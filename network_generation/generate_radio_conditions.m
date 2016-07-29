% Generate radio conditions based on output from Vienna LTE simulator
% Should integrate real fading law
function [BS, user, linear_pathloss_fading_matrix] = generate_radio_conditions
rng('shuffle')
load('network_1_rings_3_sectors_30_offset_10m_res_TS36942_urban_kathreinTSAntenna_antenna_8?-0?_2.14GHz_freq_claussen8dB_shadow_fading.mat');
global netconfig;
nb_users_per_sector=netconfig.nb_users_per_sector;
nb_sectors=netconfig.nb_sectors;
nb_RBs=netconfig.nb_RBs;

cur_id=1; % initalize the current user id
for cur_bs=1:nb_sectors
    % Find the elements in the path loss map that are associated with each
    % BS sector j
    [x_elem, y_elem] = find(networkPathlossMap.maxSINR_assignment == cur_bs);
    BS(cur_bs).attached_users=[];
    % Choose random nb_users_per_sector elements or users
    rnd_elem =randperm(numel(x_elem),nb_users_per_sector);
    for i=1:nb_users_per_sector
        user(cur_id).id=cur_id;
        user(cur_id).serving_BS=cur_bs;
        BS(cur_bs).attached_users(end+1) = user(cur_id).id;
        for j=1:nb_sectors
            pathloss_matrix(user(cur_id).id,j)=networkPathlossMap.pathloss(x_elem(rnd_elem(i)), y_elem(rnd_elem(i)),j);
        end
        cur_id=cur_id+1;
    end
end
% artifical fading between RBs
for r=1:nb_RBs
    pathloss_fading_matrix(:,:,r) = pathloss_matrix .* (0.9 + (0.2).* rand(size(pathloss_matrix)));
end
%pathloss_matrix = pathloss_matrix .* (0.8 + (0.3).* rand(size(pathloss_matrix)))
linear_pathloss_fading_matrix = 1./(10.^(0.1.*pathloss_fading_matrix));
%linear_pathloss_matrix = ones(63,21);

