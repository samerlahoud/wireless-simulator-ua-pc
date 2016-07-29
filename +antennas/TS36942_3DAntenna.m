classdef TS36942_3DAntenna < antennas.antenna
    % 3D antenna pattern according to TS36.814 Table A.2.1.1-2
    % (c) Martin Taranetz, Josep Colom Ikuno INTHFT 2012
    
    properties
    end
    
    methods
        function obj = TS36942_3DAntenna(max_antenna_gain)
            obj.antenna_type     = 'TS36.942 3D antenna';
            obj.max_antenna_gain = max_antenna_gain;
            obj.pattern_is_3D    = true;
        end
        
        % Print some information of the antenna
        function print(obj)
            fprintf('%s Antenna with maximum gain %f \n',obj.antenna_type,obj.max_antenna_gain);
        end
        
        % Returns antenna gain as a function of theta, phi, electrical tilt
        % and mechanical tilt (downtilting denoted with positive degrees)
        function antenna_gain = gain(obj, phi, theta, electrical_tilt)
            if isempty(electrical_tilt)
                electrical_tilt = 0;
            end
            A_m   = 25;
            SLA_v = 20;
            A_H   = -min(12*(phi/70).^2,A_m);
            vert_deg_lobe = 10;
            A_V   = -min(12*((theta-electrical_tilt)/vert_deg_lobe).^2,SLA_v);
            A_HV  = -min(-(A_H+A_V),A_m);
            
            antenna_gain = obj.max_antenna_gain+A_HV;
        end
        
        function minmaxgain = min_max_gain(obj)
            minmaxgain(1) = obj.gain(180,180,0);
            minmaxgain(2) = obj.max_antenna_gain;
        end
        
        % Returns a horizontal and vertical antenna gain plot for a
        % specific tilt value. Returns antenna gain in dBi
        function [hor_degrees hor_gain ver_degrees ver_gain max_gain] = gain_patterns(obj,tilt)
            index_ = obj.get_tilt_idx(tilt);
            max_gain    = obj.max_antenna_gain(index_);
            hor_degrees = obj.horizontal_degree(:,index_);
            hor_gain    = -obj.horizontal_gain_pattern(:,index_) + max_gain;
            ver_degrees = obj.vertical_degree(:,index_);
            ver_gain    = -obj.vertical_gain_pattern(:,index_) + max_gain;
        end
    end
    
end