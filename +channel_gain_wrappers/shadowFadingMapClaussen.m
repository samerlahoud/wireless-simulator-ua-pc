classdef shadowFadingMapClaussen < handle
    % Class that represents a space-correlated shadow fading map for each
    % one of the eNodeBs. Implementation of Claussen's paper "Efficient
    % modeling of channel maps with correlated shadow fading in mobile
    % radio systems". Extended to correlate the shadow fading maps from
    % each of the eNodeBs. 1 map per eNodeB is generated, NOT 1 map per
    % sector.
    % (c) Josep Colom Ikuno, INTHFT, 2008

    % Attributes of this give eNodeB
    properties
        % number of neighbors taken into account when generating the map
        n_neighbors
        % the pathloss data. Addresses as (x,y,bts)
        pathloss
        % data resulution in meters/pixel
        data_res
        % the rectangle that the map encompasses, in meters (Region Of
        % Interest)
        roi_x
        roi_y
        
        % Standard deviation of the shadow fading
        std
        % Cross-correlation between the gaussian maps that served as base
        % for the space-correlated shadow fading maps
        an_ccorr
        % Cross-correlation between the different shadow fading maps
        sn_ccorr
        
        % By default it is assumed that one shadow fading map is generated
        % per site. This can be however changed
        oneMapPerSite = true;
    end
    
    % Associated eNodeB methods
    methods
        % Class constructor
        function obj = shadowFadingMapClaussen(...
                resolution,...
                roi_x,...
                roi_y,...
                n_neighbors,...
                num_eNodeBs,...
                mean,...
                std_a,...
                eNodeBs_ccorr,...
                varargin)
            % Generates a 2-D space-correlated shadow fading map. Implementation of
            % Claussen's paper "Efficient modeling of channel maps with correlated
            % shadow fading in mobile radio systems".
            % As suggested by TS 25.942 (still nothing specified for LTE), correlation
            % between eNodeB's shadow fading is fixed to 0.5.
            % Shadow fading is lognormal-ly distributed with mean=0dB and sd=10dB
            % (c) Josep Colom Ikuno, INTHFT, 2008
            % input:   resolution   ... desired resolution of the map in meters/pixel
            %          roi_x        ... x range of the ROI
            %          roi_y        ... y range of the ROI
            %          n_neighbours ... 4 or 8. The number of neighboring pixels to be
            %                           taken into account when generating the space
            %                           correlation.
            %          eNodeBs      ... array containing the eNodeBs.
            %                           Needed if, at some point the
            %                           cross-correlation between the maps
            %                           is changed to something that
            %                           depends on the distance between
            %                           them.
            %          mean         ... shadow fading mean
            %          std          ... shadow fading standard deviation
            %          eNodeBs_ccorr... cross correlation between the
            %                           different eNodeB's shadow fading
            %                           maps
            %          a_n (opt)    ... cross-correlated gaussian base to do the shadow
            %                           fading
            % output:  s            ... shadow fading map
            %          a_n_matrix   ... correlated white noise matrixes based on which
            %                           the shadow fading was generated.
            %          r_eNodeBs    ... target desired cross-correlation between the
            %                           several shadow fading maps.
            %          an_ccorr     ... calculated cross correlation between the
            %                           generated gaussian noises that serve as a basis
            %                           for the shadow fading map.
            %          sn_ccorr     ... calculated cross correlation between the
            %                           generated shadow fading maps.
            
            if isempty(varargin)
                deactivate_claussen_spatial_correlation = false;
            else
                deactivate_claussen_spatial_correlation = varargin{1};
            end

            %% Initialization
            roi_maximum_pixels = LTE_common_pos_to_pixel( [roi_x(2) roi_y(2)], [roi_x(1) roi_y(1)], resolution);
            
            % Pixel correlation parameters
            alpha = 1/20;
            d     = resolution; % How many meters a hop is

            % Map size in pixels
            N_x = roi_maximum_pixels(1);
            N_y = roi_maximum_pixels(2);

            %% Calculate cross-correlation between eNodeBs
            % Fixed shadow fading correlation between maps
            r_eNodeBs = eNodeBs_ccorr;

            %% Generate cross correlated gaussian maps
            % The last one will be the original random one
            a_n_random_matrix = mean + std_a*randn(N_y,N_x,num_eNodeBs);
            a_n_original_map  = mean + std_a*randn(N_y,N_x);
            
            a_n_matrix = zeros(N_y,N_x,num_eNodeBs);
            for i_=1:num_eNodeBs
                % Generate i gaussian maps based on an 'original' one
                a_n_matrix(:,:,i_) = sqrt(r_eNodeBs)*a_n_original_map + sqrt(1-r_eNodeBs)*a_n_random_matrix(:,:,i_);
            end
            
            % Get the R matrix and neighbor list for the map calculation
            [offsets_neighbors, R_alpha_sq] = obj.getCorrMatrix(n_neighbors);
            
            % Calculate the correlation matrix
            R = exp(-alpha*sqrt(R_alpha_sq)*d);

            L           = chol(R,'lower');
            lambda_n_T  = L(end,:);
            R_tilde     = R(1:end-1,1:end-1);
            L_tilde     = chol(R_tilde,'lower');
            
            if ~deactivate_claussen_spatial_correlation
                try
                    % Parallelize over all available labs.
                    eNodeBs_per_lab = ceil(num_eNodeBs/matlabpool('size'));
                    if ~isfinite(eNodeBs_per_lab)
                        eNodeBs_per_lab = num_eNodeBs;
                    end
                catch %#ok<CTCH>
                    % In case the parallel toolbox is not installed
                    eNodeBs_per_lab = num_eNodeBs;
                end
                
                if eNodeBs_per_lab~=num_eNodeBs
                    % Parallel execution
                    cell_begins       = 1:eNodeBs_per_lab:num_eNodeBs;
                    cell_Ids          = cell(1,length(cell_begins));
                    a_n_matrix_tmp    = cell(1,length(cell_begins));
                    s_temp            = cell(1,length(cell_begins));
                    
                    for i_=1:length(cell_Ids)
                        cell_Ids{i_} = cell_begins(i_):min(cell_begins(i_)-1+eNodeBs_per_lab,num_eNodeBs);
                        a_n_matrix_tmp{i_} = a_n_matrix(:,:,cell_Ids{i_});
                    end
                    
                    parfor i_=1:length(cell_Ids)
                        try
                            s_temp{i_} = channel_gain_wrappers.shadowFadingMapClaussen.spatiallyCorrelateMap_mex(...
                                n_neighbors,offsets_neighbors,...
                                L_tilde,a_n_matrix_tmp{i_},lambda_n_T);
                        catch %#ok<CTCH>
                            % In case some MEX incompatibility would arise
                            fprintf('shadow fading generation: codegen MEX function not found or returned error. Using MATLAB code instead.\n');
                            s_temp{i_} = channel_gain_wrappers.shadowFadingMapClaussen.spatiallyCorrelateMap(...
                                n_neighbors,offsets_neighbors,...
                                L_tilde,a_n_matrix_tmp{i_},lambda_n_T);
                        end
                    end
                    s = zeros(size(a_n_matrix));
                    for i_=1:length(cell_Ids)
                        s(:,:,cell_Ids{i_}) = s_temp{i_};
                    end
                else
                    % Non-parallel execution
                    try
                        s = channel_gain_wrappers.shadowFadingMapClaussen.spatiallyCorrelateMap_mex(...
                            n_neighbors,offsets_neighbors,...
                            L_tilde,a_n_matrix,lambda_n_T);
                    catch %#ok<CTCH>
                        % In case some MEX incompatibility would arise
                        fprintf('shadow fading generation: codegen MEX function not found or returned error. Using MATLAB code instead.\n');
                        s = channel_gain_wrappers.shadowFadingMapClaussen.spatiallyCorrelateMap(...
                            n_neighbors,offsets_neighbors,...
                            L_tilde,a_n_matrix,lambda_n_T);
                    end
                end
            else
                s = a_n_matrix;
            end

            %% Calculate cross-correlation between maps  (use arfor just in case there may be a lot of maps)
            an_ccorr = zeros(num_eNodeBs,num_eNodeBs); %#ok<*PROP>
            sn_ccorr = zeros(num_eNodeBs,num_eNodeBs);
            if exist('corr2')==2 %#ok<EXIST> % Check if the corr2 function exists
                % This construct would enable parfor usage
                for i_=1:num_eNodeBs
                    an_ccorr_loop = zeros(1,num_eNodeBs);
                    sn_ccorr_loop = zeros(1,num_eNodeBs);
                    for j_=i_:num_eNodeBs
                        an_ccorr_loop(j_) = corr2(a_n_matrix(:,:,i_),a_n_matrix(:,:,j_));
                        sn_ccorr_loop(j_) = corr2(s(:,:,i_),s(:,:,j_));
                    end
                    an_ccorr(i_,:)      = an_ccorr_loop;
                    sn_ccorr(i_,:) = sn_ccorr_loop;
                end
                for i_=1:num_eNodeBs
                    for j_=i_:num_eNodeBs
                        an_ccorr(j_,i_) = an_ccorr(i_,j_);
                        sn_ccorr(j_,i_) = sn_ccorr(i_,j_);
                    end
                end
            else
                an_ccorr(:) = NaN;
                sn_ccorr(:) = NaN;
            end
            
            % Standard deviation of the correlated vector
            std_s = std(s(:)); %#ok<CPROP>
            
            % Re-normalize the correlated vector
            s = (std_a/std_s)*s;
            
            %% Fill in the object
            obj.roi_x       = roi_x;
            obj.roi_y       = roi_y;
            obj.n_neighbors = n_neighbors;
            obj.data_res    = resolution;
            obj.pathloss    = s;
            obj.std         = std_a;
            obj.an_ccorr    = an_ccorr;
            obj.sn_ccorr    = sn_ccorr;
        end
        
        function obj_clone = clone(obj)
            obj_clone = channel_gain_wrappers.shadowFadingMapClaussen;
            obj_clone.n_neighbors = obj.n_neighbors;
            obj_clone.pathloss    = obj.pathloss;
            obj_clone.data_res    = obj.data_res;
            obj_clone.roi_x       = obj.roi_x;
            obj_clone.roi_y       = obj.roi_y;
            obj_clone.std         = obj.std;
            obj_clone.an_ccorr    = obj.an_ccorr;
            obj_clone.sn_ccorr    = obj.sn_ccorr;
        end

        function print(obj)
            fprintf('claussenShadowFadingMap, using %d neighbors\n',obj.n_neighbors);
            fprintf('Data resolution: %d meters/pixel\n',obj.data_res);
            fprintf('ROI: x: %d,%d y:%d,%d\n',obj.roi_x(1),obj.roi_x(2),obj.roi_y(1),obj.roi_y(2));
        end
        % Returns the pathloss of a given point in the ROI
        function pathloss = get_pathloss(obj,pos,b_)
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
                
                pathloss = obj.pathloss(pixel_coord(:,2),pixel_coord(:,1),b_);
            end
        end
        % Plots the pathloss of a given eNodeB
        function plot_pathloss(obj,b_)
            figure;
            imagesc(obj.pathloss(:,:,b_));
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
        % Returns the number of eNodeBs that this pathloss map contains
        function [ eNodeBs ] = size(obj)
            eNodeBs            = size(obj.pathloss,3);
        end
        % Returns a random position inside of the Region Of Interest (ROI)
        function position = random_position(obj)
            position = [ random('unif',obj.roi_x(1),obj.roi_x(2)),...
                random('unif',obj.roi_y(1),obj.roi_y(2)) ];
        end

        % Correlation matrix
        function [offsets_neighbors R_alpha_sq] = getCorrMatrix(obj,nNeighbors) %#ok<MANU>
            switch nNeighbors
                case 4
                    offsets_neighbors = [
                        -1  -1
                        -0  -1
                        1  -1
                        -1   0
                        ];
                    R_alpha_sq = [
                        0 1 4 1 2
                        1 0 1 2 1
                        4 1 0 5 2
                        1 2 5 0 1
                        2 1 2 1 0
                        ];
                case 8
                    offsets_neighbors = [
                        -1  -1
                        -0  -1
                        1  -1
                        -1   0
                        -1  -2
                        1  -2
                        -2  -1
                        2  -1
                        ];
                    R_alpha_sq = [
                        0 1 4 1 1 5 1 9 2
                        1 0 1 2 2 2 4 4 1
                        4 1 0 5 5 1 9 1 2
                        1 2 5 0 4 8 2 10 1
                        1 2 5 4 0 4 2 10 5
                        5 2 1 8 4 0 10 2 5
                        1 4 9 2 2 10 0 16 5
                        9 4 1 10 10 2 16 0 5
                        2 1 2 1 5 5 5 5 0
                        ];
                case 12
                    offsets_neighbors = [
                        -1  -1
                        -0  -1
                        1  -1
                        -1   0
                        -1  -2
                        1  -2
                        -2  -1
                        2  -1
                        0 -2
                        -2 0
                        -2 -2
                        -2 2
                        ];
                    R_alpha_sq = [
                        0 1 4 1 1 5 1 9 2 2 2 10 2
                        1 0 1 2 2 2 4 4 1 5 5 13 1
                        4 1 0 5 5 1 9 1 2 10 10 18 2
                        1 2 5 0 4 8 2 10 5 1 5 5 1
                        1 2 5 4 0 4 2 10 1 5 1 17 5
                        5 2 1 8 4 0 10 2 1 13 9 25 5
                        1 4 9 2 2 10 0 16 5 1 1 9 5
                        9 4 1 10 10 2 16 0 5 17 17 25 5
                        2 1 2 5 1 1 5 5 0 8 4 20 4
                        2 5 10 1 5 13 1 17 8 0 4 4 4
                        2 5 10 5 1 9 1 17 4 4 0 16 8
                        10 13 18 5 17 25 9 25 20 4 16 0 8
                        2 1 2 1 5 5 5 5 4 4 8 8 0
                        ];
                otherwise
                    error('Supported values are 4, 8, and 12.');
            end
        end
    end
end