classdef omnidirectionalAntenna < antennas.antenna
    % An omnidirectional antenna
    % (c) Josep Colom Ikuno, INTHFT, 2008

    methods
        function obj = omnidirectionalAntenna
            obj.antenna_type = 'omnidirectional';
            obj.max_antenna_gain = 0;
        end
        function print(obj)
            fprintf('Omnidirectional antenna\n');
        end
        function antenna_gain = gain(obj,theta)
            antenna_gain = 0;
        end
        function minmaxgain = min_max_gain(obj)
            minmaxgain(1) = [0 0];
        end
    end
end
