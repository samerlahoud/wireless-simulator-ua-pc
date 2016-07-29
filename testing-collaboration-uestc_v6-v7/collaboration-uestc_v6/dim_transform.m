function [linear_pathloss_fading_matrix]=dim_transform(pathloss_matrix)
% 将pathloss_matrix做转置，适应后面代码
global netconfig
nb_RBs              = netconfig.nb_RBs;
nb_sectors          = netconfig.nb_sectors;
total_nb_users      = netconfig.total_nb_users;

g_temp = zeros(total_nb_users,nb_RBs,nb_sectors);
for i_=1:size(pathloss_matrix,1)
    g_temp(i_,:,:) = reshape(pathloss_matrix(i_,:,:),nb_RBs,nb_sectors);
end
linear_pathloss_fading_matrix = g_temp;
end
