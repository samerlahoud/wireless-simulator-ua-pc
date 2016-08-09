classdef TS25814PathlossModel < macroscopic_pathloss_models.generalPathlossModel
    % Propagation conditions as proposed by TS 36.942 V8.0.0
    % (c) Josep Colom Ikuno, INTHFT, 2009
    % www.nt.tuwien.ac.at
    properties
        frequency    % Frequency in HERTZs
        I
    end

    methods
        % Class constructor 
        function obj = TS25814PathlossModel(frequency)
            switch frequency
                case 2e9
                    obj.I = 128.1;
                case 900e6
                    obj.I = 120.9;
                otherwise
                    error('Only 900MHz and 2GHz defined for this channel');
            end
            obj.frequency = frequency;
            obj.name = 'TS 25.814';
        end
        
        % Returns the macroscopic pathloss in dB. Note: distance in METERS
        function pathloss_in_db = pathloss(obj,distance)
            pathloss_in_db = obj.I + 37.6*log10(distance/1000);
        end
    end
end