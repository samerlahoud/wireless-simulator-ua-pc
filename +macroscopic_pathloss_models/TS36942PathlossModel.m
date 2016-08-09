classdef TS36942PathlossModel < macroscopic_pathloss_models.generalPathlossModel
    % Propagation conditions as proposed by TS 36.942 V8.0.0
    % (c) Josep Colom Ikuno, INTHFT, 2009
    % www.nt.tuwien.ac.at
    properties
        frequency    % Frequency in HERTZs (for consistency, although this 
                     % model makes calculations with frequencies set in MHz
        environment  % Environment that this instance represents

        Dhb          % The base station antenna height in metres, measured from the average rooftop level (for the urban_area model)
        Hb           % The base station antenna height above ground in metres
        
        % This was supposed to be a function handle that would call the
        % correct one (urban micro, macro, suburban...). But since this
        % messed up a little bit with the profiler, it will now be a number
        % urban_area    = 1
        % rural_area    = 2
        pathloss_function_handle

    end

    methods
        % Class constructor
        function obj = TS36942PathlossModel(frequency,environment)
            obj.frequency   = frequency;
            obj.environment = environment;
            obj.name        = 'TS 36.942';
            
            % Dhb is the base station antenna height in metres, measured
            % from the average rooftop level (TS 36.942)
            switch environment
                case 'urban'
                    obj.name = [obj.name ' urban area'];
                    obj.pathloss_function_handle = 1;
                    % Using suggested values in TS 36.942
                    obj.Dhb = 15;
                case 'rural'
                    obj.name = [obj.name ' rural area'];
                    obj.pathloss_function_handle = 2;
                    % Using suggested values in TS 36.942
                    obj.Hb  = 45;
                otherwise
                    error(['"' environment '"" environment not valid']);
            end
        end
        
        % Returns the macroscopic pathloss in dB. Note: distance in METERS
        function pathloss_in_db = pathloss(obj,distance)
            % Restrict that pathloss must be bigger than MCL
            switch obj.pathloss_function_handle
                case 1
                    pathloss_in_db = obj.pathloss_urban(distance);
                case 2
                    pathloss_in_db = obj.pathloss_rural(distance);
            end
        end
        
        % Urban area pathloss
        function pl = pathloss_urban(obj,distance)
            % Macro cell propagation model for urban area is applicable for
            % scenarios in urban and suburban areas outside the high rise
            % core where the buildings are of nearly uniform height.
            % TS 36.942, subclause 4.5.2.
            % (c) Josep Colom Ikuno, INTHFT
            %           distance ... actual distance in m
            % output:   pl       ... NLOS pathloss in dB
            
            distance  = distance/1000;                     % Calculations are done in Km
            frequency = obj.frequency/1000000; %#ok<*PROP> % Calculations are done in freq in MHz

            pl = 40*(1-4e-3*obj.Dhb)*log10(distance)-18*log10(obj.Dhb)+21*log10(frequency)+80;
        end
        
        % Rural area pathloss
        function pl = pathloss_rural(obj,distance)
            % For rural area, the Hata model was used in the work item
            % UMTS900.
            % TS 36.942, subclause 4.5.3.
            % (c) Josep Colom Ikuno, INTHFT
            %           distance ... actual distance in m
            % output:   pl       ... NLOS pathloss in dB
            
            distance = distance/1000;          % Calculations are done in Km
            frequency = obj.frequency/1000000; % Calculations are done in freq in MHz

            pl = 69.55+26.16*log10(frequency)-13.82*log10(obj.Hb)+(44.9-6.55*log10(obj.Hb))*log10(distance)-4.78*(log10(frequency)^2)+18.33*log10(frequency)-40.94;
        end
    end
end