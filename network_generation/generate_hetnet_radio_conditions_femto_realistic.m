function [peak_rate, pathloss, sinr] = generate_hetnet_radio_conditions_femto_realistic
rng('shuffle')

% Get global configuration parameters
global netconfig;
nb_users = netconfig.nb_users;
load('./radio_conditions/orange_4G_35400_antenna_coordinates.mat')
nb_macro_BSs = numel(antenna_long);
netconfig.nb_macro_BSs=nb_macro_BSs;
netconfig.nb_femto_BSs=40;
nb_femto_BSs = netconfig.nb_femto_BSs;
RB_bandwidth = netconfig.RB_bandwidth;
nb_RBs = netconfig.nb_RBs;
macro_tx_power = netconfig.macro_tx_power;
femto_tx_power = netconfig.femto_tx_power;
tx_antenna_gain = netconfig.tx_antenna_gain;
rx_antenna_gain = netconfig.rx_antenna_gain;
thermal_noise_power = netconfig.thermal_noise_power;

% Generate base stations and users
tx_power = [macro_tx_power*ones(1,nb_macro_BSs), ...
            femto_tx_power*ones(1,nb_femto_BSs)];
nb_BSs = nb_macro_BSs + nb_femto_BSs;
netconfig.nb_BSs = nb_BSs;
macro_BS_abs = antenna_long;
macro_BS_ord = antenna_lat;

% Geographical map boundaries
%user_map_boundaries = [round(min(macro_BS_abs))-100,round(max(macro_BS_abs))+100; ...
%                      round(min(macro_BS_ord))-100,round(max(macro_BS_ord))+100];

user_map_boundaries = [round(min(macro_BS_abs)),round(max(macro_BS_abs)); ...
                      round(min(macro_BS_ord)),round(max(macro_BS_ord))];

% Femto BS coordinates
femto_BS_abs = user_map_boundaries(1,1)+(user_map_boundaries(1,2)- ...
               user_map_boundaries(1,1))*rand(1,nb_femto_BSs);
femto_BS_ord = user_map_boundaries(2,1)+(user_map_boundaries(2,2)- ... 
               user_map_boundaries(2,1))*rand(1,nb_femto_BSs);

% First nb_macro_BSs BSs are macro BSs, the remaining are femto
BS_abs = [macro_BS_abs femto_BS_abs];
BS_ord = [macro_BS_ord femto_BS_ord];

user_abs = user_map_boundaries(1,1)+(user_map_boundaries(1,2)- ...
           user_map_boundaries(1,1))*rand(nb_users,1);
user_ord = user_map_boundaries(2,1)+(user_map_boundaries(2,2)- ...
           user_map_boundaries(2,1))*rand(nb_users,1);

% Matrix of distances between users and BSs
distance_matrix = zeros(nb_users,nb_BSs);
for u = 1:nb_users
  for b = 1:nb_BSs
      distance_matrix(u,b) = pdist([[user_abs(u) user_ord(u)];[BS_abs(b) BS_ord(b)]],'euclidean');
  end
end

% Pathloss matrix => revise this according to accurate models
pathloss = zeros(nb_users,nb_BSs);
for u = 1:nb_users
    for b = 1:nb_BSs
        pathloss(u,b)=Cost231extendedHataPassLossModel(distance_matrix(u,b),'urban');
        %if b <= nb_macro_BSs
        %    pathloss(u,b) = 128+37.6*log10(distance_matrix(u,b)/1000);
        %else
        %    pathloss(u,b) = 140.7+36.7*log10(distance_matrix(u,b)/1000);
        %end
    end
end

% Received power and SINR matrices
rx_power = zeros(nb_users,nb_BSs);
sinr = zeros(nb_users,nb_BSs); % in dB

for u = 1:nb_users
    for b = 1:nb_BSs
        rx_power(u,b) = (tx_power(b)*tx_antenna_gain*rx_antenna_gain)/10^(pathloss(u,b)/10);
    end
end

for u = 1:nb_users
    for b = 1:nb_BSs
        if b <= nb_macro_BSs
            interf = sum(rx_power(u,1:nb_macro_BSs))-rx_power(u,b);
        else
            interf = sum(rx_power(u,nb_macro_BSs+1:nb_BSs))-rx_power(u,b);
        end
        sinr_real = rx_power(u,b)/(thermal_noise_power + interf);
        sinr(u,b) = 10*log10(sinr_real);
    end
end

% SINR peak rate equivalence map is given per Hz
% http://www.etsi.org/deliver/etsi_tr/136900_136999/136942/08.01.00_60/tr_136942v080100p.pdf
% Please check LTE simulator
sinr_peak_rate_equivalence = load('./radio_conditions/snr-peak-rate.txt','-ascii');
sinr_range = sinr_peak_rate_equivalence(:,1);
peak_rate_range = sinr_peak_rate_equivalence(:,2);

peak_rate = zeros(nb_users,nb_BSs) ;
for u = 1:nb_users 
    for b = 1:nb_BSs
        peak_rate_round = find(sinr(u,b)<sinr_range);
        peak_rate(u,b) = peak_rate_range(peak_rate_round(1))*RB_bandwidth*nb_RBs;
    end
end

result_file_name = sprintf('./output/radio_generation.mat');
save(result_file_name, 'netconfig', 'BS_abs', 'BS_ord', 'user_abs', 'user_ord');

end