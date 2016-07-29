classdef kathreinTSAntenna < antennas.antenna
    % Kathrein antenna with adjustable electrical and mechanical downtilt
    % (c) Martin Taranetz, Josep Colom Ikuno INTHFT 2010
    
    properties
        electrical_tilt
        horizontal_degree
        vertical_degree
        horizontal_gain_pattern
        vertical_gain_pattern
        frequency
    end
    
    methods
        function obj = kathreinTSAntenna(kathrein_antenna_folder, kathrein_antenna_gain_pattern, frequency,varargin)
            kathrein_antenna_gain_pattern = str2num(kathrein_antenna_gain_pattern);
            obj.antenna_type = kathrein_antenna_gain_pattern;
            obj.frequency    = frequency;
            % Read all Antenna files of corresponding type.
            % Antenna Files in .msi Format
            % antenna_data_all            = utils.msiFileImporter(kathrein_antenna_folder); 
            % Antenna Files in .txap Capesso Format
            
            antenna_data_all = utils.antennaFileImporter(kathrein_antenna_folder);
            
            antenna_data_by_frequency   = antenna_data_all.id_frequency_subset(kathrein_antenna_gain_pattern,frequency,'closest');
            
            obj.max_antenna_gain        = [antenna_data_by_frequency.antenna_data.max_antenna_gain];
            obj.electrical_tilt         = [antenna_data_by_frequency.antenna_data.electrical_tilt];
            obj.horizontal_degree       = [antenna_data_by_frequency.antenna_data.horizontal_degree];
            obj.horizontal_gain_pattern = [antenna_data_by_frequency.antenna_data.horizontal_gain_pattern];
            obj.vertical_degree         = [antenna_data_by_frequency.antenna_data.vertical_degree];
            obj.vertical_gain_pattern   = [antenna_data_by_frequency.antenna_data.vertical_gain_pattern];
            
            obj.pattern_is_3D = true;
        end
        
        % Print some information of the antenna
        function print(obj)
            fprintf('Kathrein %s Antenna with maximum gain %f\n',obj.antenna_type,max(obj.max_antenna_gain));
            fprintf(['Range of electrical electrical tilts : ',int2str(obj.electrical_tilt), '\n']);
        end
        
        % Returns antenna gain as a function of theta, phi, electrical tilt
        % and mechanical tilt (downtilting denoted with positive degrees)
        function antenna_gain = gain(obj, phi, theta, electrical_tilt, mechanical_tilt)
            % Check if the gain pattern is available for the demanded electrical tilt
            index_ = obj.get_tilt_idx(electrical_tilt);
            
            % Convert input to 0°-359°
            phi = utils.miscUtils.wrapTo359(phi);
            phi(phi==360) = 0;
            theta = utils.miscUtils.wrapTo359(theta);
            theta(theta==360) = 0;
            
            if index_
                % No mechanical downtilting
                if mechanical_tilt==0
                    % Generate gain pattern - method 'cubic' used because performs extrapolation for values btw. 359° and 360°
                    horizontal_gain = interp1(obj.horizontal_degree(:,index_), obj.horizontal_gain_pattern(:,index_), phi, 'cubic', 'extrap');
                    vertical_gain = interp1(obj.vertical_degree(:,index_), obj.vertical_gain_pattern(:,index_), theta,'cubic', 'extrap');
                    % The most common method of getting the 3D antenna pattern is this one. You can check the following for background info
                    % @inproceedings{TWBOJRF09mofp,
                    %    author          = "Lars Thiele and Thomas Wirth and Kai Börner and Michael Olbrich and Volker Jungnickel and Juergen Rumold and Stefan Fritze", 
                    %    title           = "{Modeling of 3D Field Patterns of Downtilted Antennas and Their Impact on Cellular Systems}", 
                    %    booktitle       = "{International ITG Workshop on Smart Antennas (WSA 2009)}", 
                    %    address         = "Berlin, Germany", 
                    %    month           = feb, 
                    %    year            = "2009", 
                    % }
                    % http://www.mk.tu-berlin.de/publikationen/objects/2009/publikation.2008-11-20.2619100490/datei
                   antenna_gain = obj.max_antenna_gain(index_) - horizontal_gain - vertical_gain;
                % Mechanical tilting
                else
                    % Implement mechanical downtilting using meshgrid
                    [A(:,:,2) A(:,:,3)] = meshgrid(-90:90, 0:360);
                    A(:,:,1) = obj.max_antenna_gain(index_);
                    
                    vert_gain_pattern = interp1(obj.vertical_degree(:,index_),  obj.vertical_gain_pattern(:,index_)  , utils.miscUtils.wrapTo359(A(:,:,2)) , 'cubic', 'extrap');
                    hor_gain_pattern  = interp1(obj.horizontal_degree(:,index_), obj.horizontal_gain_pattern(:,index_), A(:,:,3) , 'cubic', 'extrap');
                    A(:,:,1) = A(:,:,1) - hor_gain_pattern - vert_gain_pattern;
                    % Scalar radius
                    A(:,:,1) = 10.^(A(:,:,1)./10);
                   
                    % Cartesian coordinates
                    B(:,:,1) = A(:,:,1).*cos(deg2rad(A(:,:,2))).*cos(deg2rad(A(:,:,3)));    % x
                    B(:,:,2) = A(:,:,1).*cos(deg2rad(A(:,:,2))).*sin(deg2rad(A(:,:,3)));    % y
                    B(:,:,3) = A(:,:,1).*sin(deg2rad(A(:,:,2)));                            % z
                    
                    % Apply rotation
                    theta_mechanical_tilt = deg2rad(-mechanical_tilt);
                    B_rot(:,:,1) = B(:,:,1).*cos(theta_mechanical_tilt) + B(:,:,3).*sin(theta_mechanical_tilt);
                    B_rot(:,:,2) = B(:,:,2);
                    B_rot(:,:,3) = B(:,:,1).*(-sin(theta_mechanical_tilt)) + B(:,:,3).*cos(theta_mechanical_tilt);
                    
                    % Retransform to polar coordinate system
                    A_rot = zeros(size(A));
                    A_rot(:,:,1) = sqrt(B_rot(:,:,1).^2+B_rot(:,:,2).^2+B_rot(:,:,3).^2);
                    A_rot(:,:,2) = asin(B_rot(:,:,3)./A_rot(:,:,1));
                    A_rot(:,:,3) = atan2(B_rot(:,:,2), B_rot(:,:,1));
                    
                    % display([min(min(A_rot(:,:,1))) max(max(A_rot(:,:,1)))]);
                    % display([min(min(rad2deg(A_rot(:,:,2)))) max(max(rad2deg(A_rot(:,:,2))))]);
                    % display([min(min(rad2deg(A_rot(:,:,3)))) max(max(rad2deg(A_rot(:,:,3))))]);
                    
                    % display([min(min(theta)) max(max(theta))]);
                    % display([min(min(phi)) max(max(phi))]);
                    
                    % Turn off duplicate data point warnings
                    warning off MATLAB:griddata:DuplicateDataPoints;
                    antenna_gain_scalar_wn = griddata(A_rot(:,:,2), A_rot(:,:,3), A_rot(:,:,1), deg2rad(theta), deg2rad(wrapTo180(phi)),'cubic');
                    antenna_gain_scalar_wn (antenna_gain_scalar_wn(:,:)<0) = NaN;
                    antenna_gain_scalar = utils.miscUtils.fillnans(antenna_gain_scalar_wn, 3, 20);
                    antenna_gain = 10*log10(antenna_gain_scalar);
                end
            else
                error(['No antenna gain pattern available for electrical tilt: ',num2str(electrical_tilt),'°']);
            end
        end
        
        % Check if the gain pattern is available for the demanded electrical tilt
        function index_ = get_tilt_idx(obj,electrical_tilt)
            index_ = find(obj.electrical_tilt == electrical_tilt);
            if isempty(index_)
                error('Electrical tilt of %3.2f° not allowed. Only {%s} degrees allowed.',electrical_tilt,num2str(obj.electrical_tilt));
            end
        end
        
        % Returns the maximum and minimum antenna gain [min max]
        function minmaxgain = min_max_gain(obj)
            % max works columnwise
            min_hor = min(obj.max_antenna_gain - max(obj.horizontal_gain_pattern));
            min_ver = min(obj.max_antenna_gain - max(obj.vertical_gain_pattern));
            minmaxgain(1) = min(min_hor, min_ver); 
            minmaxgain(2) = max(obj.max_antenna_gain);
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