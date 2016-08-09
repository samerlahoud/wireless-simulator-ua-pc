classdef shadowFadingDummyMap < handle
    % A dummy shadow fading map. Returns always 0
    % (c) Josep Colom Ikuno, INTHFT, 2011

    % Attributes of this give eNodeB
    properties
        roi_x
        roi_y
        N_x
        N_y
    end
    
    % Associated eNodeB methods
    methods
        function obj = shadowFadingDummyMap(roi_x,roi_y,varargin)
            %% Initialization
            roi_maximum_pixels = LTE_common_pos_to_pixel( [roi_x(2) roi_y(2)], [roi_x(1) roi_y(1)], 5);

            % Map size in pixels
            obj.N_x = roi_maximum_pixels(1);
            obj.N_y = roi_maximum_pixels(2);
            
            %% Fill in the object
            obj.roi_x       = roi_x;
            obj.roi_y       = roi_y;
        end
        
        function obj_clone = clone(obj)
            obj_clone = channel_gain_wrappers.shadowFadingDummyMap(obj.roi_x,obj.roi_y);
        end
        
        function print(obj)
            fprintf('shadowFadingDummyMap\n');
        end
        % Returns the pathloss of a given point in the ROI
        function pathloss = get_pathloss(obj,pos,b_)
            pathloss = zeros(1,1,length(b_));
        end
        % Plots the pathloss of a given eNodeB
        function plot_pathloss(obj,varargin)
            figure;
            imagesc(zeros(obj.N_y,obj.N_x));
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
            eNodeBs = NaN;
        end
        % Returns a random position inside of the Region Of Interest (ROI)
        function position = random_position(obj)
            position = [ random('unif',obj.roi_x(1),obj.roi_x(2)),...
                random('unif',obj.roi_y(1),obj.roi_y(2)) ];
        end
    end
end