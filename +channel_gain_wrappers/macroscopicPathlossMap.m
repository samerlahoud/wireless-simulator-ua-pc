classdef macroscopicPathlossMap < channel_gain_wrappers.macroscopicPathlossWrapper
    % Class that represents the macroscopic pathloss in a precalculated way.
    % Also contains a cell assignment map that is used to initialize the 
    % UE eNodeB assignment (also used to re-create users when they go out 
    % of the Region Of Interest).
    % (c) Josep Colom Ikuno, INTHFT, 2008

    % Attributes of this give eNodeB
    properties
        % the pathloss data. Including the minimum coupling loss. Addresses as (x,y,sector,bts)
        pathloss
        
        % Pathloss map for which path loss map is generated
        site_type
        
        % Distance matrices of each sector
        distances
        
        % sector assignment (x,y,1)=sector, (x,y,2)=eNodeB
        sector_assignment
        
        % the same as before but only taking into account macroscopic pathloss (empty for data for which there is no shadow fading if applicable)
        sector_assignment2
        
        % sector sizes (in pixels) according to the sector_assignment matrix. Used to locate the users
        sector_sizes
        sector_sizes2
        
        % Connect to receiver with strongest signal
        maxSINR_assignment
        
        % data resulution in meters/pixel
        data_res
        
        % the rectangle that the map encompasses, in meters (Region Of Interest)
        roi_x
        roi_y
        
        % A name that describes this pathloss map
        name
        
        sector_idx_mapping  % sector_idx_mapping(s_idx)  = [b_ s_]
        site_sector_mapping % site_sector_mapping(b_,s_) = s_idx
        
        SINR      % SINR map
        SINR2     % Stores the SINR without the shadow fading (when applicable)
        capacity  % Capacity distribution based on the previous SINR
        capacity2 % The same but based on SINR2
        
        version = 4;
        
        % Stores the worst-case average SINR for this case
        sector_SINR
        
        % Stores the SINR difference between the maximum and the second-best option
        diff_SINR_dB
        diff_SINR_dB2
        
        % Centers of the cell
        sector_centers
        sector_centers2
    end
    % Associated eNodeB methods
    methods
        function print(obj)
            fprintf('macroscopicPathlossMap\n');
            fprintf('Data resolution: %d meters/pixel\n',obj.data_res);
            fprintf('ROI: x: %d,%d y:%d,%d\n',obj.roi_x(1),obj.roi_x(2),obj.roi_y(1),obj.roi_y(2));
        end
        
        function obj_clone = clone(obj)
            obj_clone = channel_gain_wrappers.macroscopicPathlossMap;
            
            obj_clone.pathloss            = obj.pathloss;
            obj_clone.site_type           = obj.site_type;
            obj_clone.distances           = obj.distances;
            obj_clone.sector_assignment   = obj.sector_assignment;
            obj_clone.sector_assignment2  = obj.sector_assignment2;
            obj_clone.sector_sizes        = obj.sector_sizes;
            obj_clone.sector_sizes2       = obj.sector_sizes2;
            obj_clone.maxSINR_assignment  = obj.maxSINR_assignment;
            obj_clone.data_res            = obj.data_res;
            obj_clone.roi_x               = obj.roi_x;
            obj_clone.roi_y               = obj.roi_y;
            obj_clone.name                = obj.name;
            obj_clone.sector_idx_mapping  = obj.sector_idx_mapping;
            obj_clone.site_sector_mapping = obj.site_sector_mapping;
            obj_clone.SINR                = obj.SINR;
            obj_clone.SINR2               = obj.SINR2;
            obj_clone.capacity            = obj.capacity;
            obj_clone.capacity2           = obj.capacity2;
            obj_clone.version             = obj.version;
            obj_clone.sector_SINR         = obj.sector_SINR;
            obj_clone.diff_SINR_dB        = obj.diff_SINR_dB;
            obj_clone.diff_SINR_dB2       = obj.diff_SINR_dB2;
            obj_clone.sector_centers      = obj.sector_centers;
            obj_clone.sector_centers2     = obj.sector_centers2;
        end
        
        % Returns the pathloss of a given point in the ROI (based on site and sector index: DEPRECATED)
        function pathloss = get_pathloss(obj,pos,s_,b_)
            s_idx = obj.site_sector_mapping(b_,s_);
            s_idx = s_idx(:);
            s_idx = s_idx(s_idx~=0);
            pathloss = obj.get_pathloss_eNodeB(pos,s_idx);
        end
        % Returns the pathloss of a given point in the ROI
        function pathloss = get_pathloss_eNodeB(obj,pos,enodeB_idx)
            x_ = pos(1);
            y_ = pos(2);
            point_outside_lower_bound = sum([x_ y_] < [obj.roi_x(1),obj.roi_y(1)]);
            point_outside_upper_bound = sum([x_ y_] > [obj.roi_x(2),obj.roi_y(2)]);
            if point_outside_lower_bound || point_outside_upper_bound
                pathloss = NaN;
            else
                % Some interpolation could be added here
                
                % Old way
                % pixel_coord = LTE_common_pos_to_pixel([x_ y_],obj.coordinate_origin,obj.data_res);
                
                % New way: put code instead of a function to speed up things
                pixel_coord(:,1) = floor((x_-obj.roi_x(1))/obj.data_res)+1;
                pixel_coord(:,2) = floor((y_-obj.roi_y(1))/obj.data_res)+1;
                
                pathloss = obj.pathloss(pixel_coord(:,2),pixel_coord(:,1),enodeB_idx);
            end
        end
        
        % Plots the pathloss of a given eNodeB sector
        function plot_pathloss(obj,b_,s_)
            figure;
            s_idx = obj.site_sector_mapping(b_,s_);
            imagesc(obj.pathloss(:,:,s_idx));
        end
        
        % Range of positions in which there are valid pathloss values
        function [x_range y_range] = valid_range(obj)
            x_range = [ obj.roi_x(1) obj.roi_x(2) ];
            y_range = [ obj.roi_y(1) obj.roi_y(2) ];
        end
        
        % Returns the coordinate origin for this pathloss map
        function pos = coordinate_origin(obj)
            pos = [ obj.roi_x(1) obj.roi_y(1) ];
        end
        
        function apply_MCL(obj,minimum_coupling_loss)
            % Applies a minimum coupling loss to the pathloss
            obj.pathloss = max(obj.pathloss,minimum_coupling_loss);
        end
        
        % Returns the eNodeB-sector that has the minimum pathloss for a
        % given (x,y) coordinate. Returns NaN if position is not valid
        % You can call it as:
        %   cell_assignment(pos), where pos = (x,y)
        %   cell_assignment(pos_x,pos_y)
        function [ b_ s_ s_idx] = cell_assignment(obj,pos,varargin)
            if length(varargin)<1
                x_ = pos(1);
                y_ = pos(2);
            else
                x_ = pos(1);
                y_ = varargin{1};
            end
            if max([x_ y_] < [obj.roi_x(1),obj.roi_y(1)]) >= 1
                eNodeB_id = NaN;
                sector_num = NaN;
            elseif max([x_ y_] > [obj.roi_x(2),obj.roi_y(2)]) >= 1
                eNodeB_id = NaN;
                sector_num = NaN;
            else
                % Some interpolation could be added here, but not so useful to have so much precision, actually...
                pixel_coord = LTE_common_pos_to_pixel([x_ y_],obj.coordinate_origin,obj.data_res);
                s_idx       = obj.sector_assignment(pixel_coord(2),pixel_coord(1));
                b_s_        = obj.sector_idx_mapping(s_idx,:);
                b_          = b_s_(1);
                s_          = b_s_(2);
            end
        end
        
        % Returns the number of eNodeBs and sectors per eNodeB that this
        % pathloss map contains
        function [ eNodeBs sectors_per_eNodeB ] = size(obj)
            eNodeBs            = size(obj.pathloss,4);
            sectors_per_eNodeB = size(obj.pathloss,3);
        end
        
        % Returns a random position inside of the Region Of Interest (ROI)
        function position = random_position(obj)
            position = [ random('unif',obj.roi_x(1),obj.roi_x(2)),...
                random('unif',obj.roi_y(1),obj.roi_y(2)) ];
        end
        
        % Deletes all information except for the cell assignment maps
        function delete_everything_except_cell_assignments(obj)
            obj.pathloss            = [];
            obj.name                = [];
            obj.sector_idx_mapping  = [];
            obj.site_sector_mapping = [];
            obj.SINR                = [];
            obj.SINR2               = [];
            obj.capacity            = [];
            obj.capacity2           = [];
            obj.version             = [];
            obj.sector_SINR         = [];
            obj.diff_SINR_dB        = [];
            obj.diff_SINR_dB2       = [];
        end
    end
end