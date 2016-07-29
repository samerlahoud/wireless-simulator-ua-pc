%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation of Joint scheduling and power control for energy efficiency in
% multi-cell networks (2015)
% Samer Lahoud samer.lahoud@irisa.fr
% Kinda Khawam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [BS, user, linear_pathloss_fading_matrix] = generate_radio_conditions
global netconfig
nb_RBs              = netconfig.nb_RBs;
nb_sectors          = netconfig.nb_sectors;
nb_users_per_sector = netconfig.nb_users_per_sector;
total_nb_users      = netconfig.total_nb_users;
rng('shuffle')
load('network_1_rings_3_sectors_30_offset_10m_res_TS36942_urban_kathreinTSAntenna_antenna_8_-0__2.14GHz_freq_claussen8dB_shadow_fading.mat');

cur_id=1; % initalize the current user id
pathloss_matrix = zeros(total_nb_users,nb_sectors);
pathloss_fading_matrix = zeros(total_nb_users,nb_sectors,nb_RBs);
for cur_bs=1:nb_sectors
    % Find the elements in the path loss map that are associated with each
    % BS sector j
    [x_elem, y_elem] = find(networkPathlossMap.maxSINR_assignment == cur_bs);
    BS(cur_bs).attached_users=[];
    BS(cur_bs).gradient = zeros(1,nb_RBs);
    % Choose random nb_users_per_sector elements or users
    rnd_elem =randperm(numel(x_elem),nb_users_per_sector);
    for i_=1:nb_users_per_sector
        user(cur_id).id=cur_id;
        user(cur_id).serving_BS=cur_bs;
        user(cur_id).current_RB_number=0;
        user(cur_id).RB = 0;
        BS(cur_bs).attached_users(end+1) = user(cur_id).id;
        for j_=1:nb_sectors
            pathloss_matrix(user(cur_id).id,j_)=networkPathlossMap.pathloss(x_elem(rnd_elem(i_)), y_elem(rnd_elem(i_)),j_);
        end
        cur_id=cur_id+1;
    end
end
% Fading between RBs
for r_=1:nb_RBs
    pathloss_fading_matrix(:,:,r_) = pathloss_matrix .* (0.9 + (0.2).* rand(size(pathloss_matrix)));
end
linear_pathloss_fading_matrix = 1./(10.^(0.1.*pathloss_fading_matrix));

end

