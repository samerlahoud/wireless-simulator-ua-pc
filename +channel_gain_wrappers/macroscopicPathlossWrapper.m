classdef macroscopicPathlossWrapper < handle
    % This class abstracts the macroscopic pathloss. It could be stored in a
    % map (precalculated) or be calculated on the fly every time a pathloss is
    % queried without the code needing to be changed.
    % (c) Josep Colom Ikuno, INTHFT, 2008

    methods (Abstract)
        % Print some useful information
        print(obj)
        % Returns the pathloss of a given point, enodeB and sector in the ROI
        pathloss = get_pathloss(obj,pos,s_,b_)
        % Plots the pathloss of a given eNodeB sector as an imagesc
        plot_pathloss(obj,b_,s_)
        % Range of positions in which there are valid pathloss values.
        % Basically the Region Of Interest (ROI)
        [x_range y_range] = valid_range(obj)
        % Returns the coordinate origin for this pathloss map (the
        % lower-left corner of the ROI)
        pos = coordinate_origin(obj)
        % Returns the eNodeB-sector that has the minimum pathloss for a
        % given (x,y) coordinate. Returns NaN if position is not valid
        % You can call it as:
        %   cell_assignment(pos), where pos = (x,y)
        %   cell_assignment(pos_x,pos_y)
        [ eNodeB_id sector_num ] = cell_assignment(obj,pos,varargin)
        % Returns the number of eNodeBs and sectors per eNodeB that this
        % pathloss map contains
        [ eNodeBs sectors_per_eNodeB ] = size(obj)
        % Returns a random position inside of the Region Of Interest (ROI)
        position = random_position(obj)
    end
end
