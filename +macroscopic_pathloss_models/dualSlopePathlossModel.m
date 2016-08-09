classdef dualSlopePathlossModel < macroscopic_pathloss_models.generalPathlossModel
    % Dual-slope path loss model
    % (c) Martin Taranetz, INTHFT, 2012
    
    properties
       indoorPathlossExponent
       indoorAreaRadius
       wall_loss
    end
    
    methods
        function obj = dualSlopePathlossModel(indoorPathlossExponent, indoorAreaRadius, wall_loss)
            obj.name                   = 'dual slope';
            obj.indoorPathlossExponent = indoorPathlossExponent;
            obj.indoorAreaRadius       = indoorAreaRadius;
            obj.wall_loss              = wall_loss;
        end
        % Returns the pathloss in dB. Note: distance in METERS
        function pathloss_in_db = pathloss(obj,distance)
            % According to 3GPP TSG RAN WG4 (Radio) Meeting #51:	R4-092042
            pathloss_in_db_indoors  = 38.4  + obj.indoorPathlossExponent*10*log10(distance);
            pathloss_in_db_atWall   = 38.4  + obj.indoorPathlossExponent*10*log10(obj.indoorAreaRadius) - 37.6*log10(obj.indoorAreaRadius);
            pathloss_in_db_outdoors = pathloss_in_db_atWall + 37.6*log10(distance) + obj.wall_loss;
            pathloss_in_db = (distance<=obj.indoorAreaRadius).*pathloss_in_db_indoors + ...
                             (distance >obj.indoorAreaRadius).*pathloss_in_db_outdoors;
        end
    end
end