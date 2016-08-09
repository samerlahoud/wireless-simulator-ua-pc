classdef eNodeB_sector < handle
    % Defines an eNodeB. The naming remaing eNodeB->site and
    % eNodeB_sector->eNodeB due to the difficulty of refactoring the whole simulator code.
    % (c) Josep Colom Ikuno, INTHFT, 2008

    properties
        id                           % Sector id inside the site
        eNodeB_id                    % Sector id for the whole sector (eNodeB) set
        parent_eNodeB                % Site to which this sector belongs
        azimuth                      % Sector antenna's azimuth
        antenna                      % Sector antenna
        attached_UEs = 0;            % Number of attached UEs
        max_power                    % eNodeB sector maximum transmit power for data, in Watts
        signaling_power              % Power dedicated to signaling. Counted as always in use
        scheduler                    % This sector's scheduler
        RB_grid                      % This sector's currently used resource block assignment grid
        nTX                          % Number of antennas
        neighbors_eNodeB             % The neighboring eNodeB (i.e. the sectors in the nighboring sites except yourself)
        
        always_on = true;            % Controls whether the eNodeB is always radiating power (dafault and worse-case scenario) or no power is used when no UEs are attached
        
        last_received_feedback       % The last received feedback
        attached_UEs_vector          % A list of attached UEs
        
        feedback_trace               % Trace that stores the received feedbacks
        sector_trace                 % Trace that stores the RB assignments
        
        zero_delay_feedback = false; % Configuration option for zero-delay CQI feedback

        macroscopic_pathloss_model   % Macroscopic pathloss model to be used. Empty if none is used (e.g. imported data)
        
        % This parameter allows you to send unquantized feedback. It can serve to assert how good a certain CQI mapping
        % approaches the target BLER in comparison to directly knowing the SINR
        unquantized_CQI_feedback = false;
        
        % extra params that may not be always used (mainly extra information from the network planning tool)
        transmitter     % This points to the pathloss file that will actually be used
        frequency_band
        antenna_name
        antenna_type
        tx_height = 32;
        electrical_downtilt
        mechanical_downtilt
    end

    methods
        
        function print(obj)
            fprintf(' Sector %d: ',obj.id);
            if obj.antenna.pattern_is_3D
                min_max_gains = obj.antenna.min_max_gain;
                fprintf('%d %.1fdB %d°\n',obj.antenna.antenna_type,min_max_gains(2),obj.azimuth);
            else
                fprintf('%s %.1fdB %d°\n',obj.antenna.antenna_type,obj.antenna.mean_antenna_gain,obj.azimuth);
            end
            fprintf('  ');
            obj.scheduler.print;
            fprintf('  UEs: ');
            for u_=1:length(obj.attached_UEs_vector)
                    fprintf('%d ',obj.attached_UEs_vector(u_).id);
            end
            fprintf('\n');
            fprintf('  '); obj.RB_grid.print;
        end
        
        % Pre-clear-workspace cleaning
        function clear(obj)
            obj.parent_eNodeB              = [];
            obj.antenna                    = [];
            obj.attached_UEs_vector        = [];
            obj.scheduler                  = [];
            obj.RB_grid                    = [];
            obj.neighbors_eNodeB           = [];
            obj.last_received_feedback     = [];
            obj.feedback_trace             = [];
            obj.sector_trace               = [];
            obj.macroscopic_pathloss_model = [];
            obj.transmitter                = [];
            obj.frequency_band             = [];
        end
        
        % Attachs a user to this eNodeB, first checking that the node is
        % not already in the list. It will update the UE's
        % 'attached_site' variable, effectively binding the UE to this
        % eNodeB. Remember to also add the user to the scheduler, or it
        % will NOT be served!
        function attachUser(obj,user)
            if isempty(obj.attached_UEs_vector)
                % If the user list is empty
                obj.attached_UEs_vector  = user;
                obj.attached_UEs         = obj.attached_UEs + 1;
            else
                % If there are already some users, check if the UE is new
                % to the list. If yes, add him.
                current_UEs = [obj.attached_UEs_vector.id];
                if ~sum(current_UEs==user.id)
                    obj.attached_UEs_vector = [obj.attached_UEs_vector user];
                    obj.attached_UEs        = obj.attached_UEs + 1;
                end
            end
            
            % Fill eNodeB-attachment info from the UE
            user.attached_sector_idx = obj.id;
            user.attached_site       = obj.parent_eNodeB;
            user.attached_eNodeB     = obj;
            
            % Also add the UE to the scheduler
            obj.scheduler.add_UE(user.id)
        end
        
        % Deattaches a user from this eNodeB. This function DOES change
        % the user's 'attached_site' variable. Remember to delete the
        % user from the scheduler also, or nonexistent users will be
        % scheduled!
        function deattachUser(obj,user)
            % If the user list is empty, do nothing. Else, delete the UE
            if ~isempty(obj.attached_UEs_vector)
                current_UEs  = [obj.attached_UEs_vector.id];
                UE_idx       = (current_UEs==user.id);
                UE_in_eNodeB = sum(UE_idx);
                
                if UE_in_eNodeB>0
                    obj.attached_UEs_vector = obj.attached_UEs_vector(~UE_idx);
                end
                obj.attached_UEs = obj.attached_UEs - UE_in_eNodeB;
            end
            % Also delete the UE from the scheduler
            obj.scheduler.remove_UE(user.id)
        end
        
        % Queries whether a user is attached
        function is_attached = userIsAttached(obj,user)
            % If the user list is empty, return false
            if ~isempty(obj.users)
                current_UEs  = [obj.attached_UEs_vector.id];
                UE_idx       = (current_UEs==user.id);
                UE_in_eNodeB = sum(UE_idx);
                is_attached  = logical(UE_in_eNodeB);
            else
                is_attached = false;
            end
        end
        
        % Receives and stores the received feedbacks from the UEs
        function receive_UE_feedback(obj)
            max_streams  = 2;
            obj.last_received_feedback.UE_id             = zeros(obj.attached_UEs,1);
            obj.last_received_feedback.tx_mode           = zeros(obj.attached_UEs,1); % From what mode the CQI and RI was taken
            obj.last_received_feedback.nCodewords        = zeros(obj.attached_UEs,1); % Relates to the ACK/NACK report. For the 0-delay case, this and tx_mode could differ (ACK is always delayed)
            obj.last_received_feedback.CQI               = zeros(obj.RB_grid.n_RB,max_streams,obj.attached_UEs);
            obj.last_received_feedback.RI                = zeros(obj.attached_UEs,1);
            obj.last_received_feedback.PMI               = nan(obj.RB_grid.n_RB,obj.attached_UEs);
            obj.last_received_feedback.feedback_received = false(obj.attached_UEs,1);
            UE_feedback_idx = 1;

            for i_=1:obj.attached_UEs
                UE_i  = obj.attached_UEs_vector(i_);
                
                % Receive the feedback from each user
                UE_id       = UE_i.id;
                feedback_u_ = UE_i.uplink_channel.get_feedback;
                % The first TTI, even with 0 delay there is no feedback, as no ACKs are available
                if ~isempty(feedback_u_)
                    % For the zero delay case, substitute the delayed feedback with a zero-delay CQI and (if applicable), RI feedback.
                    % The rest of the feedback data is delayed 1 TTI (no ACK is possible before the reception is done)
                    if obj.zero_delay_feedback
                        % TX mode relates to how the CQI and RI look like.
                        % nCodewords relates to the ACK/NACK size (not overwritten)
                        feedback_u_.tx_mode = UE_i.feedback.tx_mode;
                        feedback_u_.CQI     = UE_i.feedback.CQI;
                        if (feedback_u_.tx_mode==3) || (feedback_u_.tx_mode==4)
                            feedback_u_.RI  = UE_i.feedback.RI;
                            feedback_u_.PMI(:) = UE_i.feedback.PMI(:);
                        end
                    end

                    % Store feedback traces
                    obj.feedback_trace.store(feedback_u_,...
                        UE_id,...
                        obj.parent_eNodeB.id,...
                        obj.id,...
                        obj.parent_eNodeB.clock.current_TTI);
                    
                    % Store accumulated ACK trace. Done separately because it eases
                    % post-processing. It updates the number of correctly
                    % received bits in the trace
                    obj.sector_trace.store_ACK_report(feedback_u_);
                    
                    % Store the last received feedback for all of the attached
                    % users, as it will be needed by the scheduler.
                    % More refined schedulers may need longer "historical" information
                    obj.last_received_feedback.feedback_received(UE_feedback_idx)               = true;
                    obj.last_received_feedback.UE_id(UE_feedback_idx)                           = UE_id;
                    obj.last_received_feedback.tx_mode(UE_feedback_idx)                         = feedback_u_.tx_mode;
                    obj.last_received_feedback.nCodewords(UE_feedback_idx)                      = feedback_u_.nCodewords;
                    obj.last_received_feedback.CQI(:,1:size(feedback_u_.CQI,1),UE_feedback_idx) = feedback_u_.CQI';
                    if (feedback_u_.tx_mode==3) || (feedback_u_.tx_mode==4)
                        obj.last_received_feedback.RI(UE_feedback_idx)    = feedback_u_.RI;
                        obj.last_received_feedback.PMI(:,UE_feedback_idx) = feedback_u_.PMI;
                    end
                else
                    obj.last_received_feedback.feedback_received(UE_feedback_idx) = false;
                end
                UE_feedback_idx = UE_feedback_idx + 1;
            end            
        end
        
        % Schedule users in the RB grid for this sector. Modifies the sent
        % resourceBlockGrid object with the user allocation.
        function schedule_users(obj)
            
            % Reset the power allocation to 0. In this way, if no UEs are attached to the scheduler, no power will be transmitted
            if ~obj.always_on
                obj.RB_grid.power_allocation(:) = 0;
            end
            
            % Continue with scheduling
            obj.scheduler.schedule_users(obj.attached_UEs_vector,obj.last_received_feedback);
            % Store traces
            obj.sector_trace.store_after_scheduling(obj.RB_grid);
        end
        
        % Clear all non-basic info and leaves just basic information describing the eNodeB
        function clear_non_basic_info(obj)
            obj.antenna                    = [];
            obj.attached_UEs               = [];
            obj.scheduler                  = [];
            obj.RB_grid                    = [];
            obj.last_received_feedback     = [];
            obj.feedback_trace             = [];
            obj.sector_trace               = [];
            obj.macroscopic_pathloss_model = [];
        end
        
        % Returns a struct containing the basic information (not deleted with the previous function) from the UE
        function struct_out = basic_information_in_struct(obj)
            struct_out.id              = obj.id;
            struct_out.eNodeB_id       = obj.eNodeB_id;
            struct_out.azimuth         = obj.azimuth;                
            struct_out.max_power       = obj.max_power;
            struct_out.signaling_power = obj.signaling_power;              
            struct_out.nTX             = obj.nTX;
            struct_out.antenna_type    = obj.antenna_type;
            struct_out.tx_height       = obj.tx_height;
        end
    end
end
