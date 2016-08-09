classdef eNodeB < handle
    % Class that represents an LTE eNodeB site. The naming remaing
    % eNodeB->site and eNodeB_sector->eNodeB due to the difficulty of
    % refactoring the whole simulator code.
    %
    % Attributes of this give eNodeB site.
    % (c) Josep Colom Ikuno, INTHFT, 2008
    properties
        % eNodeB ID. It is also the index in the eNodeB site array in the simulator!!!
        id                   % Position in meters (x,y)
        pos                  % Stores info about the eNodeB's sectors. Mainly azimuth and antenna type
        sectors              % The neighboring sites, ordered by distance
        name
        altitude = 0;
        site_name
        
        site_type            % Whether this a macro cell, femto, or something else
        clock                % Network clock. Tells the network elements in whhich TTIs they are
    end
    % Associated eNodeB methods
    methods
        function print(obj)
            fprintf('eNodeB %d, position (x,y): (%3.2f,%3.2f), altitude: %3.0fm, %d attached UEs\n',obj.id,obj.pos(1),obj.pos(2),obj.altitude,obj.attached_UEs);
            for s_=1:length(obj.sectors)
                obj.sectors(s_).print;
            end
        end
        
        % Pre-clear-workspace cleaning
        function clear(obj)
            obj.sectors          = [];
            obj.clock            = [];
        end
        
        % Queries whether a user is attached
        function is_attached = userIsAttached(obj,user)
            for s_ = 1:length(obj.sectors)
                if obj.sectors(1).userIsAttached(user);
                    is_attached = true;
                    return
                end
            end
            is_attached = false;
        end
        % Returns the number of UEs currently attached to this eNodeB
        function number_of_attached_UEs = attached_UEs(obj)
            temp = zeros(1,length(obj.sectors));
            for s_ = 1:length(obj.sectors)
                temp(s_) = obj.sectors(s_).attached_UEs;
            end
            number_of_attached_UEs = sum(temp);
        end
        
        % Returns a struct containing the basic information (not deleted with the previous function) from the UE
        function struct_out = basic_information_in_struct(obj)
            struct_out.id              = obj.id;
            struct_out.pos             = obj.pos;
            for s_=1:length(obj.sectors)
                struct_out.sectors(s_) = obj.sectors(s_).basic_information_in_struct();
            end
            struct_out.site_type       = obj.site_type;                
        end
    end
end