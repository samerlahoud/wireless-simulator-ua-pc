% Generate radio conditions based on output from Vienna LTE simulator
% Should integrate real fading law
function [BS, user, pathloss_RB_matrix] = generate_radio_conditions_v2
rng('shuffle')

global netconfig;
nb_users_per_sector         = netconfig.nb_users_per_sector;
nb_sectors                  = netconfig.nb_sectors;
nb_RBs                      = netconfig.nb_RBs;
is_sectorized               = netconfig.sectorized;
inter_site_dist             = netconfig.inter_site_dist;
user_max_dist               = netconfig.user_max_dist;
pathloss_matrix=zeros(nb_users_per_sector*nb_sectors,nb_sectors);

if is_sectorized
    nb_sectors_per_BS = 3;
else
    nb_sectors_per_BS = 1;
end
network_file_name = sprintf('network_2_rings_%d_sectors_inter_bs_%dm.mat',...
    nb_sectors_per_BS,inter_site_dist);
load(network_file_name);

bs_roi=[5 6 7 10 11 12 16 1 2 3 4 8 9 13 14 15 17 18 19];
if (is_sectorized)
%     sector_roi=[];
%     for b=bs_roi
%         sector_roi=[sector_roi sites(b).sectors.eNodeB_id];
%     end
%     bs_roi=sector_roi
    bs_roi=[13 16 17 20 31 32 33];
end

for b=1:nb_sectors 
    BS(b) = struct('attached_users',[]);
end
cur_user_id=1; % initalize the current user id
cur_bs_id=1;
for cur_bs=bs_roi(1:nb_sectors)
    % Find the elements in the path loss map that are associated with each
    % BS sector j
    [x_assign, y_assign] = find(networkPathlossMap.maxSINR_assignment == cur_bs);
    [x_dist, y_dist] = find(networkPathlossMap.distances(:,:,cur_bs) < user_max_dist);
    xy_elems = intersect([x_assign y_assign], [x_dist y_dist],'rows') ;
    x_elem=xy_elems(:,1);
    y_elem=xy_elems(:,2);
    BS(cur_bs_id).attached_users=[];
    % Choose random nb_users_per_sector elements or users
    rnd_elem =randperm(numel(x_elem),nb_users_per_sector);
    for i=1:nb_users_per_sector
        user(cur_user_id).id=cur_user_id;
        user(cur_user_id).serving_BS=cur_bs_id;
        BS(cur_bs_id).attached_users(end+1) = user(cur_user_id).id;
        for j=1:nb_sectors
            pathloss_matrix(user(cur_user_id).id,j)=networkPathlossMap.pathloss(x_elem(rnd_elem(i)), y_elem(rnd_elem(i)),bs_roi(j))...
                                            * networkShadowFadingMap.pathloss(x_elem(rnd_elem(i)), y_elem(rnd_elem(i)),bs_roi(j));
                                       %disp('no fading');
        end
        cur_user_id=cur_user_id+1;
    end
    cur_bs_id=cur_bs_id+1;
end
% artifical fading between RBs
for r=1:nb_RBs
    pathloss_RB_matrix(:,:,r) = pathloss_matrix.* (0.95 + (0.25).* rand(size(pathloss_matrix)));
end
pathloss_RB_matrix = 1./pathloss_RB_matrix;
%pathloss_matrix = pathloss_matrix .* (0.8 + (0.3).* rand(size(pathloss_matrix)))
%linear_pathloss_fading_matrix = 1./(10.^(0.1.*pathloss_fading_matrix));
%linear_pathloss_matrix = ones(63,21);

