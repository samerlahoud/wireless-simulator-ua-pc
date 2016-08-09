classdef fixedPathlossModel < macroscopic_pathloss_models.generalPathlossModel
    % Fixed pathloss model. i.e., returns always the same pathloss value
    % (c) Josep Colom Ikuno, INTHFT, 2013
    properties
        pathloss_value
    end

    methods
        function obj = fixedPathlossModel(pathloss_value)
            obj.name           = 'fixed pathloss';
            obj.pathloss_value = pathloss_value;
        end
        % Returns the pathloss values
        function pathloss_in_db = pathloss(obj,distance)
            pathloss_in_db = obj.pathloss_value(ones(size(distance)));
        end
    end
end
