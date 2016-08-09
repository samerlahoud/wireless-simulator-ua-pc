function [peak_rate, pathloss, sinr, BS_to_BS_pathloss] = generate_hetnet_radio_conditions_v2(run_instance)
% This is based on the Vienna LTE Simulator
% Radio model includes shadowing and trisector antennas
rng('shuffle')

% Get global configuration parameters
global netconfig;
nb_users = netconfig.nb_users;
RB_bandwidth = netconfig.RB_bandwidth;
nb_RBs = netconfig.nb_RBs;
macro_tx_power = netconfig.macro_tx_power;
femto_tx_power = netconfig.femto_tx_power;
tx_antenna_gain = netconfig.tx_antenna_gain;
rx_antenna_gain = netconfig.rx_antenna_gain;
thermal_noise_power = netconfig.thermal_noise_power;

% Original file name is network_1_rings_3_sectors_30_offset_5m_res_TS36942_
% urban_TS 36.942_antenna_2.14GHz_freq_plus_femtocells

load('network_1_rings_femtocells.mat');

% Get geographical area and BS carachteristics from pathloss map
[x_range, y_range, nb_BSs] = size(networkPathlossMap.pathloss);

netconfig.nb_BSs = nb_BSs;
[BS_type, ~, ub] = unique(networkPathlossMap.site_type);
% histc returns two structures
BS_type_count = histc(ub, 1:length(BS_type));

for t_ = 1:length(BS_type)
    if ismember(BS_type(t_),'macro')
        netconfig.nb_macro_BSs = BS_type_count(t_);
    elseif ismember(BS_type(t_),'femto')
        netconfig.nb_femto_BSs = BS_type_count(t_);
    end
end
nb_femto_BSs = netconfig.nb_femto_BSs;
nb_macro_BSs = netconfig.nb_macro_BSs;

% Get geographical positions of BSs
BS_abs = zeros(nb_BSs,1);
BS_ord = zeros(nb_BSs,1);
for b = 1:nb_BSs
    BS_abs(b) = eNodeBs(b).parent_eNodeB.pos(1);
    BS_ord(b) = eNodeBs(b).parent_eNodeB.pos(2);
end

% Define BS transmit power
tx_power = [macro_tx_power*ones(1,nb_macro_BSs), ...
            femto_tx_power*ones(1,nb_femto_BSs)];

% Compute BS to BS distance and pathloss
% Macro trisectors are colocated, how to compute distance ?
BS_to_BS_distance_matrix = zeros(nb_BSs,nb_BSs);
BS_to_BS_pathloss = zeros(nb_BSs,nb_BSs);
for bs1 = 1:nb_BSs-1
  for bs2 = bs1+1:nb_BSs
      BS_to_BS_distance_matrix(bs1,bs2) = pdist([[BS_abs(bs1) BS_ord(bs1)];[BS_abs(bs2) BS_ord(bs2)]],'euclidean');
      BS_to_BS_pathloss(bs1,bs2)= Cost231extendedHataPassLossModel(BS_to_BS_distance_matrix(bs1,bs2), 'urban');
  end
end
BS_to_BS_distance_matrix = BS_to_BS_distance_matrix + BS_to_BS_distance_matrix';
BS_to_BS_pathloss = BS_to_BS_pathloss + BS_to_BS_pathloss';

femto_to_femto_pathloss = BS_to_BS_pathloss(nb_macro_BSs+1:end,nb_macro_BSs+1:end);

% Generate user position

% Uniform user position
% user_x_idx = randi(x_range,nb_users,1);
% user_y_idx = randi(y_range,nb_users,1);

% Normal (cluster) user position
% Cluster is centered at (x_range/2, y_range/2) with large std deviation
x_pd = makedist('Normal','mu',x_range/2,'sigma',45);
x_pd_t = truncate(x_pd,0,x_range);
y_pd = makedist('Normal','mu',y_range/2,'sigma',45);
y_pd_t = truncate(y_pd,0,y_range);

% ceil is pertinent to avoid 0 matrix index
user_x_idx = ceil(random(x_pd_t,nb_users,1));
user_y_idx = ceil(random(y_pd_t,nb_users,1));

% Compute pathloss (this is pathgain in fact) with per site shadowing 
pathloss = zeros(nb_users,nb_BSs); % real values
for u = 1:nb_users
    for b = 1:nb_BSs
     pathloss(u,b) = networkPathlossMap.pathloss(user_x_idx(u),user_y_idx(u),b) * ...
         networkShadowFadingMap.pathloss(user_x_idx(u),user_y_idx(u),eNodeBs(b).parent_eNodeB.id);
    end                          
end

% Received power and SINR matrices
rx_power = zeros(nb_users,nb_BSs);
sinr = zeros(nb_users,nb_BSs); % in dB

% Check for penetration loss
for u = 1:nb_users
    for b = 1:nb_BSs
        rx_power(u,b) = (tx_power(b)*tx_antenna_gain*rx_antenna_gain)/pathloss(u,b);
    end
end

% Frequency reuse model
nb_RBs_per_BS = zeros(1,nb_BSs);
for b = 1:nb_BSs
    if b <= nb_macro_BSs
        nb_RBs_per_BS(b) = nb_RBs/2;
    else
        nb_RBs_per_BS(b) = nb_RBs/2;
    end
end
    
% Check for interferers model
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
%sinr_peak_rate_equivalence = load('./radio_conditions/snr-peak-rate.txt','-ascii');
%sinr_range = sinr_peak_rate_equivalence(:,1);
%peak_rate_range = sinr_peak_rate_equivalence(:,2);

% Transformed to output of Vienna simulator, adding only fictive high SINR 1000
load('SNR_to_throughput_mod_mapping.mat');

% Check for nb_RBs according to freq allocation
peak_rate = zeros(nb_users,nb_BSs) ;
for u = 1:nb_users 
    for b = 1:nb_BSs
        peak_rate_round = find(sinr(u,b)<sinr_range);
        peak_rate(u,b) = peak_rate_range(peak_rate_round(1))*RB_bandwidth*nb_RBs_per_BS(b);
    end
end

% Get real coordinates from pathloss map (the map is dangerousely inverted)
user_ord = networkPathlossMap.data_res.*(user_x_idx-1)+networkPathlossMap.roi_y(1);
user_abs = networkPathlossMap.data_res.*(user_y_idx-1)+networkPathlossMap.roi_x(1);

result_file_name = sprintf('./output/radio-conditions-%dusers-%drun.mat', nb_users, run_instance);
save(result_file_name, 'netconfig', 'BS_abs', 'BS_ord', 'user_abs', 'user_ord', ...
    'peak_rate', 'pathloss', 'sinr', 'BS_to_BS_pathloss');

end