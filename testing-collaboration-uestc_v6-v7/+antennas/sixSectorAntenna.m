classdef sixSectorAntenna < antennas.antenna
    % An example antenna for showing the six-sector case. Values taken from
    % Performance Evaluation of 6-Sector-Site Deployment for Downlink UTRAN Long Term Evolution, 2008
    % @INPROCEEDINGS{4657216, 
    % author={Kumar, S. and Kovacs, I.Z. and Monghal, G. and Pedersen, K.I. and Mogensen, P.E.}, 
    % booktitle={Vehicular Technology Conference, 2008. VTC 2008-Fall. IEEE 68th}, title={Performance Evaluation of 6-Sector-Site Deployment for Downlink UTRAN Long Term Evolution}, 
    % year={2008}, 
    % month={sept.}, 
    % doi={10.1109/VETECF.2008.384}, 
    % }
    % http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=4657216
    % (c) Josep Colom Ikuno, INTHFT, 2008

    methods
        function obj = sixSectorAntenna(max_antenna_gain)
            obj.antenna_type = 'six sector';
            obj.max_antenna_gain = max_antenna_gain;
        end
        function print(obj)
            fprintf('Six sector antenna, mean gain: %d\n',obj.max_antenna_gain);
        end
        function antenna_gain = gain(obj,theta)
            antenna_gain = -min(12*(theta/35).^2,23) + obj.max_antenna_gain;
        end
        function minmaxgain = min_max_gain(obj)
            minmaxgain(1) = obj.gain(180);
            minmaxgain(2) = obj.max_antenna_gain;
        end
    end
end
