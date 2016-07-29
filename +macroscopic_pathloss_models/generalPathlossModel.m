classdef generalPathlossModel
    % Abstract class that represents a pathloss model. Also wraps the code
    % that calculates the macroscopic pathloss maps (used for macro and
    % femtocells).
    % (c) Josep Colom Ikuno, INTHFT, 2008
    properties
        % this model's name
        name
    end
    methods (Abstract)
        pathloss_in_db = pathloss(distance)
    end
    methods (Static)
        function calculate_pathloss_maps(LTE_config,eNodeBs,networkMacroscopicPathlossMap,varargin)
            if ~isempty(varargin)
                elevation_map     = varargin{1};
                elevation_map_set = true;
            else
                elevation_map     = 0;
                elevation_map_set = false;
            end
            
            % Calculates the pathloss maps for a given eNodeB set (cell set)
            total_sectors         = length([eNodeBs.sectors]);
            data_res              = networkMacroscopicPathlossMap.data_res;
            roi_x                 = networkMacroscopicPathlossMap.roi_x;
            roi_y                 = networkMacroscopicPathlossMap.roi_y;
            roi_maximum_pixels    = LTE_common_pos_to_pixel( [roi_x(2) roi_y(2)], [roi_x(1) roi_y(1)], data_res);
            roi_height_pixels     = roi_maximum_pixels(2);
            roi_width_pixels      = roi_maximum_pixels(1);
            distance_matrix_2D    = zeros(roi_height_pixels,roi_width_pixels,length(eNodeBs));
            cell_pathloss_data    = zeros(roi_height_pixels,roi_width_pixels,total_sectors);
            sector_antenna_gain   = zeros(roi_height_pixels,roi_width_pixels,total_sectors);
            sector_distances      = zeros(roi_height_pixels,roi_width_pixels,total_sectors);
            
            site_positions     = reshape([eNodeBs.pos],2,[])';
            site_positions_pix = LTE_common_pos_to_pixel( site_positions, [roi_x(1) roi_y(1)], data_res);
            
            % Generate distance and angle matrix
            position_grid_pixels      = zeros(roi_height_pixels*roi_width_pixels,2);
            position_grid_pixels(:,1) = reshape(repmat(1:roi_width_pixels,roi_height_pixels,1),1,roi_width_pixels*roi_height_pixels);
            position_grid_pixels(:,2) = repmat(1:roi_height_pixels,1,roi_width_pixels);
            position_grid_meters      = LTE_common_pixel_to_pos(position_grid_pixels,networkMacroscopicPathlossMap.coordinate_origin,networkMacroscopicPathlossMap.data_res);
            
            %% Sector pathloss
            s_idx = 1;
            all_sectors   = [eNodeBs.sectors];
            eNodeB_id_set = [all_sectors.eNodeB_id];
            for b_ = 1:length(eNodeBs)
                distances                  = sqrt((position_grid_meters(:,1)-eNodeBs(b_).pos(1)).^2 + (position_grid_meters(:,2)-eNodeBs(b_).pos(2)).^2);
                distance_matrix_2D(:,:,b_) = reshape(distances,roi_height_pixels,roi_width_pixels);
                for s_ = 1:length(eNodeBs(b_).sectors)
                    
                    if isempty(eNodeBs(b_).sectors(s_).macroscopic_pathloss_model)
                        capesso_pathloss = true;
                    else
                        capesso_pathloss = false;
                    end
                    
                    % Distance matrix for each sector
                    sector_distances(:,:,s_idx) = distance_matrix_2D(:,:,b_);
                    
                    if LTE_config.calculate_3D_pathloss
                        % Although the elevation map and the site information should have the same information, the elevation map info takes precedence
                        if elevation_map_set
                            eNodeB_elevation = elevation_map(site_positions_pix(b_,2),site_positions_pix(b_,1));
                        else
                            eNodeB_elevation = eNodeBs(b_).altitude;
                        end
                        
                        % Vertical angle grid
                        sector_distances(:,:,s_idx) = sqrt((eNodeBs(b_).sectors(s_).tx_height + elevation_map - eNodeB_elevation - LTE_config.rx_height).^2+distance_matrix_2D(:,:,b_).^2);
                    end
                    
                    % Calculate macroscopic pathloss using the macroscopic pathloss model from each eNodeB
                    if ~capesso_pathloss
                        cell_pathloss_data(:,:,s_idx) = eNodeBs(b_).sectors(s_).macroscopic_pathloss_model.pathloss(sector_distances(:,:,s_idx));
                    else
                        cell_pathloss_data(:,:,s_idx) = networkMacroscopicPathlossMap.pathloss(:,:,s_idx);
                    end
                    
                    % Horizontal angle grid
                    angle_grid = (180/pi)*(atan2((position_grid_meters(:,2)-eNodeBs(b_).pos(2)),(position_grid_meters(:,1)-eNodeBs(b_).pos(1)))) - utils.miscUtils.wrapTo359(-eNodeBs(b_).sectors(s_).azimuth+90); % Convert the azimuth (0°=North, 90°=East, 180^=South, 270°=West) degrees to cartesian
                    
                    if eNodeBs(b_).sectors(s_).antenna.pattern_is_3D
                        % Although the elevation map and the site information should have the same information, the elevation map info takes precedence
                        if elevation_map_set
                            eNodeB_elevation = elevation_map(site_positions_pix(b_,2),site_positions_pix(b_,1));
                        else
                            eNodeB_elevation = eNodeBs(b_).altitude;
                        end
                        
                        % Horizontal angle grid
                        horizontal_angle_grid   = reshape(angle_grid,roi_height_pixels,roi_width_pixels);
                        horizontal_angle_grid_s = utils.miscUtils.wrapTo359(horizontal_angle_grid);
                        
                        % Vertical angle grid
                        % 'atan2d' available for MATLAB r2012b and newer, so we stick to the old atan2 in radians.
                        vertical_angle_grid_el = (180/pi)*atan2(eNodeBs(b_).sectors(s_).tx_height + elevation_map - eNodeB_elevation - LTE_config.rx_height, distance_matrix_2D(:,:,b_));
                        
                        % Calculate antenna gain
                        switch class(eNodeBs(b_).sectors(s_).antenna)
                            case 'antennas.kathreinTSAntenna'
                                sector_antenna_gain(:,:,s_idx) = eNodeBs(b_).sectors(s_).antenna.gain(horizontal_angle_grid_s, vertical_angle_grid_el, eNodeBs(b_).sectors(s_).electrical_downtilt, eNodeBs(b_).sectors(s_).mechanical_downtilt);
                            case 'antennas.TS36942_3DAntenna'
                                % Set phi to (-180,180)
                                horizontal_angle_grid_s = horizontal_angle_grid_s + 180;
                                horizontal_angle_grid_s = mod(horizontal_angle_grid_s,360);
                                horizontal_angle_grid_s = horizontal_angle_grid_s - 180;
                                
                                % Set theta to (-180,180)
                                vertical_angle_grid_el = vertical_angle_grid_el + 180;
                                vertical_angle_grid_el = mod(vertical_angle_grid_el,360);
                                vertical_angle_grid_el = vertical_angle_grid_el - 180;
                                
                                sector_antenna_gain(:,:,s_idx) = eNodeBs(b_).sectors(s_).antenna.gain(horizontal_angle_grid_s, vertical_angle_grid_el, eNodeBs(b_).sectors(s_).electrical_downtilt);
                            otherwise
                                error('3D antenna pattern %s not recognized',class(eNodeBs(b_).sectors(s_).antenna));
                        end
                    else
                        % Calculate angle
                        theta_matrix = reshape(angle_grid,roi_height_pixels,roi_width_pixels);
                        
                        % Set sector_azimuth to (-180,180)
                        theta_matrix                   = theta_matrix + 180;
                        theta_matrix                   = mod(theta_matrix,360);
                        theta_matrix                   = theta_matrix - 180;
                        sector_antenna_gain(:,:,s_idx) = eNodeBs(b_).sectors(s_).antenna.gain(theta_matrix);
                    end
                    
                    % Mapping between s_idx and b_/s_ pair
                    networkMacroscopicPathlossMap.sector_idx_mapping(eNodeBs(b_).sectors(s_).eNodeB_id,:) = [b_ s_];
                    networkMacroscopicPathlossMap.site_sector_mapping(b_,s_)  = eNodeBs(b_).sectors(s_).eNodeB_id;
                    % Site type, for which path loss map is generated
                    eNodeB_site_type{s_idx}  = eNodeBs(b_).site_type;
                    
                    s_idx = s_idx + 1;
                end
            end
            
            % Just in case...
            cell_pathloss_data(isnan(cell_pathloss_data) | (cell_pathloss_data<0)) = 0;
            networkMacroscopicPathlossMap.pathloss(:,:,eNodeB_id_set)  = cell_pathloss_data - sector_antenna_gain;
            networkMacroscopicPathlossMap.distances(:,:,eNodeB_id_set) = sector_distances;
            if ~iscell(networkMacroscopicPathlossMap.site_type)
               networkMacroscopicPathlossMap.site_type                = cell(length(eNodeB_id_set),1);
               networkMacroscopicPathlossMap.site_type(eNodeB_id_set) = eNodeB_site_type;
            else
               networkMacroscopicPathlossMap.site_type(eNodeB_id_set) = eNodeB_site_type;
            end
            %             i_ = 1;
%             for j_ = eNodeB_id_set
%                networkMacroscopicPathlossMap.site_type{j_} = eNodeB_site_type{i_};
%                i_ = i_ + 1;
%             end
        end
        
        function macroscopic_pathloss_model = generateMacroscopicPathlossModel(LTE_config,macroscopic_pathloss_model_name,frequency,macroscopic_pathloss_model_settings)
            % Returns an appropriate pathloss model based on the provided information
            print_output = true;
            switch macroscopic_pathloss_model_name
                case 'free space'
                    if isfield(macroscopic_pathloss_model_settings,'alpha')
                        macroscopic_pathloss_model = macroscopic_pathloss_models.freeSpacePathlossModel(frequency,macroscopic_pathloss_model_settings.alpha);
                    else
                        macroscopic_pathloss_model = macroscopic_pathloss_models.freeSpacePathlossModel(frequency);
                    end
                    if print_output && LTE_config.debug_level>=1
                        fprintf('free space pathloss model\n');
                    end
                case 'cost231'
                    macroscopic_pathloss_model = macroscopic_pathloss_models.cost231PathlossModel(frequency,macroscopic_pathloss_model_settings.environment);
                    if print_output && LTE_config.debug_level>=1
                        fprintf('COST 231 pathloss model, %s environment\n',macroscopic_pathloss_model_settings.environment);
                    end
                case 'TS36942'
                    macroscopic_pathloss_model = macroscopic_pathloss_models.TS36942PathlossModel(frequency,macroscopic_pathloss_model_settings.environment);
                    if print_output && LTE_config.debug_level>=1
                        fprintf('TS 36.942-recommended pathloss model, %s environment\n',macroscopic_pathloss_model_settings.environment);
                    end
                case 'TS25814'
                    macroscopic_pathloss_model = macroscopic_pathloss_models.TS25814PathlossModel(frequency);
                    if print_output && LTE_config.debug_level>=1
                        fprintf('TS 25.814-recommended pathloss model\n');
                    end
                case 'dual slope'
                    macroscopic_pathloss_model = macroscopic_pathloss_models.dualSlopePathlossModel(macroscopic_pathloss_model_settings.indoorPathlossExponent,macroscopic_pathloss_model_settings.indoorAreaRadius,macroscopic_pathloss_model_settings.wall_loss);
                    if print_output && LTE_config.debug_level>=1
                        fprintf('dual slope pathloss model\n');
                    end
                case 'fixed pathloss'
                    macroscopic_pathloss_model = macroscopic_pathloss_models.fixedPathlossModel(macroscopic_pathloss_model_settings.pathloss);
                    if print_output && LTE_config.debug_level>=1
                        fprintf('fixed pathloss model\n');
                    end
                otherwise
                    error('"%s" macroscopic pathloss model not supported',macroscopic_pathloss_model_name);
            end
        end
    end
end
