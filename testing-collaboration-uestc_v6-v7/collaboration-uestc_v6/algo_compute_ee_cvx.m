%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation of Joint scheduling and power control for energy efficiency in
% multi-cell networks (2015)
% Samer Lahoud samer.lahoud@irisa.fr
% Kinda Khawam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [complete_time]=algo_compute_ee_cvx(netconfig, BS, pathloss_matrix)

total_nb_users=netconfig.total_nb_users;
nb_sectors=netconfig.nb_sectors;
nb_users_per_sector=netconfig.nb_users_per_sector;
nb_RBs=netconfig.nb_RBs;
max_power_per_sector=netconfig.max_power_per_sector;

result_file_name = sprintf('./results-compute-ee-%dusers-%dsectors-%dRBs-%dW.mat',...
    nb_users_per_sector,nb_sectors,nb_RBs,max_power_per_sector);

tic
[ee_power_allocation_matrix,ee_sinr_matrix,eta] = ...
    central_ee_maxlog_sinr_power_allocation_cvx(netconfig, pathloss_matrix, BS); 
complete_time=toc;

% Result formatting
% SINR vectors take the non zero elements in the SINR matrix.
% Recall that zero elements in the SINR matrix result from the cell
% selection problem: a user that is not attached to a sector has a null
% SINR for all RBs in this sector (log is -Inf)
% ee_sinr_db_vector = 10*log(reshape(ee_sinr_matrix,[],1));
% ee_sinr_db_sorted_vector = sort(ee_sinr_db_vector(ee_sinr_db_vector>-Inf));
% 
% % Power is divided by the max power per sector
% ee_power_db_vector = 10*log(reshape(ee_power_allocation_matrix, [], 1)./max_power_per_sector);
% ee_power_db_sorted_vector = sort(ee_power_db_vector);

% Reproduce power allocation per user
ee_power_allocation_matrix_per_user=zeros(total_nb_users,nb_RBs,nb_sectors);
for j=1:nb_sectors
    for i=BS(j).attached_users
        ee_power_allocation_matrix_per_user(i,:,j)=ee_power_allocation_matrix(j,:);
    end
end

% ee_power_db_vector_per_user = 10*log(reshape(ee_power_allocation_matrix_per_user, [], 1)./max_power_per_sector);
% 
% pathloss_db_vector = 10*log(reshape(pathloss_matrix,[], 1));

save(result_file_name,'netconfig','eta','ee_power_allocation_matrix');

end
