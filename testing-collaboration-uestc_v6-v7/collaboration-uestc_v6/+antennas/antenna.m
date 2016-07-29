classdef antenna
    % This Abstract class represents an antenna
    % (c) Josep Colom Ikuno, INTHFT, 2008

    properties
        antenna_type
        max_antenna_gain
        pattern_is_3D = false;
    end

    methods (Abstract)
        % Print some info
        print(obj)
        % Returns antenna gain as a function of theta
        antenna_gain = gain(obj,theta)
        % Returns the maximum and minimum antenna gain [min max]
        minmaxgain = min_max_gain(obj)
    end
    
    methods (Static)
        function attach_antenna_to_eNodeB(an_eNodeB,LTE_config)
            switch an_eNodeB.antenna_type
                case 'berger'
                    an_eNodeB.antenna = antennas.bergerAntenna(LTE_config.antenna.max_antenna_gain);
                case 'TS 36.942'
                    an_eNodeB.antenna = antennas.TS36942Antenna(LTE_config.antenna.max_antenna_gain,LTE_config.TS_36942_3dB_lobe);
                case 'TS 36.942 3D'
                    an_eNodeB.antenna = antennas.TS36942_3DAntenna(LTE_config.antenna.max_antenna_gain);
                    
                    % Additional parameters
                    an_eNodeB.parent_eNodeB.altitude = LTE_config.site_altitude;
                    an_eNodeB.electrical_downtilt    = LTE_config.antenna.electrical_downtilt;
                case 'six-sector'
                    an_eNodeB.antenna = antennas.sixSectorAntenna(LTE_config.antenna.max_antenna_gain);
                case 'omnidirectional'
                    an_eNodeB.antenna = antennas.omnidirectionalAntenna;
                case 'kathreinTSAntenna'
                    kathrein_antenna_folder = LTE_config.antenna.kathrein_antenna_folder;
                    antenna_type            = LTE_config.antenna.antenna_type; %#ok<PROP>
                    frequency               = LTE_config.antenna.frequency;
                    an_eNodeB.antenna       = antennas.kathreinTSAntenna(kathrein_antenna_folder, antenna_type, frequency);
                    
                    % Additional parameters
                    an_eNodeB.parent_eNodeB.altitude = LTE_config.site_altitude;
                    an_eNodeB.mechanical_downtilt    = LTE_config.antenna.mechanical_downtilt;
                    an_eNodeB.electrical_downtilt    = LTE_config.antenna.electrical_downtilt;
                otherwise
                    error('This antenna is not supported');
            end
        end
    end
end
