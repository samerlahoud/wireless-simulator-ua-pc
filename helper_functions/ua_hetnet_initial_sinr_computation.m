function [peak_rate, sinr, rx_RB_power] = ua_hetnet_initial_sinr_computation(pathloss, RB_allocation)

global netconfig;
nb_BSs = netconfig.nb_BSs;
nb_users = netconfig.nb_users;
nb_RBs = netconfig.nb_RBs;
nb_femto_RBs = netconfig.nb_femto_RBs;
nb_macro_RBs = nb_RBs - nb_femto_RBs;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_femto_BSs = netconfig.nb_femto_BSs;
nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;
nb_mmwave_BSs = netconfig.nb_mmwave_BSs;
macro_tx_power = netconfig.macro_tx_power;
femto_tx_power = netconfig.femto_tx_power;
mmwave_tx_power = netconfig.mmwave_tx_power;
tx_antenna_gain = netconfig.tx_antenna_gain;
rx_antenna_gain = netconfig.rx_antenna_gain;
mmwave_tx_antenna_gain = netconfig.mmwave_tx_antenna_gain;
mmwave_rx_antenna_gain = netconfig.mmwave_rx_antenna_gain;
RB_bandwidth = netconfig.RB_bandwidth;
mmwave_bandwidth = netconfig.mmwave_bandwidth;
noise_density = netconfig.noise_density;

% Define BS transmit power per RB
% Beware that there is no RB in mmwave
tx_RB_power = [macro_tx_power*ones(1,nb_macro_BSs)./nb_macro_RBs, ...
            femto_tx_power*ones(1,nb_femto_BSs)./nb_femto_RBs, ...
            mmwave_tx_power*ones(1,nb_mmwave_BSs)];
        
% Received power and SINR matrices
rx_RB_power = zeros(nb_users,nb_BSs);
sinr_RB = zeros(nb_users,nb_macro_femto_BSs,nb_RBs);

% Check for penetration loss
for u = 1:nb_users
    for b = 1:nb_macro_femto_BSs
        rx_RB_power(u,b) = (tx_RB_power(b)*tx_antenna_gain*rx_antenna_gain)/pathloss(u,b);
    end
    for b = nb_macro_femto_BSs+1:nb_BSs
        rx_RB_power(u,b) = (tx_RB_power(b)*mmwave_tx_antenna_gain*mmwave_rx_antenna_gain)/pathloss(u,b);
    end
end

% SINR per RB is expressed only for macro and femto BSs
% Skip this if you want to compute mmwave SINR
for u = 1:nb_users
    for b = 1:nb_macro_femto_BSs
        % Iterate over allocated RB on BS b
        for k = find(RB_allocation(b,:)==1)
            interf = sum(rx_RB_power(u,RB_allocation(:,k)==1))-rx_RB_power(u,b);
            sinr_RB(u,b,k) = rx_RB_power(u,b)/(noise_density*RB_bandwidth + interf);
            %sinr(u,b) = 10*log10(sinr_real);
        end
    end
end

% Compute mean SINR for user u on BS b
sinr = zeros(nb_users,nb_BSs);
% SINR equals -Inf when femto demand is zero
for u = 1:nb_users
    for b = 1:nb_macro_femto_BSs
        if(sum(RB_allocation(b,:)) == 0)
            sinr(u,b) = -Inf;
            continue;
        end
        tmp_sinr_real = 0;
        % Iterate over allocated RB on BS b
        for k = find(RB_allocation(b,:)==1)
            tmp_sinr_real = tmp_sinr_real + sinr_RB(u,b,k);
        end
        % This is arithmectic mean (should we go for geometric?)
        tmp_sinr_real = tmp_sinr_real/sum(RB_allocation(b,:));
        sinr(u,b) = 10*log10(tmp_sinr_real);
    end
    % Reuse 1 model for mmwave
    for b = nb_macro_femto_BSs+1:nb_BSs
        mmwave_interf = sum(rx_RB_power(u,nb_macro_femto_BSs+1:nb_BSs))-rx_RB_power(u,b);
        sinr(u,b) = 10*log10(rx_RB_power(u,b)/(noise_density*mmwave_bandwidth + mmwave_interf));
    end
end         

% SINR peak rate equivalence map is given per Hz
% http://www.etsi.org/deliver/etsi_tr/136900_136999/136942/08.01.00_60/tr_136942v080100p.pdf
%sinr_peak_rate_equivalence = load('./radio_conditions/snr-peak-rate.txt','-ascii');
%sinr_range = sinr_peak_rate_equivalence(:,1);
%peak_rate_range = sinr_peak_rate_equivalence(:,2);

% Transformed to output of Vienna simulator, adding only fictive high SINR 1000
load('SNR_to_throughput_mod_mapping.mat');

% Check for nb_RBs according to freq allocation
peak_rate = zeros(nb_users,nb_BSs);
for u = 1:nb_users 
    for b = 1:nb_BSs
        peak_rate_round = find(sinr(u,b)<sinr_range);
        if isempty(peak_rate_round)
            peak_rate(u,b) = 0;
            continue;
        end
        if b <= nb_macro_femto_BSs
            peak_rate(u,b) = peak_rate_range(peak_rate_round(1))*RB_bandwidth*sum(RB_allocation(b,:));
        else
            if sinr(u,b) < -20
                peak_rate(u,b) = 0;
            else
                peak_rate(u,b) = mmwave_bandwidth*log2(1+10^(sinr(u,b)/10));
            end
        end
    end
end

end

