function [BS_abs, BS_ord, user_abs, user_ord, pathloss, BS_to_BS_pathloss] ...
    = generate_hetnet_radio_conditions_v4(run_instance)
% COST231 model for radio conditions

rng('shuffle')

% Get global configuration parameters
global netconfig;
nb_users = netconfig.nb_users;
user_distribution = netconfig.user_distribution;

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

% Get geographical positions of BSs
BS_abs = zeros(nb_BSs,1);
BS_ord = zeros(nb_BSs,1);
for b = 1:nb_BSs
    BS_abs(b) = eNodeBs(b).parent_eNodeB.pos(1);
    BS_ord(b) = eNodeBs(b).parent_eNodeB.pos(2);
end

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

% Get real pathgain
BS_to_BS_pathloss = 10.^(BS_to_BS_pathloss./10);

%femto_to_femto_pathloss = BS_to_BS_pathloss(nb_macro_BSs+1:end,nb_macro_BSs+1:end);

% Generate user position

% Uniform user position
if strcmp(user_distribution, 'uniform')
    user_x_idx = randi(x_range,nb_users,1);
    user_y_idx = randi(y_range,nb_users,1);
elseif strcmp(user_distribution, 'normal')
    % Normal (cluster) user position
    % Cluster is centered at (x_range/2, y_range/2) with large std deviation
    x_pd = makedist('Normal','mu',x_range/2,'sigma',45);
    x_pd_t = truncate(x_pd,0,x_range);
    y_pd = makedist('Normal','mu',y_range/2,'sigma',45);
    y_pd_t = truncate(y_pd,0,y_range);
    
    % ceil is pertinent to avoid 0 matrix index
    user_x_idx = ceil(random(x_pd_t,nb_users,1));
    user_y_idx = ceil(random(y_pd_t,nb_users,1));
end

% Get real coordinates from pathloss map (the map is dangerousely inverted)
user_ord = networkPathlossMap.data_res.*(user_x_idx-1)+networkPathlossMap.roi_y(1);
user_abs = networkPathlossMap.data_res.*(user_y_idx-1)+networkPathlossMap.roi_x(1);

% Compute pathloss (this is pathgain in fact) with per site shadowing 
pathloss = zeros(nb_users,nb_BSs); % real values
for u = 1:nb_users
    for b = 1:nb_BSs
        user_bs_distance = pdist([[user_abs(u) user_ord(u)];[BS_abs(b) BS_ord(b)]],'euclidean');
        pathloss(u,b) = Cost231extendedHataPassLossModel(user_bs_distance, 'urban');
    end                          
end

% Get real pathgain
pathloss = 10.^(pathloss./10);

end