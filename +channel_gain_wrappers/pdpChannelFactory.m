classdef pdpChannelFactory < channel_gain_wrappers.channelFactory
    % Wraps the functions needed to generate PDP-based channel traces.
    % (c) Josep Colom Ikuno, Michal Simko, INTHFT, 2011
    
    properties
        fading_config_params = [];
        rosa_zheng_params    = [];
        number_of_realizations_per_loop = 1000;
        correlated_fading;
        ChanMod = [];
    end
    
    methods (Static)
        function pdp_params = get_default_config(carrier_freq,nTX,nRX,speed,channel)
            pdp_params.BS_config.nTx     = nTX;
            pdp_params.UE_config.nRX     = nRX;
            pdp_params.speed             = speed;  % m/s
            pdp_params.correlated_fading = true;
            pdp_params.carrier_freq      = carrier_freq;
            pdp_params.PDP_profile       = channel;
        end
    end
    
    methods
        function obj = pdpChannelFactory(bandwidth,pdp_params)
            % Call superclass constructor
            obj = obj@channel_gain_wrappers.channelFactory(bandwidth);
            
            obj.correlated_fading = pdp_params.correlated_fading;
            obj.ChanMod = obj.ChanMod_params_generator(pdp_params.PDP_profile,pdp_params.BS_config.nTx,pdp_params.UE_config.nRX);
            
            obj.fading_config_params.nTX                             = pdp_params.BS_config.nTx;
            obj.fading_config_params.nRX                             = pdp_params.UE_config.nRX;
            obj.fading_config_params.corrRX                          = obj.ChanMod.corrRX;
            obj.fading_config_params.corrTX                          = obj.ChanMod.corrTX;
            obj.fading_config_params.number_of_realizations_per_loop = obj.number_of_realizations_per_loop;
            obj.fading_config_params.tap_powers                      = sqrt(10.^(obj.ChanMod.PDP_dB(1,:)./10)) / obj.ChanMod.normH; % Power of taps in linear and normalized to 1
            obj.fading_config_params.tap_delays                      = round(obj.ChanMod.PDP_dB(2,:)*obj.fs);
            obj.fading_config_params.tap_position                    = [1, find(diff(obj.fading_config_params.tap_delays)) + 1];
            
            % Sum up all of the taps that merge (sum power!): nearest neighbor interpolation
            obj.fading_config_params.tap_powers_used = zeros(1,max(obj.fading_config_params.tap_delays+1));
            for tap_idx = unique(obj.fading_config_params.tap_delays)
                taps_to_sum = obj.fading_config_params.tap_delays==tap_idx;
                obj.fading_config_params.tap_powers_used(tap_idx+1) = sqrt(sum(obj.fading_config_params.tap_powers(taps_to_sum).^2));
            end
            
            obj.fading_config_params.number_of_taps        = length(obj.fading_config_params.tap_position);
            obj.fading_config_params.f                     = pdp_params.carrier_freq;  % Frequency at which our system operates [Hz]
            obj.fading_config_params.fs                    = obj.fs;
            obj.fading_config_params.Tsubframe             = obj.tSubframe;
            obj.fading_config_params.Nfft                  = obj.Nfft;
            obj.fading_config_params.Ntot                  = obj.Ntot;
            obj.fading_config_params.FFT_sampling_interval = obj.FFT_sampling_interval;
            
            obj.rosa_zheng_params.M     = 15;
            nRX = pdp_params.UE_config.nRX;
            nTX = pdp_params.BS_config.nTx;
            obj.rosa_zheng_params.psi   = rand(nRX, nTX,obj.fading_config_params.number_of_taps, obj.rosa_zheng_params.M);
            obj.rosa_zheng_params.phi   = repmat(rand(nRX, nTX,obj.fading_config_params.number_of_taps, 1),[1 1 1 obj.rosa_zheng_params.M]);
            obj.rosa_zheng_params.theta = rand(nRX, nTX,obj.fading_config_params.number_of_taps, obj.rosa_zheng_params.M);
            obj.rosa_zheng_params.v     = pdp_params.speed; % In m/s
        end
        
        function ChanMod = ChanMod_params_generator(obj,channel_type,nTX,nRX)
            % Obtain the config parameter for the channel model (taken from the LTE LL
            % simulator: LTE_load_parameters_dependant.m)
            % (c) Josep Colom Ikuno, INTHFT, 2009
            
            ChanMod.type = channel_type;
            ChanMod.nTX  = nTX;
            ChanMod.nRX  = nRX;
            
            switch ChanMod.type
                case {'PedA'}
                    ChanMod.PDP_dB = [0 -9.7 -19.2 -22.8;  % Average power [dB]
                        [ 0 110 190 410 ]*10^-9 ]; % delay (s)
                    ChanMod.normH = sqrt(sum(10.^(ChanMod.PDP_dB(1,:)/10)));
                case {'PedB', 'PedBcorr'}
                    ChanMod.PDP_dB = [0   -0.9  -4.9  -8    -7.8  -23.9; % Average power [dB]
                        [ 0 200 800 1200 2300 3700 ]*10^-9 ]; % delay (s)
                    ChanMod.normH = sqrt(sum(10.^(ChanMod.PDP_dB(1,:)/10)));
                case {'extPedB'}
                    % ITU-T extended PedestrianB channel model. From "Extension of the ITU Channel Models
                    % for Wideband (OFDM) Systems", Troels B. Sørensen, Preben E.
                    % Mogensen, Frank Frederiksen
                    ChanMod.PDP_dB = [0 -0.1 -3.7 -3.0 -0.9 -2.5 -5.0 -4.8 -20.9; % Average power [dB]
                        [ 0 30 120 200 260 800 1200 2300 3700 ]*1e-9 ]; % delay (s)
                    ChanMod.normH = sqrt(sum(10.^(ChanMod.PDP_dB(1,:)/10)));
                case {'VehA'}
                    ChanMod.PDP_dB = [0   -1  -9  -10    -15  -20; % Average power [dB]
                        [ 0 310 710 1090 1730 2510 ]*10^-9 ]; % delay (s)
                    ChanMod.normH = sqrt(sum(10.^(ChanMod.PDP_dB(1,:)/10)));
                case {'VehB'}
                    ChanMod.PDP_dB = [-2.5   0  -12.8  -10    -25.2  -16; % Average power [dB]
                        [ 0 300 8900 12900 17100 20000 ]*10^-9]; % delay (s)
                    ChanMod.normH = sqrt(sum(10.^(ChanMod.PDP_dB(1,:)/10)));
                case {'TU'}
                    ChanMod.PDP_dB = [-5.7000 -7.6000 -10.1000 -10.2000 -10.2000 -11.5000 -13.4000 -16.3000 -16.9000 -17.1000 -17.4000,...
                        -19.0000 -19.0000 -19.8000 -21.5000 -21.6000 -22.1000 -22.6000 -23.5000 -24.3000; % Average power [dB]
                        0 0.2170 0.5120 0.5140 0.5170 0.6740 0.8820 1.2300 1.2870 1.3110 1.3490 1.5330 1.5350,...
                        1.6220 1.8180 1.8360 1.8840 1.9430 2.0480 2.1400];% delay (s)
                    ChanMod.PDP_dB(2,:) = ChanMod.PDP_dB(2,:)*10^-6;
                    ChanMod.normH = sqrt(sum(10.^(ChanMod.PDP_dB(1,:)/10)));
                case {'RA'}
                    ChanMod.PDP_dB = [-5.2000 -6.4000 -8.4000 -9.3000 -10.0000 -13.1000 -15.3000 -18.5000 -20.4000 -22.4000; % Average power [dB]
                        0 0.0420 0.1010 0.1290 0.1490 0.2450 0.3120 0.4100 0.4690 0.5280]; % delay (s)
                    ChanMod.PDP_dB(2,:) = ChanMod.PDP_dB(2,:)*10^-6;
                    ChanMod.normH = sqrt(sum(10.^(ChanMod.PDP_dB(1,:)/10)));
                case {'HT'}
                    ChanMod.PDP_dB = [-3.6000 -8.9000 -10.2000 -11.5000 -11.8000 -12.7000 -13.0000 -16.2000 -17.3000 -17.700 -17.6000 -22.7000,...
                        -24.1000 -25.8000 -25.8000 -26.2000 -29.0000 -29.9000 -30.0000 -30.7000; % Average power [dB]
                        0 0.3560 0.4410 0.5280 0.5460 0.6090 0.6250 0.8420 0.9160 0.9410 15.0000 16.1720 16.4920 16.8760 16.8820,...
                        16.9780 17.6150 17.827 17.8490 18.0160]; % delay (s)
                    ChanMod.PDP_dB(2,:) = ChanMod.PDP_dB(2,:)*10^-6;
                    ChanMod.normH = sqrt(sum(10.^(ChanMod.PDP_dB(1,:)/10)));
            end
            %% Channel parameters dependent - now only the same channel parameters for each user and BS are allowed
            % load Correlation Matrices
            if strcmp(ChanMod.type,'PedA') || strcmp(ChanMod.type,'PedB') || strcmp(ChanMod.type,'VehA') || strcmp(ChanMod.type,'VehB') ||strcmp(ChanMod.type,'TU') || strcmp(ChanMod.type,'RA') || strcmp(ChanMod.type,'HT') || strcmp(ChanMod.type,'extPedB')
                ChanMod.corrRX = ones(size(ChanMod.PDP_dB,2),nRX,nRX);
                ChanMod.corrTX = ones(size(ChanMod.PDP_dB,2),nTX,nTX);
                for kk = 1:size(ChanMod.PDP_dB,2)
                    ChanMod.corrRX(kk,:,:) = eye(nRX);
                    ChanMod.corrTX(kk,:,:) = eye(nTX);
                end
            elseif strcmp(ChanMod.type,'PedBcorr')
                ChanMod.corrRX = ones(size(ChanMod.PDP_dB,2),nRX,nRX);
                ChanMod.corrTX = ones(size(ChanMod.PDP_dB,2),nTX,nTX);
                for kk = 1:size(ChanMod.PDP_dB,2)
                    ChanMod.corrRX(kk,:,:) = eye(nRX) + ChanMod.corr_coefRX*ones(nRX) - ChanMod.corr_coefRX*eye(nRX);
                    ChanMod.corrTX(kk,:,:) = eye(nTX) + ChanMod.corr_coefTX*ones(nTX) - ChanMod.corr_coefTX*eye(nTX);
                end
            end
        end
        
        function plot_ChanMod(obj,ChanMod)
            % Debug function
            figure;
            stem(ChanMod.PDP_dB(2,:),ChanMod.PDP_dB(1,:));
        end
        
        function pregen_H_trace = generate_FF_trace(obj,N_subframes)
            % Generate fast fading coefficients for the simulation using the Rosa Zheng
            % model. This function returns a struct containing the sampled channel model
            % (c) Michal Simko, modified by Josep Colom Ikuno, INTHFT, 2009
            
            % Shorthand naming
            nRX = obj.fading_config_params.nRX;
            nTX = obj.fading_config_params.nTX;
            
            %% Separate the N_subframes in smaller chunks to avoid memory problems
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
           
            %% Create output, where the pregenerated fast fading will be stored
            pregen_H_trace.channel_model_name = obj.ChanMod.type;
            pregen_H_trace.fs                 = obj.fs;
            pregen_H_trace.H_RB_samples       = zeros(nRX,nTX,N_subframes,obj.fading_config_params.Ntot/obj.FFT_sampling_interval);
            pregen_H_trace.fft_points         = obj.Nfft;
            pregen_H_trace.t_start            = 0;
            pregen_H_trace.t_end              = (N_subframes-1)*obj.tSubframe;
            pregen_H_trace.t_step             = obj.tSubframe;
            pregen_H_trace.t_length           = N_subframes;
            pregen_H_trace.h_length           = obj.ChanMod.PDP_dB(2,end); % Length of the channel in seconds
            pregen_H_trace.UE_speed           = obj.rosa_zheng_params.v;
            
            %% Generate channel coefficients
            % Separated the channel coefficient generation in several loops so as not
            % to eat up all of the memory.
            %H_fft_sampled = zeros(nRX,nTX,number_of_realizations_per_loop,fading_config_params.Ntot/6);
            print_i_ = unique(floor(linspace(1,number_of_loops,10)));
            current_i = 1;
            for loop_idx = 1:number_of_loops
                if loop_idx==print_i_(current_i)
                    percentage = loop_idx/number_of_loops*100;
                    fprintf([num2str(percentage,'%3.2f') '%% ']);
                    current_i = current_i + 1;
                end
                samples     = begin_pos(loop_idx):end_pos(loop_idx);
                loop_offset = begin_pos(loop_idx)-1;
                pregen_H_trace.H_RB_samples(:,:,samples,:) = obj.fading_generation(loop_offset);
            end
            fprintf('\n');
        end
        
        function H_fft_to_return = fading_generation(obj,loop_offset)
            % Generate fast fading coefficients for the simulation. Separated the function due to memory issues.
            % (c) Michal Simko, INTHFT, 2009
            correlated_fading      = obj.correlated_fading;
            fading_config_params   = obj.fading_config_params;
            rosa_zheng_params      = obj.rosa_zheng_params;
            number_of_realizations = fading_config_params.number_of_realizations_per_loop;
            tap_powers             = fading_config_params.tap_powers;% Power of taps
            tap_delays             = fading_config_params.tap_delays;
            tap_position           = fading_config_params.tap_position;
            tap_powers_used        = fading_config_params.tap_powers_used;
            number_of_taps         = fading_config_params.number_of_taps;
            f                      = fading_config_params.f;  % Frequency at which our system operates
            v                      = rosa_zheng_params.v;
            nTX                    = fading_config_params.nTX;
            nRX                    = fading_config_params.nRX;
            M                      = rosa_zheng_params.M;
            corrRX                 = fading_config_params.corrRX;
            corrTX                 = fading_config_params.corrTX;
            fs                     = fading_config_params.fs;
            Tsubframe              = fading_config_params.Tsubframe;
            Nfft                   = fading_config_params.Nfft;
            Ntot                   = fading_config_params.Ntot;
            FFT_sampling_interval  = fading_config_params.FFT_sampling_interval; % Specifiy out of the useful data subcarrier's FFT,
            % which ones to take (all of them take up too much memory)
            
            %% Preallocation of the Time matrix
            time_i = zeros(nRX, nTX,number_of_realizations,number_of_taps,M);
            time_i_help = tap_delays(tap_position) / fs;
            % We sample once per TTI. for the LL simulator this happens depending on the sampling frequency (LTE_params.Fs)
            time_i_help = kron(time_i_help, ones(number_of_realizations,1)) + ((0:(number_of_realizations-1))+loop_offset).'*ones(1,length(time_i_help))*Tsubframe;
            %time_i_help = repmat(time_i_help,[1, 1, M]);
            time_i(1,1,:,:,1) = time_i_help;
            time_i = repmat(time_i(1,1,:,:,1),[nRX, nTX, 1, 1, M]);
            
            if correlated_fading
                %% Rosa-Zheng parameters
                % Yahong Rosa Zheng; Chengshan Xiao, "Simulation models with correct statistical properties for Rayleigh fading channels," Communications, IEEE Transactions on , vol.51, no.6, pp. 920-928, June 2003
                % URL:
                % http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=1209292&isnumber=27219
                c = 299792458;
                w_d   = 2*pi*v*f/c;      % Maximum radian Doppler frequency
                X_c   = zeros(nRX, nTX,number_of_realizations,number_of_taps,M);
                X_s   = zeros(nRX, nTX,number_of_realizations,number_of_taps,M);
                psi_n = zeros(nRX, nTX,number_of_realizations,number_of_taps,M);
                theta = zeros(nRX, nTX,number_of_realizations,number_of_taps,M);
                phi   = zeros(nRX, nTX,number_of_realizations,number_of_taps,M);
                
                %% For the generation of the rosa zheng weights
                psi_n(:,:,1, :, :)   = rosa_zheng_params.psi;
                phi(:,:,1, :, :)     = rosa_zheng_params.phi;
                theta(:,:,1, :, :)   = rosa_zheng_params.theta;
                for tap_i = 1:number_of_taps
                    for M_i = 1:M
                        psi_n(:,:,1, tap_i, M_i) = (sqrtm(squeeze(corrRX(tap_i,:,:)))*psi_n(:,:,1, tap_i, M_i)*(sqrtm(squeeze(corrTX(tap_i,:,:)))).');
                        phi(:,:,1, tap_i, M_i)   = (sqrtm(squeeze(corrRX(tap_i,:,:)))*phi(:,:,1, tap_i, M_i)*(sqrtm(squeeze(corrTX(tap_i,:,:)))).');
                        theta(:,:,1, tap_i, M_i) = (sqrtm(squeeze(corrRX(tap_i,:,:)))*theta(:,:,1, tap_i, M_i)*(sqrtm(squeeze(corrTX(tap_i,:,:)))).');
                    end
                end
                
                %% Calculation of H
                psi_n(:,:,1, :, :) = (psi_n(:,:,1, :, :)*2 - 1) * pi;
                phi(:,:,1, :, :)   = (phi(:,:,1, :, :)*2 - 1) * pi;
                theta(:,:,1, :, :) = (theta(:,:,1, :, :)*2 - 1) * pi;
                
                psi_n = repmat(psi_n(:,:,1, :, :), [1,1,number_of_realizations, 1, 1]);
                phi = repmat(phi(:,:,1, :, :), [1,1,number_of_realizations, 1, 1]);
                theta = repmat(theta(:,:,1, :, :), [1,1,number_of_realizations, 1, 1]);
                
                PI_mat = zeros(nRX, nTX,number_of_realizations,number_of_taps,M);
                PI_mat(1,1,1,1,:) = (1:M)*2*pi;
                PI_mat = repmat(PI_mat(1,1,1,1,:), [nRX, nTX, number_of_realizations, number_of_taps, 1]);
                alpha_n = (PI_mat - pi + theta) / (4*M);
                
                X_c = cos(psi_n).*cos(w_d.*time_i.*cos(alpha_n) + phi);
                X_s = sin(psi_n).*cos(w_d.*time_i.*cos(alpha_n) + phi);
                X = 2/sqrt(2*M) * sum(X_c + 1i*X_s,5);
            else % uncorrelated fading
                X = (randn(nRX,nTX,number_of_realizations,number_of_taps)+1i*randn(nRX,nTX,number_of_realizations,number_of_taps))/sqrt(2);
            end
            weight_matrix = zeros(nRX, nTX,number_of_realizations,number_of_taps);
            weight_matrix(1,1,:,:) = kron(tap_powers_used(unique(tap_delays+1)), ones(number_of_realizations,1));
            weight_matrix = repmat(weight_matrix(1,1,:,:),[nRX, nTX, 1, 1]);
            H = zeros(nRX, nTX, number_of_realizations, tap_delays(end)+1);
            H(:,:,:, tap_delays(tap_position)+1) = X .* weight_matrix;
            
            %% Trace in freq domain
            H_fft_to_return = obj.get_RB_trace(H);
        end
    end
end

