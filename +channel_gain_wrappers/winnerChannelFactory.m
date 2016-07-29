classdef winnerChannelFactory < channel_gain_wrappers.channelFactory
    % Wraps the functions needed to generate Winner+ channel traces.
    % (c) Josep Colom Ikuno, Michal Simko, INTHFT, 2011
    
    properties
        cache_folder          = './data_files/channel_traces';
        winner_params         = [];
        winner_antenna_params = [];
        winner_antenna_array  = [];
        
        % This variable allows for the Winner channel model to be called
        % subsequent times, each time generating this number of channel
        % realizations. This eases the memory requirements, but as I found
        % out, does not work well due to some channel normalizuations done
        % inside the Winner code which I am not completely sure of.
        number_of_realizations_per_loop = Inf;
    end
    
    methods (Static)
        function winner_params = get_default_config(carrier_freq,nTX,nRX,speed)
            winner_params.filtering              = 'BlockFading';
            winner_params.nUE                    = 1;
            winner_params.speed_of_light         = 299792458;
            winner_params.carrier_freq           = carrier_freq; % in Hz
            winner_params.BS_config.nTx          = nTX;
            winner_params.UE_config.nRX          = nRX;
            winner_params.speed                  = speed;      % m/s
            winner_params.Scenario               = 12;         % 1=A1, 2=A2, 3=B1, 4=B2, 5=B3, 6=B4, 7=B5a, 8=B5c, 9=B5f, 10=C1, 11=C2, 12=C3, 13=C4, 14=D1 and 15=D2a
            winner_params.PropagCondition        = 'NLOS';     % [LOS,{NLOS}]
            winner_params.SampleDensity          = 2;          % number of time samples per half wavelength [ {2} ]
            winner_params.UniformTimeSampling    = 'yes';      % Use same time sampling grid for all links [ yes | {no} ]
            winner_params.FixedPdpUsed           = 'no';       % nonrandom path delays and powers [ yes | {no}]
            winner_params.FixedAnglesUsed        = 'no';       % nonrandom AoD/AoAs [ yes | {no} ]
            winner_params.PolarisedArrays        = 'yes';      % usage of dual polarised arrays [ {yes} | no ]
            winner_params.TimeEvolution          = 'no';       % usage of time evolution  [ yes | {no} ]
            winner_params.PathLossModelUsed      = 'no';       % usage of path loss model [ yes | {no} ]
            winner_params.ShadowingModelUsed     = 'no';       % usage of shadow fading model [ yes | {no} ]
            winner_params.PathLossModel          = 'pathloss'; % path loss model function name [ {pathloss} ]
            winner_params.PathLossOption         = 'CR_light'; % ['{CR_light}' or 'CR_heavy' or 'RR_light' or 'RR_heavy', CR = Corridor-Room, RR = Room-Room nlos}
            winner_params.RandomSeed             = [];         % sets random seed [ {[empty]} ]
            winner_params.UseManualPropCondition = 'yes';      % whether to use manual propagation condition (los/nlos) setting or not. If not, the propagation condition is drawn from probabilities.  [ {yes} | no]
            winner_params.final_normalization    = true;       % Whether to perform a normalization to 1 before outputting the channel trace
            % Note: winner_params.SamplingTime is calculated in the class constructors as Tb/Nfft;
        end
        
        function found = prepare_winner_channel_model_path(winner_model_path)
            %% Check and/or add Winner Model code path
            if ~exist(fullfile(winner_model_path,'dipole.m'),'file')
                error('Please download the Winner+ II channel model from http://projects.celtic-initiative.org/winner+/phase_2_model.html and extract it into the "%s" folder',winner_model_path);
                web http://projects.celtic-initiative.org/winner+/phase_2_model.html
            else
                % Add Winner Model code path
                path(path,winner_model_path);
            end
        end
    end
    
    methods
        function obj = winnerChannelFactory(bandwidth,winner_params,varargin)
            % Call superclass constructor
            obj = obj@channel_gain_wrappers.channelFactory(bandwidth);
            
            if ~isempty(varargin)
                winner_antenna_params = varargin{1};
            else
                winner_antenna_params = [];
            end
            
            % Calculate sampling time
            winner_params.SamplingTime = obj.Tb/obj.Nfft;
            winner_params.Tsubframe    = obj.tSubframe;
            
            % This is needed in order to apply the same normalization to
            % all loop iterations. The first iterations is used to measure.
            % Further iterations will use the value stored here
            winner_params.normalization_factor = [];
            
            % Winner channel parameters
            obj.winner_params         = winner_params;
            obj.winner_antenna_params = winner_antenna_params;
        end
        function winner_antenna_array = load_antenna_array(obj,varargin)
            winner_params = obj.winner_params;
            
            % Option of using the cache or not
            if isempty(varargin)
                force_recalculate = false;
            else
                force_recalculate = varargin{1};
            end
            
            cache_filename = obj.generate_cache_filename;
            fullfile_cache = fullfile(obj.cache_folder,cache_filename);
            
            if ~exist(fullfile_cache,'file') || force_recalculate
                % Generate antenna array
                fprintf('Calculating winner antenna array cache: %s\n',fullfile_cache);
                winner_antenna_array = obj.generate_winner_channel_model_antenna_array;
                % Save file
                fprintf('Saving winner antenna array cache: %s\n',fullfile_cache);
                save_array = true;
            else
                % Load filename
                loaded_data = load(fullfile_cache);
                % Check loaded file
                data_correct = true;
                if winner_params.speed_of_light ~= loaded_data.winner_params.speed_of_light
                    data_correct = false;
                    fprintf('"speed_of_light" variable is not equal for loaded file and winner parameters. Generating file again\n');
                end
                if winner_params.carrier_freq ~= loaded_data.winner_params.carrier_freq
                    data_correct = false;
                    fprintf('"carrier_freq" variable is not equal for loaded file and winner parameters. Generating file again\n');
                end
                if winner_params.BS_config.nTx ~= loaded_data.winner_params.BS_config.nTx
                    data_correct = false;
                    fprintf('"nTx" variable is not equal for loaded file and winner parameters. Generating file again\n');
                end
                if winner_params.UE_config.nRX ~= loaded_data.winner_params.UE_config.nRX
                    data_correct = false;
                    fprintf('"nRx" variable is not equal for loaded file and winner parameters. Generating file again\n');
                end
                % Regenerate if necessary
                if data_correct
                    fprintf('Reading winner antenna array cache: %s\n',fullfile_cache);
                    winner_antenna_array = loaded_data.winner_antenna_array;
                    save_array = false;
                else
                    fprintf('Re-calculating winner antenna array cache: %s\n',fullfile_cache);
                    winner_antenna_array = obj.generate_winner_channel_model_antenna_array;
                    fprintf('Saving winner antenna array cache: %s\n',fullfile_cache);
                    save_array = true;
                end
            end
            
            if save_array
                try
                    if exist(fullfile_cache,'file')
                        throw(MException('LTEsim:cacheExists', 'The cache file was concurrently generated during another simulation run'));
                    end
                    save(fullfile_cache,'winner_antenna_array','winner_params');
                catch err
                    fprintf('Winner antenna array could not be saved. If needed, it will be generated again in the next run (%s).\n',err.message);
                end
            end
            
            % Setup the winner object
            obj.winner_antenna_array = winner_antenna_array;
        end
        
        function cache_filename = generate_cache_filename(obj)
            if ~isempty(obj.winner_antenna_params)
                hash_string = ['_' utils.hashing.DataHash(obj.winner_antenna_params)];
            else
                hash_string = [];
            end
            
            % Generate the name of the cache file according to the input
            % params
            if obj.winner_params.carrier_freq >= 1e9
                freq_string = sprintf('%4.2fGHz',obj.winner_params.carrier_freq/1e9);
            else
                freq_string = sprintf('%3.0fMHz',obj.winner_params.carrier_freq/1e6);
            end
            cache_filename = sprintf('winer_array_%dx%d_%s%s.mat',obj.winner_params.BS_config.nTx,obj.winner_params.UE_config.nRX,freq_string,hash_string);
        end
        
        function Arrays = generate_winner_channel_model_antenna_array(obj)
            % LTE winner channel model - to generate channel realization using Winner
            % Model II [1]
            %
            % Author: Michal Simko, msimko@nt.tuwien.ac.at
            % (c) by INTHFT
            % www.nt.tuwien.ac.at
            %
            % [1]   IST-WINNER D1.1.2 P. Kyösti, et al., "WINNER II Channel Models", ver 1.1, Sept. 2007.
            %       Available: https://www.ist-winner.org/WINNER2-Deliverables/D1.1.2v1.1.pdf
            % [2]   TSG-RAN Working Group 4 (Radio) meeting #38 R4-060334
            %
            % input :
            % output:   Arrays                      ... struct antenna specification using Winner II channel model
            %
            % date of creation: 2009/10/13
            % last changes: 2009/10/13  Simko
            
            LTE_params = obj.winner_params;
            
            %% Base Station antennas
            
            % NAz=3*120; %3 degree sampling interval
            % Az=linspace(-180,180-1/NAz,NAz);
            % pattern=ones(2,2,1,NAz);
            % dist = 3e8/5.25e9*0.5;
            % BSArrays(1)=AntennaArray('ULA',1,dist,'FP-ECS',pattern); % isotropic antenna
            % BSArrays(2)=AntennaArray('ULA',2,dist,'FP-ECS',pattern); % isotropic antenna
            % BSArrays(3)=AntennaArray('ULA',3,dist,'FP-ECS',pattern); % isotropic antenna
            % BSArrays(4)=AntennaArray('ULA',4,dist,'FP-ECS',pattern); % isotropic antenna
            
            NAz=3*120; %3 degree sampling interval
            Az=linspace(-180,180-1/NAz,NAz);
            lambda = LTE_params.speed_of_light/LTE_params.carrier_freq;
            
            % Overridable antenna parameters
            if ~isempty(obj.winner_antenna_params)
                TX_pol        = obj.winner_antenna_params.TX_antenna_polarization;
                TX_pos_lambda = obj.winner_antenna_params.TX_antenna_position_in_lambdas;
                RX_pol        = obj.winner_antenna_params.RX_antenna_polarization;
                RX_pos_lambda = obj.winner_antenna_params.RX_antenna_position_in_lambdas;
            else
                switch LTE_params.BS_config.nTx
                    case 1
                        TX_pol        = 0;
                        TX_pos_lambda = 1;
                    case 2
                        TX_pol        = [45 -45];
                        TX_pos_lambda = [0 0];
                    case 4
                        TX_pol        = [45 -45 45 -45];
                        TX_pos_lambda = [-1 -1 1 1];
                end
                switch LTE_params.UE_config.nRX
                    case 1
                        RX_pol        = 12; % slanted by 12 degree
                        RX_pos_lambda = 1;
                    case 2
                        RX_pol        = [45 -45];
                        RX_pos_lambda = [0 0];
                    case 4
                        RX_pol        = [0 90 0 90];
                        RX_pos_lambda = [-1 -1 1 1];
                end
            end
            
            % Create the antenna array
            switch LTE_params.BS_config.nTx
                case 1
                    pattern(1,:,1,:) = dipole(Az,TX_pol);
                    BsArrays         = AntennaArray('ULA',1,TX_pos_lambda*lambda,'FP-ECS',pattern,'Azimuth',Az);
                case 2
                    Position         = [TX_pos_lambda(1)*lambda 0 0; TX_pos_lambda(2)*lambda 0 0];
                    Rotation         = [0 0 -8;0 0 -8];
                    pattern          = zeros(2,2,1,length(Az));
                    pattern(1,:,1,:) = dipole(Az,TX_pol(1));
                    pattern(2,:,1,:) = dipole(Az,TX_pol(2));
                    BsArrays         = AntennaArray('Pos',Position,'Rot',Rotation,'FP-ECS',pattern);
                case 3
                    error('3 TX antenna configuration not defined.'); % Not defined
                case 4
                    Position         = [TX_pos_lambda(1)*lambda 0 0;TX_pos_lambda(2)*lambda 0 0;TX_pos_lambda(3)*lambda 0 0;TX_pos_lambda(4)*lambda 0 0];
                    Rotation         = zeros(4,3);
                    pattern          = zeros(4,2,1,length(Az));
                    pattern(1,:,1,:) = dipole(Az,TX_pol(1));
                    pattern(2,:,1,:) = dipole(Az,TX_pol(2));
                    pattern(3,:,1,:) = dipole(Az,TX_pol(3));
                    pattern(4,:,1,:) = dipole(Az,TX_pol(4));
                    BsArrays         = AntennaArray('Pos',Position,'Rot',Rotation,'FP-ECS',pattern);
                otherwise
                    error('Invalid number of transmit antennas');
            end
            
            %% User antennas
            
            NAz=120; %3 degree sampling interval
            Az=linspace(-180,180-1/NAz,NAz);
            switch LTE_params.UE_config.nRX
                case 1
                    pattern          = zeros(1,2,1,length(Az));
                    pattern(1,:,1,:) = dipole(Az,RX_pol);
                    UserArrays       = AntennaArray('ULA',1,0.01,'FP-ECS',pattern,'Azimuth',Az); %ULA-1 1cm spacing
                case 2
                    % cross-dipole with vertical and horizaontal polarized elements in Talk position [2]
                    switch LTE_params.BS_config.nTx
                        case 1
                            Position = [ 0 0 0; 0 0 0 ];
                        otherwise
                            Position = [ TX_pos_lambda(1)*lambda 0 0; TX_pos_lambda(2)*lambda 0 0 ];
                    end
                    Rotation         = [ 0 0 -45; 0 0 -45 ];
                    pattern          = zeros(2,2,1,length(Az));
                    switch LTE_params.BS_config.nTx
                        case 1
                            pattern(1,:,1,:) = dipole(Az,45);
                            pattern(2,:,1,:) = dipole(Az,-45);
                        otherwise
                            pattern(1,:,1,:) = dipole(Az,TX_pol(1));
                            pattern(2,:,1,:) = dipole(Az,TX_pol(2));
                    end
                    UserArrays       = AntennaArray('Pos',Position,'Rot',Rotation,'FP-ECS',pattern,'Azimuth',Az);
                case 3
                    pattern          = zeros(1,2,1,length(Az));
                    pattern(1,:,1,:) =dipole(Az,12); % slanted by 12 degree
                    UserArrays       = AntennaArray('ULA',3,0.01,'FP-ECS',pattern,'Azimuth',Az); %ULA-3 1cm spacing
                case 4
                    % doble cross-dipole with vertical and horizaontal polarized elements in Talk position [2]
                    Position         = [ RX_pos_lambda(1) 0 0; RX_pos_lambda(2) 0 0; RX_pos_lambda(3) 0 0; RX_pos_lambda(4) 0 0 ];
                    Rotation         = zeros(4,3);
                    pattern          = zeros(4,2,1,length(Az));
                    pattern(1,:,1,:) = dipole(Az,TX_pol(1));
                    pattern(2,:,1,:) = dipole(Az,TX_pol(2));
                    pattern(3,:,1,:) = dipole(Az,TX_pol(3));
                    pattern(4,:,1,:) = dipole(Az,TX_pol(4));
                    UserArrays       = AntennaArray('Pos',Position,'Rot',Rotation,'FP-ECS',pattern,'Azimuth',Az);
                otherwise
                    error('Invalid number ot receive antennas');
            end
            
            Arrays = [UserArrays,BsArrays];
        end
        
        function [channel_out, delays, out, normalization_factor] = generate_channel_trace(obj,N_subframes,varargin)
            % LTE winner channel model - to generate channel realization using Winner
            % Model II [1]
            %
            % Author: Michal Simko, msimko@nt.tuwien.ac.at
            % Modified by Josep Colom Ikuno, jcolom@nt.tuwien.ac.at
            % (c) 2011 by INTHFT
            % www.nt.tuwien.ac.at
            %
            % [1]   IST-WINNER D1.1.2 P. Kyösti, et al., "WINNER II Channel Models", ver 1.1, Sept. 2007.
            %       Available: https://www.ist-winner.org/WINNER2-Deliverables/D1.1.2v1.1.pdf
            %
            % input :   N_subframes                 ... [1x1]   number of channel realization
            %           Arrays                      ... struct  -> antenna specification
            %           out                         ... struct  -> state of previous channel generation using winner model
            % output:   channel                     ... [ x ] channel matrix
            %           delays                      ... [ x ] delays matrix
            %           out                         ... struct  -> output state of the winner model
            %
            % date of creation: 2009/10/12
            % last changes: 2008/12/12  Simko
            
            init_params = obj.winner_params;
            
            if isempty(obj.winner_antenna_array)
                error('Winner channel model antenna array not initialized. Call first the load_antenna_array function.');
            else
                Arrays =  obj.winner_antenna_array;
            end
            final_normalization = init_params.final_normalization;
            
            %% winner II channel model
            
            % set parameters {default option}
            wimpar=wimparset;
            wimpar.Scenario                 = ScenarioMapping(init_params.Scenario);
            wimpar.PropagCondition          = init_params.PropagCondition;                % [LOS,{NLOS}]
            switch init_params.filtering
                case 'BlockFading'
                    Channel_Sampling_Time = init_params.Tsubframe;
                case 'FastFading'
                    Channel_Sampling_Time = init_params.SamplingTime;
            end
            SampleDensity = init_params.speed_of_light/(2*init_params.carrier_freq*Channel_Sampling_Time*init_params.speed);
            
            wimpar.SampleDensity           = SampleDensity;                      % number of time samples per half wavelength [ {2} ]
            wimpar.NumTimeSamples          = N_subframes;                        % number of time samples [ {100} ]
            wimpar.UniformTimeSampling     = init_params.UniformTimeSampling;    % Use same time sampling grid for all links [ yes | {no} ]
            wimpar.FixedPdpUsed            = init_params.FixedPdpUsed;           % nonrandom path delays and powers [ yes | {no}]
            wimpar.FixedAnglesUsed         = init_params.FixedAnglesUsed;        % nonrandom AoD/AoAs [ yes | {no} ]
            wimpar.PolarisedArrays         = init_params.PolarisedArrays;        % usage of dual polarised arrays [ {yes} | no ]
            wimpar.TimeEvolution           = init_params.TimeEvolution;          % usage of time evolution  [ yes | {no} ]
            wimpar.CenterFrequency         = init_params.carrier_freq;           % carrier frequency in Herz [ {5.25e9} ]
            wimpar.DelaySamplingInterval   = init_params.SamplingTime;           % delay sampling grid [ {5e-9} ]init_params.SamplingTime
            wimpar.PathLossModelUsed       = init_params.PathLossModelUsed;      % usage of path loss model [ yes | {no} ]
            wimpar.ShadowingModelUsed      = init_params.ShadowingModelUsed;     % usage of shadow fading model [ yes | {no} ]
            wimpar.PathLossModel           = init_params.PathLossModel;          % path loss model function name [ {pathloss} ]
            wimpar.PathLossOption          = init_params.PathLossOption;         % ['{CR_light}' or 'CR_heavy' or 'RR_light' or 'RR_heavy', CR = Corridor-Room, RR = Room-Room nlos}
            wimpar.RandomSeed              = init_params.RandomSeed;             % sets random seed [ {[empty]} ]
            wimpar.UseManualPropCondition  = init_params.UseManualPropCondition; % whether to use manual propagation condition (los/nlos) setting or not. If not, the propagation condition is drawn from probabilities.  [ {yes} | no]
            
            
            % MsAAIdx = init_params.UE_config.nRX * ones(1,init_params.nUE);
            % BsAAIdxCell = {[init_params.BS_config.nTx + 4]};
            MsAAIdx = ones(1,init_params.nUE);   %every user is using antenna defined Arrays(1)
            BsAAIdxCell = {[2]};    %   base station is using antenna defined Arrays(2)
            
            layoutpar=layoutparset(MsAAIdx,BsAAIdxCell,init_params.nUE,Arrays);
            
            layoutpar.ScenarioVector = init_params.Scenario*ones(1,init_params.nUE); % 1=A1, 2=A2, 3=B1, 4=B2, 5=B3, 6=B4, 7=B5a, 8=B5c, 9=B5f, 10=C1,
            % 11=C2, 12=C3, 13=C4, 14=D1 and 15=D2a
            % for more details look in  ScenarioMapping.mat
            switch init_params.PropagCondition
                case 'LOS'
                    layoutpar.PropagConditionVector =1*ones(1,init_params.nUE);  %   (NLOS=0/LOS=1)
                case 'NLOS'
                    layoutpar.PropagConditionVector =0*ones(1,init_params.nUE);  %   (NLOS=0/LOS=1)
            end
            for uu = 1:init_params.nUE
                layoutpar.Stations(1,uu+1).Velocity = [init_params.speed;0;0];
            end
            
            optargin = size(varargin,2);
            if optargin==1
                out = varargin{1};
                [channel, delays, out] = wim(wimpar,layoutpar,out);
            elseif optargin==0
                [channel, delays, out] = wim(wimpar,layoutpar);
            else
                error('Wrong number of input variables');
            end
            delays = round(delays/init_params.SamplingTime);             %   correct sampling in the delay domain
            
            % Set normalization factor
            normalization_factor_exists = ~isempty(init_params.normalization_factor);
            if final_normalization && normalization_factor_exists;
                normalization_factor = init_params.normalization_factor;
            else
                normalization_factor = ones(1,init_params.nUE);
            end
            % Initialize output
            channel_out = cell(1,init_params.nUE);
            
            % Final procedures
            for user_i = 1:init_params.nUE
                channel{user_i}(isnan(channel{user_i})) = 0;
                channel_matrix_size = size(channel{user_i});
                channel_matrix_size(3) = max(delays(user_i,:))+1;
                channel_out{user_i} = zeros(channel_matrix_size);
                
                for tap_i = 1:channel_matrix_size(3)
                    tap_positions = find(delays(user_i,:) == tap_i-1);
                    if sum(tap_positions)>0
                        channel_out{user_i}(:,:,tap_i,:) = sum(channel{user_i}(:,:,tap_positions,:),3);
                    end
                end
                
                % Channel normalization
                if final_normalization
                    if ~normalization_factor_exists
                        channel_energy = mean(sum(sum(sum(abs(channel_out{user_i}).^2,3),2),1),4); % mean channel energy = sum over transmit and receive antennas and over taps energies averaged over all realizations
                        normalization_factor(user_i) = sqrt(init_params.UE_config.nRX * init_params.BS_config.nTx) / sqrt(channel_energy);
                        obj.winner_params.normalization_factor = normalization_factor;
                    end
                    channel_out{user_i} = normalization_factor(user_i) * channel_out{user_i}; % channel is normalized to have mean energy Nt*Nr
                else
                    % Do nothing (no normalization)
                end
                
                % Since the old channel trace has the last two dimensions
                % ordered as time,taps, instead of the taps,time which is used
                % here, we need to perform a permutation.
                channel_out{user_i} = permute(channel_out{user_i},[1 2 4 3]);
            end
            
            % Since we are only generating the trace for one user, we do
            % not need the output to be a cell array
            channel_out = channel_out{1};
            normalization_factor = normalization_factor(1);
        end
        
        function pregen_H_trace = generate_FF_trace(obj,N_subframes)
            % Shorthand naming
            nRX = obj.winner_params.UE_config.nRX;
            nTX = obj.winner_params.BS_config.nTx;
            
            %% Separate the N_subframes in smaller chunks to avoid memory problems
            % Read the comment under the 'number_of_realizations_per_loop'
            % object attribute to know more about this segmentation code
            % (which is actually not used)
            if isfinite(obj.number_of_realizations_per_loop)
                sim_segmentation = obj.number_of_realizations_per_loop*ones(1,floor(N_subframes/obj.number_of_realizations_per_loop));
                remanent = rem(N_subframes,obj.number_of_realizations_per_loop);
                if remanent > 0
                    sim_segmentation = [sim_segmentation remanent];
                end
                number_of_loops = length(sim_segmentation);
                begin_pos = zeros(size(sim_segmentation));
                end_pos   = begin_pos;
                begin_pos(1) = 1;
                end_pos(1)   = sim_segmentation(1);
                for i_=2:number_of_loops
                    begin_pos(i_) = end_pos(i_-1)+1;
                    end_pos(i_)   = end_pos(i_-1)+sim_segmentation(i_);
                end
            else
                number_of_loops  = 1;
                sim_segmentation = N_subframes;
                begin_pos        = 1;
                end_pos          = N_subframes;
            end
            
            %% Create output, where the pregenerated fast fading will be stored
            pregen_H_trace.channel_model_name = 'Winner+';
            pregen_H_trace.fs                 = obj.fs;
            pregen_H_trace.H_RB_samples       = zeros(nRX,nTX,N_subframes,obj.Ntot/obj.FFT_sampling_interval);
            pregen_H_trace.fft_points         = obj.Nfft;
            pregen_H_trace.t_start            = 0;
            pregen_H_trace.t_end              = (N_subframes-1)*obj.tSubframe;
            pregen_H_trace.t_step             = obj.tSubframe;
            pregen_H_trace.t_length           = N_subframes;
            pregen_H_trace.UE_speed           = obj.winner_params.speed;
            
            obj.load_antenna_array;
            
            for i_=1:number_of_loops
                if i_==1
                    [channel, delays, out, normalization_factor] = obj.generate_channel_trace(sim_segmentation(i_));
                else
                    [channel, delays, out, normalization_factor] = obj.generate_channel_trace(sim_segmentation(i_),out);
                end
                samples = begin_pos(i_):end_pos(i_);
                pregen_H_trace.H_RB_samples(:,:,samples,:) = obj.get_RB_trace(channel);
            end
        end
    end
    
end

