classdef freeSpacePathlossModel < macroscopic_pathloss_models.generalPathlossModel
    % Free space pathloss model
    % (c) Josep Colom Ikuno, INTHFT, 2008
    properties
        frequency % Frequency in HERTZs
        alpha = 2;
    end

    methods
        function obj = freeSpacePathlossModel(frequency,varargin)
            obj.frequency = frequency;
            obj.name = 'free space';
            if ~isempty(varargin)
                obj.alpha = varargin{1};
            end
        end
        % Returns the free-space pathloss in dB. Note: distance in METERS
        function pathloss_in_db = pathloss(obj,distance)
            % Restrict that pathloss must be bigger than 0 dB
            pathloss_in_db = max(10*log10((4*pi/299792458*distance*obj.frequency).^obj.alpha),0);
        end
    end
end
