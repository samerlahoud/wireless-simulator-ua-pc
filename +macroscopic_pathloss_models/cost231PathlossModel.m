classdef cost231PathlossModel < macroscopic_pathloss_models.generalPathlossModel
    % COST231 pathloss model
    % (c) Josep Colom Ikuno, INTHFT, 2008
    properties
        frequency    % Frequency in HERTZs (for consistency, although this 
                     % model makes calculations with frequencies set in MHz
        environment  % Environment that this instance represents

        Cm           % correction factor for dense buildings (dB), urban_macro and suburban_macro only
        h_base       % height of base station (m)
        h_mobile     % height of the mobile (m)
        d_min        % minimum base station distance in m
        
        h_roof       % height of buildings (m), urban_micro only
        w            % width of the roads (m), urban_micro only
        b            % building separation (m), urban_micro only
        phi          % road orientation with respect to the direct radio path (°), urban_micro only
        
        minimum_pathloss
        
        % This was supposed to be a function handle that would call the
        % correct one (urban micro, macro, suburban...). But since this
        % messed up a little bit with the profiler, it will now be a number
        % urban_micro    = 1
        % urban_macro    = 2
        % suburban_macro = 3
        pathloss_function_handle

    end

    methods
        % Class constructor
        function obj = cost231PathlossModel(frequency,environment)
            obj.frequency = frequency;
            obj.environment = environment;
            obj.name = 'COST231';
            switch environment
                case 'urban_micro'
                    obj.name = [obj.name ' urban micro'];
                    obj.pathloss_function_handle = 1;
                    % values according to TR25.996
                    obj.h_base = 12.5;
                    obj.h_mobile = 1.5;
                    obj.d_min = 20;
                    
                    obj.h_roof = 12;
                    obj.w = 25;
                    obj.b = 50;
                    obj.phi = 30;
                case 'urban_macro'
                    obj.name = [obj.name ' urban macro'];
                    obj.pathloss_function_handle = 2;
                    % values according to TR25.996
                    obj.Cm = 3;
                    obj.h_base = 32;
                    obj.h_mobile = 1.5;
                    obj.d_min = 35;
                case 'suburban_macro'
                    obj.name = [obj.name ' suburban macro'];
                    obj.pathloss_function_handle = 3;
                    % values according to TR25.996
                    obj.Cm = 0;
                    obj.h_base = 32;
                    obj.h_mobile = 1.5;
                    obj.d_min = 35;
                otherwise
                    error(['"' environment '"" environment not valid']);
            end
            
            switch obj.pathloss_function_handle
                case 1
                    obj.minimum_pathloss = obj.pathloss_urbanmicro(obj.d_min);
                case 2
                    obj.minimum_pathloss = obj.pathloss_urbanmacro(obj.d_min);
                case 3
                    obj.minimum_pathloss = obj.pathloss_suburbanmacro(obj.d_min);
            end
        end
        
        % Returns the NLOS pathloss in dB. Note: distance in METERS
        function pathloss_in_db_NLOS = pathloss(obj,distance)
            % Restrict that pathloss must be bigger than the loss with the minimum distance
            switch obj.pathloss_function_handle
                case 1
                    pathloss_in_db_NLOS = obj.pathloss_urbanmicro(distance);
                case 2
                    pathloss_in_db_NLOS = obj.pathloss_urbanmacro(distance);
                case 3
                    pathloss_in_db_NLOS = obj.pathloss_suburbanmacro(distance);
            end
            pathloss_in_db_NLOS = max(pathloss_in_db_NLOS,obj.minimum_pathloss);
        end
        
        % COST 231 urban micro pathloss
        function pl_NLOS = pathloss_urbanmicro(obj,distance)
            % function to evaluate the microcell LOS and NLOS pathloss based on the COST231
            % Walfish-Ikegami model, see TR25.996 and COST 231 book
            % (c) Martin Wrulich, INTHFT
            %           distance ... actual distance in m
            % output:   pl_NLOS  ... NLOS pathloss in dB

            pl_NLOS = LTE_aux_COST231_urban_micro_pathloss(...
                distance,...
                obj.frequency,...
                obj.h_roof,...
                obj.h_base,...
                obj.h_mobile,...
                obj.phi,...
                obj.w,...
                obj.b); %NLOS pathloss
        end
        
        % COST 231 urban macro pathloss
        function pl_NLOS = pathloss_urbanmacro(obj,distance)
            % function to evaluate the urban macrocell pathloss based on the COST 231
            % extended Hata model, see 3GPP TR25.996 and COST 231 book
            % (c) Martin Wrulich, INTHFT
            % input:    distance ... actual distance in m
            % output:   pl_NLOS  ... NLOS pathloss in dB
            
            distance = distance/1000;          % Calculations are done in Km
            frequency = obj.frequency/1000000; % Calculations are done in freq in MHz

            a = (1.1*log10(frequency) - 0.7)*obj.h_mobile - ...
                (1.56*log10(frequency)-0.8);

            pl_NLOS = 46.3 + 33.9*log10(frequency) - 13.82*log10(obj.h_base) - a + (44.9 - 6.55*log10(obj.h_base))*log10(distance) + obj.Cm;
        end
        
        % COST 231 suburban macro pathloss
        function pl_NLOS = pathloss_suburbanmacro(obj,distance)
            % function to evaluate the suburban macrocell pathloss based on the COST 231
            % extended Hata model, see 3GPP TR25.996 and COST 231 book
            % (c) Martin Wrulich, INTHFT
            % input:    distance ... actual distance in m
            % output:   pl_NLOS  ... NLOS pathloss in dB
            
            distance = distance/1000;          % Calculations are done in Km
            frequency = obj.frequency/1000000; % Calculations are done in freq in MHz

            a = (1.1*log10(frequency) - 0.7)*obj.h_mobile - ...
                (1.56*log10(frequency)-0.8);

            pl_NLOS = 46.3 + 33.9*log10(frequency) - 13.82*log10(obj.h_base) - a + (44.9 - 6.55*log10(obj.h_base))*log10(distance) + obj.Cm;
        end
    end
end