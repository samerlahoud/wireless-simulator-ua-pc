classdef TS36942Antenna < antennas.antenna
    % An antenna, as defined by TS 36.942, subclause 4.2.1.1
    % (c) Josep Colom Ikuno, INTHFT, 2008
    
    properties
        angle_3dB = 65;
    end
    
    methods
        function obj = TS36942Antenna(max_antenna_gain,varargin)
            obj.antenna_type = 'TS 36.942';
            obj.max_antenna_gain = max_antenna_gain;
            if ~isempty(varargin)
                obj.angle_3dB = varargin{1};
            end
        end
        function print(obj)
            fprintf('TS 36.942 antenna, mean gain: %d\n',obj.max_antenna_gain);
        end
        function antenna_gain = gain(obj,theta)
            antenna_gain = -min(12*(theta/obj.angle_3dB).^2,20) + obj.max_antenna_gain;
        end
        function minmaxgain = min_max_gain(obj)
            % minmaxgain(1) = -min(12*(180/70)^2,20) + obj.max_antenna_gain;
            minmaxgain(1) = obj.gain(180);
            minmaxgain(2) = obj.max_antenna_gain;
        end
    end
end
