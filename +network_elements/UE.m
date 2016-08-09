classdef UE < handle
    % Class that represents an LTE UE (user)
    % (c) Josep Colom Ikuno, INTHFT, 2008
    
    properties
        
        id                    % Unique UE id
        pos                   % pos in meters (x,y)
        attached_site         % Site to where this user is attached
        attached_sector_idx   % sector index to which the UE is attached
        attached_eNodeB       % eNodeB to which the UE is attached to
        
        walking_model         % Walking model for this user
        downlink_channel      % Downlink channel model for this user
        RB_grid               % This links to obj.downlink_channel.RB_grid Stored again here for efficiency reasons
        
        uplink_channel        % Uplink channel model for this user
        receiver_noise_figure % Noise figure for this specific UE (dB)
        thermal_noise_W_RB    % Calculated based on the thermal noise density and the receiver noise figure in Watts/RB
        penetration_loss      % Penetration loss in dB for this user
        wall_loss = 0;        % wall loss that only affects interferers [dB]
        nRX                   % Number of receive antennas
        antenna_gain          % Antenna gain of the UE
        
        trace                 % Trace that stores info about what happened
        clock                 % Network clock. Tells the UE in what TTI he is
        CQI_mapper            % Performs the mapping between SINR and CQI
        
        % Output of the link quality (measurement) model.
        link_quality_model_output
        
        % Data to be fedbacked to the eNodeB. It is used to pass the feedback data to the send_feedback() function
        feedback
        
        % Whether the CQI feedback should be unquantized. Having this set
        % to true is equivalent to directly sending the post-equalization
        % SINR for each codeword (note that there is still a layer mapping)
        unquantized_CQI_feedback
        
        % Will decide whether a give TB made it or not
        BLER_curves
        
        % Gives the means to average the several Transport Block (TB) SINRs
        SINR_averager
        
        % Contains the LTE precoding codebook
        codebook
        
        % Signaling from the eNodeB to this UE. This is a direct channel
        % between the eNodeB and this UE, where it gets signaled
        % UE-specific signaling information. The signaled information and
        % where it is located is as follows:
        %   UEsignaling:
        %     - TB_CQI           % CQI used for the transmission of each codeword
        %     - TB_size          % size of the current TB, in bits
        %     - tx_mode          % transmission mode used (SISO, tx diversity, spatial multiplexing)
        %     - rv_idx           % redundancy version index for each codeword
        %   downlink_channel.RB_grid
        %     - user_allocation  % what UE every RB belongs to
        %     - power_allocation % how much power to allocate to each RB,
        %     - n_RB             % RB grid size (frequency)
        %     - sym_per_RB       % number of symbols per RB (12 subcarriers, 0.5ms)
        %     - size_bits        % total size of the RB grid in bits
        %     - numStreams       % maximum number of allowed streams. Resource allocation is described for all of them
        eNodeB_signaling
        
        % Extra tracing options (default options)
        trace_SINR
        
        % average preequalization SNR at current position (averaged over microscopic fading and noise)
        SNR_avg_preequal
        
        % This is an "overall SINR", calculated by summing up all of the
        % signal power and dividing it by the sum of all interfering and
        % noise power.
        wideband_SINR
        
        % Lets you use instead of the link quality and performance models
        % dummy funcitons that output dummy values. Useful if you would like
        % to "deactivate" some UEs to shorten simulation time. Note that the
        % feedback will also be deactivated.
        deactivate_UE
        
        % This variable is used for the default feedback calculation sent in
        % case the UE was not scheduled. For the old (v1) trace format, this
        % sets the actual transmit mode.
        default_tx_mode
        
        traffic_model
        lambda = 0;
        
        adaptive_RI
        
        % Helper variables for the very simple handover management. Just
        % meant as an example as to how that could be implemented.
        cell_change
        
        % Safe temporarily for tracing
        rx_power_tb_in_current_tti
        rx_power_interferers_in_current_tti
        
        % If the attached cell and pathloss (RSRP) come from a trace
        trace_UE = false;
    end
    
    methods
        % Constructor with the default UE parameter values
        function obj = UE
            obj.unquantized_CQI_feedback  = false;
            obj.trace_SINR                = false;
            obj.deactivate_UE             = false;
            obj.cell_change.requested     = false;
            obj.cell_change.target_eNodeB = [];
        end
        
        function print(obj)
            if isempty(obj.attached_site)
                fprintf('User %d, (%d,%d), not attached to an eNodeB\n',obj.id,obj.pos(1),obj.pos(2));
            else
                fprintf('User %d, (%d,%d), Site %d, sector %d (eNodeB %d)\n',obj.id,obj.pos(1),obj.pos(2),obj.attached_site.id,obj.attached_sector_idx,obj.attached_eNodeB.eNodeB_id);
            end
            obj.walking_model.print;
        end
        
        % Clear variables
        function clear(obj)
            obj.attached_site             = [];
            obj.attached_eNodeB           = [];
            obj.walking_model             = [];
            obj.downlink_channel          = [];
            obj.RB_grid                   = [];
            obj.uplink_channel            = [];
            obj.trace                     = [];
            obj.clock                     = [];
            obj.CQI_mapper                = [];
            obj.link_quality_model_output = [];
            obj.feedback                  = [];
            obj.BLER_curves               = [];
            obj.SINR_averager             = [];
            obj.eNodeB_signaling          = [];
            obj.traffic_model             = [];
            obj.codebook                  = [];
        end
        
        % Move this user according to its settings
        function move(obj)
            new_pos = obj.walking_model.move(obj.pos);
            obj.pos = new_pos;
        end
        % Move this user to where it was the last TTI before according to
        % its settings
        function move_back(obj)
            old_pos = obj.walking_model.move(obj.pos);
            obj.pos = old_pos;
        end
        function UE_in_roi = is_in_roi(a_UE,roi_x_range,roi_y_range)
            % Tells you whether a user in in the Region of Interest (ROI) or not
            % (c) Josep Colom Ikuno, INTHFT, 2008
            % input:    a_UE         ... the UE in question
            %           roi_x_range  ... roi x range. minimum and maximum x coordinates
            %                            which are valid
            %           roi_y_range  ... roi y range. minimum and maximum y coordinates
            %                            which are valid
            % output:   UE_in_roi  ... true or false, whether the UE is inside or not

            UE_pos_x = a_UE.pos(1);
            UE_pos_y = a_UE.pos(2);

            if UE_pos_x<roi_x_range(1) || UE_pos_x>roi_x_range(2)
                UE_in_roi = false;
                return;
            end

            if UE_pos_y<roi_y_range(1) || UE_pos_y>roi_y_range(2)
                UE_in_roi = false;
                return;
            end
            UE_in_roi = true;
        end
        % Starts handover procedures from the currently attached eNodeB to
        % the specified target_eNodeB
        % for now... immediate handover. A proper implementation remains
        % pending.
        function start_handover(obj,new_eNodeB)
            % Remove the user from the eNodeB and its scheduler
            obj.attached_eNodeB.deattachUser(obj);
            
            % Add the user to the eNodeB and its scheduler
            new_eNodeB.attachUser(obj);
            
            % Set a new channel realization
            pregenerated_ff = obj.downlink_channel.fast_fading_model.ff_trace;
            N_eNodeBs       = length(obj.downlink_channel.fast_fading_model.interfering_starting_points);
            obj.downlink_channel.set_fast_fading_model_model(channel_gain_wrappers.fastFadingWrapper(pregenerated_ff,'random',N_eNodeBs));
        end

        % Measure whatever needs to be measured and send a feedback to the attached eNodeB
        function send_feedback(obj)
            obj.uplink_channel.send_feedback(obj.feedback);
        end
        
        function [...
                interfering_eNodeBs,...
                user_macroscopic_pathloss_dB,...
                user_shadow_fading_loss_dB,...
                there_are_interferers...
                ] = get_signal_macroscale_losses(obj)
            % Read macro scale pathloss values for the signal part
            if ~obj.trace_UE
                interfering_eNodeBs          = obj.attached_eNodeB.neighbors_eNodeB;
                user_macroscopic_pathloss_dB = obj.downlink_channel.macroscopic_pathloss + obj.penetration_loss - obj.antenna_gain;
                user_shadow_fading_loss_dB   = obj.downlink_channel.shadow_fading_pathloss;
                there_are_interferers        = ~isempty(interfering_eNodeBs);
            else
                UE_id       = obj.id;
                UE_trace    = obj.downlink_channel.macroscopic_pathloss_model.pathloss(UE_id);
                current_TTI = obj.clock.current_TTI;
                current_trace_time = floor((current_TTI-1)/UE_trace.TTIs_per_time_idx)+1;
                
                current_pathlosses = UE_trace.pathloss(current_trace_time,:);
                user_macroscopic_pathloss_dB = min(current_pathlosses);
                user_shadow_fading_loss_dB   = 0;
                there_are_interferers        = length(current_pathlosses)>1;
                
                attached_cell = UE_trace.attached_cell(current_trace_time);
                all_cells     = UE_trace.cellsIds(current_trace_time,:);
                if there_are_interferers
                    interfering_eNodeBs = obj.downlink_channel.eNodeBs(all_cells(all_cells~=attached_cell));
                else
                    interfering_eNodeBs = [];
                end
            end
        end
        
        function [interfering_macroscopic_pathloss_eNodeB_dB, interfering_shadow_fading_loss_dB]...
                = get_interfering_macroscale_losses(obj,interfering_eNodeB_ids,parent_sites_id)
            % Read macro scale pathloss values for the interference part
            if ~obj.trace_UE
                interfering_macroscopic_pathloss_eNodeB_dB = obj.downlink_channel.interfering_macroscopic_pathloss(interfering_eNodeB_ids) + obj.penetration_loss - obj.antenna_gain;
                interfering_shadow_fading_loss_dB          = obj.downlink_channel.interfering_shadow_fading_pathloss(parent_sites_id);
            else
                UE_id       = obj.id;
                UE_trace    = obj.downlink_channel.macroscopic_pathloss_model.pathloss(UE_id);
                current_TTI = obj.clock.current_TTI;
                current_trace_time = floor((current_TTI-1)/UE_trace.TTIs_per_time_idx)+1;
                
                % The ordering comes from the traces, so we do not need to
                % do a one-by-one mapping
                current_cells      = UE_trace.cellsIds(current_trace_time,:);
                current_pathlosses = UE_trace.pathloss(current_trace_time,:);
                interfering_macroscopic_pathloss_eNodeB_dB = current_pathlosses(current_cells~=obj.attached_eNodeB.eNodeB_id)'; % Must be a column vector
                interfering_shadow_fading_loss_dB          = 0;
            end
        end
        
        % Calculates the receiver SINR, which is the metric used to measure link quality
        function link_quality_model(obj,config)
            
            % Get current time
            t = obj.clock.time;
            
            % Get map-dependant parameters for the current user
            [...
                interfering_eNodeBs,...
                user_macroscopic_pathloss_dB,...
                user_shadow_fading_loss_dB,...
                there_are_interferers...
                ] = obj.get_signal_macroscale_losses;
            user_macroscopic_pathloss_linear = 10^(0.1*user_macroscopic_pathloss_dB);
            user_shadow_fading_loss_linear   = 10^(0.1*user_shadow_fading_loss_dB);

            % Number of codewords, layers, power etc. assigned to this user
            DL_signaling = obj.eNodeB_signaling;
            tx_mode      = obj.default_tx_mode;         % Fixed tx mode according to LTE_config
            the_RB_grid  = obj.downlink_channel.RB_grid;
            nRB          = the_RB_grid.n_RB;
            nSC          = nRB*2;
            
            % Get the RX power (power allocation) from the target eNodeB
            TX_power_data      = the_RB_grid.power_allocation';
            TX_power_signaling = the_RB_grid.power_allocation_signaling';
            RX_total_RB        = (TX_power_data+TX_power_signaling)./user_macroscopic_pathloss_linear./user_shadow_fading_loss_linear;
            RX_total           = reshape([RX_total_RB; RX_total_RB],1,[])/(2);
            
            % Get fast fading trace for this subframe
            [zeta,chi,psi] = obj.downlink_channel.fast_fading_model.generate_fast_fading_signal(t,tx_mode);

            %% The SINR calculation is done under the following circumstances:
            % Power allocation is done on a per-subframe (1 ms) and RB basis
            % The fast fading trace is given for every 6 subcarriers (every
            % 90 KHz), so as to provide enough samples related to a
            % worst-case-scenario channel length
            
            % TX_power_signaling_half_RB =  TODO: add signaling interference in better-modeled way
            S_dims = size(zeta);
            S_dims(2) = 1; % All MATLAB variables have at least 2 dimensions, so not a problem.
            
            % RX power
            switch tx_mode
                case 1     % SISO
                    RX_power = RX_total.*zeta.';
                otherwise  % TxD, OLSM or CLSM
                    RX_power_half_RB_repmat = repmat(RX_total,S_dims);
                    RX_power = RX_power_half_RB_repmat.*zeta;
            end
            
            % Get interfering eNodeBs
            if there_are_interferers % no interfering eNodeBs present (single eNodeB simulation)
                parent_sites                            = [interfering_eNodeBs.parent_eNodeB];
                parent_sites_id                         = [parent_sites.id];
                interfering_eNodeB_ids                  = [interfering_eNodeBs.eNodeB_id];
                interfering_RB_grids                    = [interfering_eNodeBs.RB_grid];
                interfering_power_allocations_data      = [interfering_RB_grids.power_allocation];
                interfering_power_allocations_signaling = [interfering_RB_grids.power_allocation_signaling];
                
                % Get macroscopic pathloss and shadow fading values
                [interfering_macroscopic_pathloss_eNodeB_dB,interfering_shadow_fading_loss_dB] = obj.get_interfering_macroscale_losses(...
                    interfering_eNodeB_ids,parent_sites_id);
                interfering_macroscopic_pathloss_eNodeB_linear = 10.^(0.1*interfering_macroscopic_pathloss_eNodeB_dB);
                interfering_shadow_fading_loss_linear          = 10.^(0.1*interfering_shadow_fading_loss_dB);
                
                % Total power allocations
                interfering_power_allocations = interfering_power_allocations_data + interfering_power_allocations_signaling;
                
                total_RX_Power   = 10*log10(sum(RX_total_RB));
                totalInterfPower = 10*log10(reshape(sum(interfering_power_allocations,1),[],1))-interfering_macroscopic_pathloss_eNodeB_dB-interfering_shadow_fading_loss_dB;
                CI_dB            = total_RX_Power-totalInterfPower;
                
                % Overwrite variables to take into consideration just the interferers up to 45dB below our signal
                interfererIdxs = CI_dB < 45;
                if sum(interfererIdxs)==0 % Just to avoid a crash
                    interfererIdxs(1) = true;
                end
                interfering_eNodeB_ids                         = interfering_eNodeB_ids(interfererIdxs);
                interfering_macroscopic_pathloss_eNodeB_linear = interfering_macroscopic_pathloss_eNodeB_linear(interfererIdxs);
                interfering_power_allocations                  = interfering_power_allocations(:,interfererIdxs);
                interfering_eNodeBs                            = interfering_eNodeBs(interfererIdxs);
                if ~isscalar(interfering_shadow_fading_loss_linear)
                    % Only if the shadow fading is not a scalar (i.e., there is shadow fading)
                    interfering_shadow_fading_loss_linear = interfering_shadow_fading_loss_linear(interfererIdxs);
                else
                    interfering_shadow_fading_loss_linear = ones(length(interfering_macroscopic_pathloss_eNodeB_linear),1);
                end
                
                % Get interfering channel fading parameters
                theta = obj.downlink_channel.fast_fading_model.generate_fast_fading_interference(t,tx_mode,interfering_eNodeB_ids);
                SINR_interf_dims = size(theta);
                
                % Get assigned interfering power on a per-half-RB-basis
                if config.feedback_channel_delay~=0
                    interfering_power_allocations_temp = interfering_power_allocations/2;
                    interf_power_all_RB = reshape([interfering_power_allocations_temp(:) interfering_power_allocations_temp(:)]',2*size(interfering_power_allocations_temp,1),[]); % Take scheduled power
                else
                    if ndims(SINR_interf_dims)==2 %#ok<ISMAT>
                        TX_power_interferers = [interfering_eNodeBs.max_power]/SINR_interf_dims(2);
                        interf_power_all_RB  = TX_power_interferers(ones(1,SINR_interf_dims(2)),:);
                    else
                        interf_power_all_RB = repmat([interfering_eNodeBs.max_power]/SINR_interf_dims(2),[SINR_interf_dims(2) 1]); % Turn on all interferers
                    end
                end
                
                temp_macro_mat      = interfering_macroscopic_pathloss_eNodeB_linear';
                temp_macro_mat      = temp_macro_mat(ones(SINR_interf_dims(2),1),:); 
                temp_shadow_mat     = interfering_shadow_fading_loss_linear';
                temp_shadow_mat     = temp_shadow_mat(ones(SINR_interf_dims(2),1),:);
                interf_power_all_RB = interf_power_all_RB./temp_macro_mat./temp_shadow_mat; % Add macro and shadow fading
                
                % Temporarily safe interference power on per RB block basis; For tracing and statistical evaluation
                % of interference.
                
                interference_structure_debug = false;
                if interference_structure_debug
                    if (obj.clock.current_TTI==1)&&(~obj.deactivate_UE) %#ok<UNRCH>
                        % Assume unit power, i.e. transmit power per RB = 1
                        % Take only taps from first RB as representative
                        % Reason: Shadow fading is constant for all RBs.
                        microscale_fading_taps_temp  = theta(:,1);
                        shadow_fading_taps_temp      = interfering_shadow_fading_loss_linear;
                        composite_fading_taps_temp   = microscale_fading_taps_temp.*shadow_fading_taps_temp;
                        aggregated_interference_temp = sum(theta./temp_macro_mat'./temp_shadow_mat',1);
                        if (exist('Interference Statistics.mat','file'))
                            load('Interference Statistics.mat', 'microscale_fading_taps', 'shadow_fading_taps', 'composite_fading_taps', 'aggregated_interference_taps');
                            microscale_fading_taps       = [microscale_fading_taps;       microscale_fading_taps_temp];
                            shadow_fading_taps           = [shadow_fading_taps;           shadow_fading_taps_temp];
                            composite_fading_taps        = [composite_fading_taps;        composite_fading_taps_temp];
                            aggregated_interference_taps = [aggregated_interference_taps; aggregated_interference_temp(1)];
                            save('Interference Statistics.mat', 'microscale_fading_taps', 'shadow_fading_taps','composite_fading_taps','aggregated_interference_taps');
                        else
                            microscale_fading_taps       = microscale_fading_taps_temp;
                            shadow_fading_taps           = shadow_fading_taps_temp;
                            composite_fading_taps_temp   = composite_fading_taps_temp;
                            aggregated_interference_taps = aggregated_interference_temp(1);
                            save('Interference Statistics.mat', 'microscale_fading_taps', 'shadow_fading_taps','composite_fading_taps','aggregated_interference_taps');
                        end
                    end
                end
                
                obj.rx_power_tb_in_current_tti = mean(RX_total_RB,2); % linear scale !
                
                % To avoid errors. This trace is thought for SISO
                obj.rx_power_interferers_in_current_tti = zeros(2,size(interf_power_all_RB,2));
                if length(size(interf_power_all_RB))==2
                    obj.rx_power_interferers_in_current_tti(1,:) = 2*mean(interf_power_all_RB(:,:),1); % linear scale !
                    % Add eNodeB ID of interferer as second line to rx power (in order to identify interferer tiers)
                    obj.rx_power_interferers_in_current_tti(2,:) = interfering_eNodeB_ids;
                else
                    obj.rx_power_interferers_in_current_tti(1,:) = NaN;
                    obj.rx_power_interferers_in_current_tti(2,:) = NaN;
                end
                
                max_Layers = SINR_interf_dims(1);
                if length(SINR_interf_dims) > 3
                    N_RI = SINR_interf_dims(4);
                else
                    N_RI = 1;
                end
                
                switch tx_mode
                    case 1
                        interf_power_all_RB_repmat = interf_power_all_RB.';
                    otherwise
                        interf_power_all_RB_repmat = zeros(SINR_interf_dims);
                        for nLayers = 1:max_Layers
                            for RI = 1:N_RI
                                interf_power_all_RB_repmat(nLayers,:,:,RI) = interf_power_all_RB;
                            end
                        end
                        
                        % This line is totally incorrect!!!
                        % interf_power_all_RB_repmat = reshape(repmat(interf_power_all_RB,SINR_interf_dims_repmat),SINR_interf_dims); % Also valid for the case where more than one rank is used
                end
            else
                obj.rx_power_interferers_in_current_tti = 0;
            end
            
            % Calculate thermal noise
            thermal_noise_watts_per_half_RB = obj.thermal_noise_W_RB/2;
            
            % Calculate average preequalization SNR
            % This is a total SNR, the same as in the Link Level Simulator
            obj.SNR_avg_preequal = 10*log10(mean(RX_total)./thermal_noise_watts_per_half_RB); % mean over the subcarriers
            
            switch tx_mode
                case 1
                    % SINR calculation (SISO)
                    noise_plus_inter_layer_power = psi.*thermal_noise_watts_per_half_RB;
                    
                    if there_are_interferers
                        % Also works for more than one rank (i.e. extra dimension)
                        interfering_rx_power = squeeze(sum(interf_power_all_RB_repmat.*theta,1));
                        Interference_plus_noise_power = noise_plus_inter_layer_power + interfering_rx_power.';
                    else
                        Interference_plus_noise_power = noise_plus_inter_layer_power;
                    end
                    SINR_linear = RX_power ./ Interference_plus_noise_power.'; % Divide thermal noise by 2: Half-RB frequency bins
                    
                    % Calculate SIR
                    % if there_are_interferers
                    %     SIR_linear = RX_power ./ interfering_rx_power.';
                    % else
                    %     SIR_linear = Inf(size(SINR_linear));
                    % end
                otherwise
                    % SINR calculation (TxD, OLSM, CLSM)
                    noise_plus_inter_layer_power = chi.*RX_power + psi.*thermal_noise_watts_per_half_RB; % Divide thermal noise by 2: Half-RB frequency bins
                    if there_are_interferers
                        % Also works for more than one rank (i.e. extra dimension)
                        interfering_rx_power = squeeze(sum(interf_power_all_RB_repmat.*theta,3));
                        Interference_plus_noise_power = noise_plus_inter_layer_power + interfering_rx_power;
                    else
                        Interference_plus_noise_power = noise_plus_inter_layer_power;
                    end
                    SINR_linear = RX_power ./ Interference_plus_noise_power;
                    
                    % Calculate SIR
                    % if there_are_interferers
                    %     SIR_linear = RX_power ./ interfering_rx_power;
                    % else
                    %     SIR_linear = Inf(size(SINR_linear));
                    % end
            end

            % Calculation of the wideband SINR
            if there_are_interferers
                obj.wideband_SINR = 10*log10(sum(RX_total(:))/(sum(interf_power_all_RB(:))+thermal_noise_watts_per_half_RB*nSC));
            else
                obj.wideband_SINR = 10*log10(sum(RX_total(:))/(thermal_noise_watts_per_half_RB*nSC));
            end
            
            % Calculation of the post-equalization symbols SINR
            SINR_dB = 10*log10(SINR_linear);
            % SIR_dB  = 10*log10(SIR_linear);
            
            % Calculate and save feedback, as well as the measured SINRs
            obj.calculate_feedback(config,tx_mode,SINR_linear,SINR_dB,nRB,[],DL_signaling);
        end
        
        % Next version of the Link Quality model, implemented with run-time precoding
        function link_quality_model_v2(obj,config)
            
            % Get current time
            t = obj.clock.time;
            
            % Get map-dependant parameters for the current user
            % Get map-dependant parameters for the current user
            [...
                interfering_eNodeBs,...
                user_macroscopic_pathloss_dB,...
                user_shadow_fading_loss_dB,...
                there_are_interferers...
                ] = obj.get_signal_macroscale_losses;
            user_macroscopic_pathloss_linear = 10^(0.1*user_macroscopic_pathloss_dB);
            user_shadow_fading_loss_linear   = 10^(0.1*user_shadow_fading_loss_dB);
            
            N_interferers                    = length(interfering_eNodeBs);
            interfering_eNodeBs_idxs         = [interfering_eNodeBs.eNodeB_id];

            % Number of codewords, layers, power etc. assigned to this user
            DL_signaling = obj.eNodeB_signaling;
            tx_mode      = DL_signaling.tx_mode;
            
            % For the case the UE is not scheduled
            if DL_signaling.num_assigned_RBs==0
                tx_mode = obj.default_tx_mode;
            end
            
            the_RB_grid  = obj.downlink_channel.RB_grid;
            
            % Get fast fading trace for this subframe
            [H_0, H_i, PMI_precalc] = obj.downlink_channel.fast_fading_model.generate_fast_fading_v2(t,interfering_eNodeBs);
            PMI_precalc_sc        = kron(PMI_precalc,[1;1]);
            [nRX, nTX, nSC] = size(H_0);
            nRB           = the_RB_grid.n_RB;
            max_layer     = min(nRX,nTX);

            % The SINR calculation is done under the following circumstances:
            % Power allocation is done on a per-subframe (1 ms) and RB basis. The fast fading trace is given for every 6 subcarriers (every 90 KHz)

            % TX power for each layer
            RX_power_RB      = (the_RB_grid.power_allocation + the_RB_grid.power_allocation) / user_macroscopic_pathloss_linear / user_shadow_fading_loss_linear;
            RX_power_half_RB = reshape([RX_power_RB'; RX_power_RB'],1,[])/2;
            
            % Interfering eNodeBs' power allocation
            if there_are_interferers % no interfering eNodeBs present (single eNodeB simulation)
                parent_sites                            = [interfering_eNodeBs.parent_eNodeB];
                parent_sites_id                         = [parent_sites.id];
                interfering_eNodeB_ids                  = [interfering_eNodeBs.eNodeB_id];
                interfering_RB_grids                    = [interfering_eNodeBs.RB_grid];
                interfering_power_allocations_data      = [interfering_RB_grids.power_allocation];
                interfering_power_allocations_signaling = [interfering_RB_grids.power_allocation_signaling];
                
                % Get macroscopic pathloss and shadow fading values
                [interfering_macroscopic_pathloss_eNodeB_dB,interfering_shadow_fading_loss_dB] = obj.get_interfering_macroscale_losses(...
                    interfering_eNodeB_ids,parent_sites_id);
                
                interfering_macroscopic_pathloss_eNodeB_linear = 10.^(0.1*interfering_macroscopic_pathloss_eNodeB_dB);
                interfering_shadow_fading_loss_linear          = 10.^(0.1*interfering_shadow_fading_loss_dB);
                
                % Total power allocations
                interfering_power_allocations = interfering_power_allocations_data + interfering_power_allocations_signaling;
                
                total_RX_Power            = 10*log10(sum(RX_power_RB));
                totalInterfPower          = 10*log10(reshape(sum(interfering_power_allocations,1),[],1))-interfering_macroscopic_pathloss_eNodeB_dB-interfering_shadow_fading_loss_dB;
                [CI_dB_sorted,interfIdxs] = sort(total_RX_Power-totalInterfPower);
                
                % Overwrite variables to take into consideration just the interferers up to 45dB below our signal
                interfererIdxs                                 = CI_dB_sorted<45;
                interfering_eNodeB_ids                         = interfering_eNodeB_ids(interfIdxs(interfererIdxs));
                interfering_macroscopic_pathloss_eNodeB_linear = interfering_macroscopic_pathloss_eNodeB_linear(interfererIdxs);
                interfering_power_allocations                  = interfering_power_allocations(:,interfererIdxs);
                interfering_eNodeBs                            = interfering_eNodeBs(interfererIdxs);
                if ~isscalar(interfering_shadow_fading_loss_linear)
                    % Only if the shadow fading is not a scalar (i.e., there is shadow fading)
                    interfering_shadow_fading_loss_linear = interfering_shadow_fading_loss_linear(interfererIdxs);
                else
                    interfering_shadow_fading_loss_linear = ones(length(interfering_macroscopic_pathloss_eNodeB_linear),1);
                end
                
                power_allocations_interf_sc = reshape([interfering_power_allocations(:)';interfering_power_allocations(:)'],nSC,[])'/2; % Power allocation per half-RB
                
                % Total received interfering power
                RX_power_half_RB_interf = power_allocations_interf_sc ./ kron(interfering_macroscopic_pathloss_eNodeB_linear,ones(1,nSC))./kron(interfering_shadow_fading_loss_linear,ones(1,nSC));
            end
            
            thermal_noise_watts_per_half_RB = obj.thermal_noise_W_RB/2;
            
            % Get the correct precodig matrices
            switch tx_mode
                case 4
                    % CLSM
                    precoding = [obj.codebook{:,nTX,tx_mode}];
                case 3
                    % OLSM
                    error('Not yet supported (3)');
                    precoding = [obj.codebook{:,nRX,tx_mode}];
                case 2
                    % TxD: none
                    error('Not yet supported (2)');
                case 1
                    % Single TX antenna: none
                    error('Not yet supported (1)');
                otherwise
                    error('Not yet supported (other)');
            end
            
            % SINR calculation for each layer possibility
            SINR_linear = nan(max_layer,nSC,max_layer);
            for l_=1:max_layer
                H0_H0_l        = zeros(l_,nSC);
                H_0_eff_inv_l_ = zeros(l_,nTX,nSC);
                precoders_l    = precoding(l_).W;   % All the possible precoders for this layer number choice
                % Obtain the effective channel matrix
                for sc_=1:nSC
                    precoder = precoders_l(:,:,PMI_precalc_sc(sc_,l_));
                    H0_pinv  = pinv(H_0(:,:,sc_)*precoder);
                    H_0_eff_inv_l_(:,:,sc_) = H0_pinv;
                    H0_H0_l(:,sc_)          = diag(H0_pinv*H0_pinv');
                end
                MSE_signal_part = thermal_noise_watts_per_half_RB*H0_H0_l; % ToDo: Add Channel Estimation error
                MSE_interf_part = zeros(l_,nSC,N_interferers);
                if there_are_interferers
                    for int_=1:N_interferers
                        interferer_precoding = precoders_l(:,:,1); % Arbitrary and fixed precoder for the interferers. Could be changed, though
                        for sc_=1:nSC
                            H_i_W_i     = H_i(:,:,sc_,int_)*interferer_precoding;
                            H_i_W_i_2   = H_i_W_i*H_i_W_i';
                            H_0_eff_inv = H_0_eff_inv_l_(:,:,sc_);
                            MSE_interf_part(:,sc_,int_) = diag(RX_power_half_RB_interf(int_,sc_) * H_0_eff_inv * H_i_W_i_2 * H_0_eff_inv');
                        end
                    end
                end
                MSE                    = real(MSE_signal_part + sum(MSE_interf_part,3)); % The remaining imaginary part is just due to type rounding. There is no imaginary part, actually.
                SINR_linear(1:l_,:,l_) = kron(RX_power_half_RB,ones(l_,1)) ./ MSE;
            end
            SINR_dB = 10*log10(SINR_linear);
            
            % Calculate average preequalization SNR: This is a total SNR, the same as in the Link Level Simulator
            obj.SNR_avg_preequal = 10*log10(RX_power_half_RB(1)/thermal_noise_watts_per_half_RB);
            
            % Calculation of the wideband SINR
            if there_are_interferers
                obj.wideband_SINR = 10*log10(sum(RX_power_half_RB) / (sum(RX_power_half_RB_interf(:))+thermal_noise_watts_per_half_RB*nSC));
            else
                obj.wideband_SINR = 10*log10(sum(RX_power_half_RB) / (thermal_noise_watts_per_half_RB*nSC));
            end
            
            % Calculate and save feedback, as well as the measured SINRs
            obj.calculate_feedback(config,tx_mode,SINR_linear,SINR_dB,nRB,PMI_precalc,DL_signaling);
        end
        
        % Calculate the feedback values based on the input. This function
        % is called from the link quality model and is separated for
        % convenience and readability. The results of the feedback
        % calculation are stored in the following variables:
        % - obj.feedback.CQI:              CQI feedback
        % - obj.feedback.RI:               Rank Indicator feedback (when applicable)
        % - obj.link_quality_model_output: SINR values
        %
        % As input parameters you have one SINR per RB
        % (SINRs_to_map_to_CQI) or all of the SINRs the SL simulator
        % traces, which are currently two per RB (SINR_dB)
        function calculate_feedback(obj,config,tx_mode,SINR_linear,SINR_dB,nRB,PMI_suggestion,DL_signaling)
            % Take a subset of the SINRs for feedback calculation
            % For SM we send 2 CQIs, one for each of the codewords (which in the 2x2
            % case are also the layers). For TxD, both layers have the same SINR
            % The CQI is calculated as a linear averaging of the SINRs in
            % dB. This is done because like this the Tx has an "overall
            % idea" of the state of the RB, not just a sample of it.
            switch tx_mode
                case 1 % SISO
                    SINRs_to_map_to_CQI = (SINR_dB(1:2:end)+SINR_dB(2:2:end))/2;
                    obj.link_quality_model_output.SINR_dB     = SINR_dB;
                    obj.link_quality_model_output.SINR_linear = SINR_linear;
                case 2 % TxD
                    % Both layers have the same SINR
                    SINRs_to_map_to_CQI = (SINR_dB(1,1:2:end)+SINR_dB(1,2:2:end))/2;
                    obj.link_quality_model_output.SINR_dB     = SINR_dB(1,:);
                    obj.link_quality_model_output.SINR_linear = SINR_linear(1,:);
                case {3,4} % OLSM, CLSM
                    SINRs_to_map_to_CQI = (SINR_dB(:,1:2:end,:)+SINR_dB(:,2:2:end,:))/2;
                    obj.link_quality_model_output.SINR_dB     = SINR_dB;
                    obj.link_quality_model_output.SINR_linear = SINR_linear;
                otherwise
                    error('TX mode not yet supported');
            end
            
            max_rank   = size(SINRs_to_map_to_CQI,3);
            
            if (tx_mode==3) || (tx_mode==4) % Rank decision for SM
                MCSs_all = 1:15;
                Is_MCSs  = obj.SINR_averager.SINR_to_I(SINRs_to_map_to_CQI,MCSs_all);
                
                if max_rank==1
                    Is_MCSs = reshape(Is_MCSs,[size(Is_MCSs,1) size(Is_MCSs,2) 1 size(Is_MCSs,3)]);
                end
                
                % Compute the per-layer mutual-information sum
                Is_dims                         = size(Is_MCSs);
                Is_MCSs_no_nans                 = zeros(size(Is_MCSs));
                Is_finite_idxs                  = isfinite(Is_MCSs);
                Is_MCSs_no_nans(Is_finite_idxs) = Is_MCSs(Is_finite_idxs);
                Is_sum_MCSs_per_layer           = reshape(sum(Is_MCSs_no_nans,1),Is_dims(2:end));
                
                % Optional: take only the N best values, as measured by the last MCS (if not one would need to calcualte it for every rank-MCS pair, making it too computationally costly!)
                Is_mean_MCSs_per_rank = zeros(length(MCSs_all),max_rank);
                last_MCS_Is_sum       = Is_sum_MCSs_per_layer(:,:,MCSs_all(end));
                
                %% Calculate mean MI value for each rank and MCS pair based on the best N MI values for each rank
                for r_=1:max_rank
                    multiplier_matrix = kron(1:max_rank,ones(length(MCSs_all),1));
                    if obj.adaptive_RI==1 && ~isempty(DL_signaling.adaptive_RI) && ~isempty(DL_signaling.adaptive_RI.avg_MI) && ~isempty(DL_signaling.adaptive_RI.min_MI)
                        % Take only the RBs with similar spectral efficiency as previously scheduled (measured in BICM capacity)
                        spectral_eff_threshold = DL_signaling.adaptive_RI.min_MI;
                        
                        number_of_RBs_to_take   = DL_signaling.num_assigned_RBs;
                        if number_of_RBs_to_take==0
                            number_of_RBs_to_take = nRB;
                        end
                        [sort_values,sort_idxs]    = sort(last_MCS_Is_sum(:,r_));
                        bigger_than_threshold      = sort_values>=spectral_eff_threshold;
                        bigger_than_threshold_idxs = sort_idxs(bigger_than_threshold);
                        begin_idx                  = max(length(bigger_than_threshold_idxs)-number_of_RBs_to_take+1,1);
                        end_idx                    = length(bigger_than_threshold_idxs);
                        RBs_to_average_idx_rank    = bigger_than_threshold_idxs(begin_idx:end_idx);
                        
                        RBs_to_average = Is_sum_MCSs_per_layer(RBs_to_average_idx_rank,r_,:);
                        
                        if isempty(RBs_to_average)
                            RBs_to_average = Is_sum_MCSs_per_layer(:,r_,:); % All values
                        end
                    elseif obj.adaptive_RI==2 && ~isempty(DL_signaling.adaptive_RI) && ~isempty(DL_signaling.adaptive_RI.RBs_for_feedback)
                            RBs_to_average = Is_sum_MCSs_per_layer(DL_signaling.adaptive_RI.RBs_for_feedback,r_,:); % The indicated values
                    else
                        RBs_to_average = Is_sum_MCSs_per_layer(:,r_,:);
                    end
                    
                    Is_mean_MCSs_per_rank(:,r_) = reshape(mean(RBs_to_average,1),[Is_dims(end) 1]) ./ multiplier_matrix(:,r_);
                end
                
                %% Rank Indicator: Decide based on the number of transmitted data bits for a rank value
                SINR_av_dB_for_RI     = obj.SINR_averager.average_for_RI(Is_mean_MCSs_per_rank,1:15);
                CQI_temp_all          = floor(obj.CQI_mapper.SINR_to_CQI(SINR_av_dB_for_RI));
                all_CQIs              = reshape(1:15,[],1);
                all_CQIs              = all_CQIs(:,ones(1,max_rank));
                temp_var              = CQI_temp_all-all_CQIs;
                temp_var(temp_var<0)  = Inf;
                [C, CQI_layer_all]    = min(temp_var);
                out_of_range          = CQI_layer_all<1;
                CQI_layer_all(out_of_range) = 1;
                bits_layer_config = (1:max_rank).*(8*round(1/8*[config.CQI_params(CQI_layer_all).modulation_order] .* [config.CQI_params(CQI_layer_all).coding_rate_x_1024]/1024 * config.sym_per_RB_nosync * config.N_RB*2)-24);
                bits_layer_config(out_of_range) = 0;
                [C,optimium_rank] = max(bits_layer_config); % Choose the RI for which the number of bits is maximized
                
                %% Calculate CQI feedback on a per-codeword basis
                
                % CQI reporting Layer mappings according to TS 36.211
                switch optimium_rank
                    case 1
                        SINRs_to_CQI_CWs = SINRs_to_map_to_CQI(1,:,1);
                    case 2
                        SINRs_to_CQI_CWs = SINRs_to_map_to_CQI(1:2,:,2);
                    case 3
                        % Manually set to two Codewords. Layer-to-codeword mapping according to TS 36.211 and done with the last CQI
                        codeword2_SINRs_dB_avg = obj.SINR_averager.average_codeword(Is_MCSs(2:3,:,optimium_rank,MCSs_all(end)),MCSs_all(end));
                        SINRs_to_CQI_CWs       = [SINRs_to_map_to_CQI(1,:,3); codeword2_SINRs_dB_avg];
                    case 4
                        % Manually set to two Codewords. Layer-to-codeword mapping according to TS 36.211
                        codeword1_SINRs_dB_avg = obj.SINR_averager.average_codeword(Is_MCSs(1:2,:,optimium_rank,MCSs_all(end)),MCSs_all(end));
                        codeword2_SINRs_dB_avg = obj.SINR_averager.average_codeword(Is_MCSs(3:4,:,optimium_rank,MCSs_all(end)),MCSs_all(end));
                        SINRs_to_CQI_CWs       = [codeword1_SINRs_dB_avg; codeword2_SINRs_dB_avg];
                end
                
                obj.feedback.RI  = optimium_rank;
            else
                obj.feedback.RI  = 1;
                SINRs_to_CQI_CWs = SINRs_to_map_to_CQI; % I have to cehck whether this also holds for TxD because of the matrix dimensions
            end
            
            if tx_mode==4 && ~isempty(PMI_suggestion)
                obj.feedback.PMI = PMI_suggestion(:,optimium_rank);
            else
                obj.feedback.PMI = nan(nRB,1);
            end
            
            % Send as feedback the CQI for each RB.
            % Flooring the CQI provides much better results than
            % rounding it, as by rounding it to a higher CQI you will
            % very easily jump the BLER to 1. The other way around it
            % will jump to 0.
            if obj.unquantized_CQI_feedback
                CQIs = obj.CQI_mapper.SINR_to_CQI(SINRs_to_CQI_CWs);
            else
                CQIs = floor(obj.CQI_mapper.SINR_to_CQI(SINRs_to_CQI_CWs));
            end
            
            obj.feedback.CQI = CQIs;
            obj.feedback.tx_mode = tx_mode;
        end
        
        % Evaluate whether this TB arrived correctly by using the data from
        % the link quality model and feeding it to the link performance
        % model (BLER curves)
        function link_performance_model(obj)
            
            % Get RB grid
            % the_RB_grid   = obj.RB_grid;
            
            % Get SINRs from the link quality model. Only the dB (not
            % linear) are needed.
            SINR_dB       = obj.link_quality_model_output.SINR_dB;
                      
            % Calculate TB SINR
            [...
               TB_CQI,...
               user_RBs,...
               assigned_RBs,...
               assigned_power,...
               tx_mode,...
               nLayers,...
               nCodewords,...
               rv_idxs,...
               TB_size,...
               N_used_bits,...
               packet_parts...
               ] = obj.eNodeB_signaling.get_TB_params;
            
            % Preallocate variables to store in trace
            TB_SINR_dB = zeros(1,nCodewords);
            BLER       = zeros(1,nCodewords);
            
            % NOTE: This needs to be changed into a per-layer SINR. A layer-to-stream translation will be needed
            UE_TB_SINR_idxs = reshape([user_RBs';user_RBs'],1,[]);
            
            % Setting this "Kronecker product" to [1 0] would mean that you only take one SC per RB and repeat it. i.e. not use all of
            % your SCs in the trace.

            % Set feedback for all streams
            if assigned_RBs~=0
                % Not all of the dimensions are needed
                switch tx_mode
                    case {1,2}
                        % SIXO, TxD
                    case {3,4}
                        % OLSM, CLSM
                        
                        % Take only the SINRs of the layers that are needed
                        SINR_dB = SINR_dB(1:nLayers,:,nLayers);
                        
                        % Layer mapping
                        % NOTHING (for now) -> 2 TX antennas does not yet need a proper mapping
                        % Convert the shape of the SINR_dB vector, as well
                        % as the mapping
                    otherwise
                        error('Mode not supported');
                end
                
                % Layer mapping according to TS 36.212
                for cw_=1:nCodewords
                    switch cw_
                        case 1
                            switch nLayers
                                case 4
                                    layers_cw = [1 2];
                                otherwise
                                    layers_cw = 1;
                            end
                        case 2
                            switch nLayers
                                case 1
                                    error('2 codewords and 1 layers not allowed');
                                case 2
                                    layers_cw = 2;
                                case 3
                                    layers_cw = [2 3];
                                case 4
                                    layers_cw = [3 4];
                            end
                    end
                    layer_SINRs            = SINR_dB(layers_cw,:);
                    UE_TB_SINR_idxs_layers = UE_TB_SINR_idxs(ones(length(layers_cw),1),:);
                    UE_TB_SINRs_layer      = layer_SINRs(UE_TB_SINR_idxs_layers);
                    [TB_SINR_dB(cw_)]      = obj.SINR_averager.average(UE_TB_SINRs_layer,TB_CQI(cw_),true);
                    BLER(cw_)              = obj.BLER_curves.get_BLER(TB_CQI(cw_),TB_SINR_dB(cw_));
                end
                
                % Receive
                ACK     = BLER<rand(1,nCodewords);
            else
                % Dummy results
                TB_SINR_dB = [];
                ACK        = false(1,nCodewords);
            end
            
            % Needed for non-full-buffer simulations
            if ~obj.traffic_model.is_fullbuffer
                obj.process_packet_parts(packet_parts,nCodewords);
            end
                      
            % Add BLER/ACK feedback to the CQI and RI feedback
            if assigned_RBs~=0
                obj.feedback.UE_scheduled = true;
                obj.feedback.nCodewords   = nCodewords;
                obj.feedback.TB_size      = TB_size;
                obj.feedback.BLER         = BLER;
                obj.feedback.ACK          = ACK;
            else
                obj.feedback.UE_scheduled = false;
                obj.feedback.nCodewords   = 0;
                obj.feedback.TB_size      = 0;
                obj.feedback.BLER         = NaN;
                obj.feedback.ACK          = false;
            end
            
            % Optional traces
            if obj.trace_SINR
                extra_traces{1} = obj.link_quality_model_output.SINR_dB;
            else
                extra_traces{1} = [];
            end
            
            % Store trace of the relevant information
            tti_idx = obj.clock.current_TTI;
            
            % Store trace
            obj.trace.store(...
                obj.feedback,...
                obj.attached_eNodeB,...
                obj.pos,...
                tti_idx,...
                assigned_RBs,...
                assigned_power,...
                TB_CQI,...
                TB_size,...
                BLER,...
                TB_SINR_dB,...
                N_used_bits,...
                obj.wideband_SINR,...
                obj.deactivate_UE,...
                obj.SNR_avg_preequal,...
                obj.rx_power_tb_in_current_tti,...
                obj.rx_power_interferers_in_current_tti,...
                extra_traces);
        end
        
        % Dummy functions
        function dummy_link_quality_model(obj,config)
            obj.SNR_avg_preequal      = NaN;
            obj.wideband_SINR         = NaN;
            obj.feedback.CQI          = zeros(1,config.N_RB);
            obj.feedback.PMI          = ones(1,config.N_RB);
            obj.feedback.RI           = 1;
            obj.feedback.tx_mode      = 4;
            obj.feedback.UE_scheduled = false;
            obj.feedback.nCodewords   = 1;
            obj.feedback.TB_size      = 0;
            obj.feedback.BLER         = 0;
            obj.feedback.ACK          = false;
        end
        
        function dummy_link_performance_model(obj)           
            % Store trace of the relevant information
            tti_idx = obj.clock.current_TTI;
            
            % Store trace
            extra_traces{1} = [];
            extra_traces{2} = [];
            obj.trace.store(...
                obj.feedback,...
                obj.attached_eNodeB,...
                obj.pos,...
                tti_idx,...
                0,...
                0,...
                0,...
                0,...
                0,...
                NaN,...
                0,...
                obj.wideband_SINR,...
                obj.deactivate_UE,...
                NaN,...
                0,...
                0,...
                extra_traces);
        end
        
        function distance_to_site = distance_to_attached_site(obj)
            % Return the distance to the attached site (function added for convenience)
            distance_to_site = sqrt(sum((obj.attached_site.pos -obj.pos).^2));
        end
        
        % Clear all non-basic info and leaves just basic information describing the UE
        function clear_non_basic_info(obj)
            obj.walking_model             = [];
            obj.downlink_channel          = [];
            obj.RB_grid                   = [];
            obj.uplink_channel            = [];
            obj.trace                     = [];
            obj.clock                     = [];
            obj.CQI_mapper                = [];
            obj.link_quality_model_output = [];
            obj.feedback                  = [];
            obj.unquantized_CQI_feedback  = [];
            obj.BLER_curves               = [];
            obj.SINR_averager             = [];
            obj.codebook                  = [];
            obj.eNodeB_signaling          = [];
            obj.trace_SINR                = [];
            obj.SNR_avg_preequal          = [];
            obj.wideband_SINR             = [];
            obj.deactivate_UE             = [];
            obj.default_tx_mode           = [];
            obj.traffic_model             = [];
            obj.lambda                    = [];
        end
        
        % Returns a struct containing the basic information (not deleted with the previous function) from the UE
        function struct_out = basic_information_in_struct(obj)
            struct_out.id                    = obj.id;
            struct_out.pos                   = obj.pos;
            if ~isempty(obj.attached_site)
                struct_out.attached_site = obj.attached_site.basic_information_in_struct();
            else
                struct_out.attached_site = [];
            end
            struct_out.attached_sector_idx   = obj.attached_sector_idx;
            if ~isempty(obj.attached_eNodeB)
                struct_out.attached_eNodeB = obj.attached_eNodeB.basic_information_in_struct();
            else
                struct_out.attached_eNodeB = [];
            end
            struct_out.receiver_noise_figure = obj.receiver_noise_figure;
            struct_out.thermal_noise_W_RB    = obj.thermal_noise_W_RB;
            struct_out.penetration_loss      = obj.penetration_loss;
            struct_out.nRX                   = obj.nRX;
            struct_out.antenna_gain          = obj.antenna_gain;
        end
        
        % Processes tha packet parts
        function process_packet_parts(obj,packet_parts,nCodewords)
            for cw_ = 1:nCodewords
                if ACK(cw_)
                    if strcmp(obj.traffic_model.type,'voip') || strcmp(obj.traffic_model.type,'video') || strcmp(obj.traffic_model.type,'gaming')
                        for pp = 1:length(packet_parts{cw_}) % acknowledge all packet parts and remove them from the buffer
                            if packet_parts{cw_}(pp).data_packet_id
                                packet_ind = obj.traffic_model.get_packet_ids == packet_parts{cw_}(pp).data_packet_id;
                                if sum(packet_ind)
                                    [packet_done,packet_id] = obj.traffic_model.packet_buffer(packet_ind).acknowledge_packet_part(packet_parts{cw_}(pp).id,true);
                                    if packet_done && packet_id
                                        obj.traffic_model.remove_packet(packet_id,true);
                                    end
                                end
                            end
                        end
                    end
                else
                    %% NOTE: activate me if HARQ exists
                    %                     if strcmp(obj.traffic_model.type,'voip') || strcmp(obj.traffic_model.type,'video') || strcmp(obj.traffic_model.type,'gaming')
                    %                         if current_rv_idx == max_rv_idx % if maximum of retransmissions is obtained --> delete the packet parts
                    %                             for pp = 1:length(packet_parts{cw_})
                    %                                 if packet_parts{cw_}(pp).data_packet_id
                    %                                     packet_ind = obj.traffic_model.get_packet_ids == packet_parts{cw_}(pp).data_packet_id;
                    %                                     if sum(packet_ind)
                    %                                         [packet_done,packet_id] = obj.traffic_model.packet_buffer(packet_ind).acknowledge_packet_part(packet_parts{cw_}(pp).id,false); % with the option "false" (last argument) the packet is deleted
                    %                                         if packet_done && packet_id
                    %                                             obj.traffic_model.remove_packet(packet_id,false); % with the option false, the packet is marked as non-successfully transmitted
                    %                                         end
                    %                                     end
                    %                                 end
                    %                             end
                    %                         else % else restore them for retransmission
                    %                             for pp = 1:length(packet_parts{cw_})
                    %                                 if packet_parts{cw_}(pp).data_packet_id
                    %                                     packet_ind = obj.traffic_model.get_packet_ids == packet_parts{cw_}(pp).data_packet_id;
                    %                                     if sum(packet_ind)
                    %                                         obj.traffic_model.packet_buffer(packet_ind).restore_packet_part(packet_parts{cw_}(pp).id);
                    %                                     end
                    %                                 end
                    %                             end
                    %                         end
                    %                     end
                end
            end
        end
    end
end
