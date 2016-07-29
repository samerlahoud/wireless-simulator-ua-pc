function [complete_time]=algo_compare_maxsinr(BS, pathloss_matrix, run_instance)
% Compare max-min sinr, max sum-log and uniform power
global netconfig;
total_nb_users=netconfig.total_nb_users;
nb_sectors=netconfig.nb_sectors;
nb_users_per_sector=netconfig.nb_users_per_sector;
nb_RBs=netconfig.nb_RBs;
max_power_per_sector=netconfig.max_power_per_sector;

result_file_name = sprintf('./output/results-compare-maxsinr-%dusers-%dsectors-%dRBs-%dW-%drun.mat',...
    nb_users_per_sector,nb_sectors,nb_RBs,max_power_per_sector, run_instance);

tic
%[time_allocation] = central_max_sinr_scheduling_rb_gp(netconfig,pathloss_matrix,BS);
[maxmin_power_allocation_matrix,maxmin_sinr_matrix] = ...
    central_maxmin_sinr_power_allocation_rb_gp_lambda_formulation(pathloss_matrix, BS);
[maxlog_power_allocation_matrix,maxlog_sinr_matrix] = ...
    central_maxlog_sinr_power_allocation_rb_gp(pathloss_matrix, BS);
[distributed_gt_maxlog_power_allocation_matrix,distributed_gt_maxlog_sinr_matrix] = ...
    distributed_gt_maxlog_sinr_power_allocation_rb_gp(pathloss_matrix, BS);
complete_time=toc;

% Result formatting
% SINR vectors take the non zero elements in the SINR matrix.
% Recall that zero elements in the SINR matrix result from the cell
% selection problem: a user that is not attached to a sector has a null
% SINR for all RBs in this sector (log is -Inf)
maxlog_sinr_db_vector = 10*log10(reshape(maxlog_sinr_matrix,[],1));
maxlog_sinr_db_sorted_vector = sort(maxlog_sinr_db_vector(maxlog_sinr_db_vector>-Inf));
maxmin_sinr_db_vector = 10*log10(reshape(maxmin_sinr_matrix,[],1));
maxmin_sinr_db_sorted_vector = sort(maxmin_sinr_db_vector(maxmin_sinr_db_vector>-Inf));
distributed_gt_maxlog_sinr_db_vector = 10*log10(reshape(distributed_gt_maxlog_sinr_matrix,[],1));
distributed_gt_maxlog_sinr_db_sorted_vector = sort(distributed_gt_maxlog_sinr_db_vector(distributed_gt_maxlog_sinr_db_vector>-Inf));

% Power is divided by the max power per sector
maxlog_power_db_vector = 10*log10(reshape(maxlog_power_allocation_matrix, [], 1)./max_power_per_sector);
maxlog_power_db_sorted_vector = sort(maxlog_power_db_vector);
maxmin_power_db_vector = 10*log10(reshape(maxmin_power_allocation_matrix, [], 1)./max_power_per_sector);
maxmin_power_db_sorted_vector = sort(maxmin_power_db_vector);
distributed_gt_maxlog_power_db_vector = 10*log10(reshape(distributed_gt_maxlog_power_allocation_matrix, [], 1)./max_power_per_sector);
distributed_gt_maxlog_power_db_sorted_vector = sort(distributed_gt_maxlog_power_db_vector);

% Reproduce power allocation per user
maxlog_power_allocation_matrix_per_user=zeros(total_nb_users,nb_sectors,nb_RBs);
maxmin_power_allocation_matrix_per_user=zeros(total_nb_users,nb_sectors,nb_RBs);
distributed_gt_maxlog_power_allocation_matrix_per_user=zeros(total_nb_users,nb_sectors,nb_RBs);
for j=1:nb_sectors
    for i=BS(j).attached_users
        maxlog_power_allocation_matrix_per_user(i,j,:)=maxlog_power_allocation_matrix(j,:);
        maxmin_power_allocation_matrix_per_user(i,j,:)=maxmin_power_allocation_matrix(j,:);
        distributed_gt_maxlog_power_allocation_matrix_per_user(i,j,:)=distributed_gt_maxlog_power_allocation_matrix(j,:);
    end
end

maxlog_power_db_vector_per_user = 10*log10(reshape(maxlog_power_allocation_matrix_per_user, [], 1)./max_power_per_sector);
maxmin_power_db_vector_per_user = 10*log10(reshape(maxmin_power_allocation_matrix_per_user, [], 1)./max_power_per_sector);
distributed_gt_maxlog_power_db_vector_per_user = 10*log10(reshape(distributed_gt_maxlog_power_allocation_matrix_per_user, [], 1)./max_power_per_sector);

pathloss_db_vector = 10*log10(reshape(pathloss_matrix,[], 1));

save(result_file_name, 'netconfig', 'BS', 'pathloss_matrix', 'maxlog_sinr_db_vector',...
    'maxlog_sinr_db_sorted_vector', 'maxmin_sinr_db_vector', 'maxmin_sinr_db_sorted_vector', ... 
    'distributed_gt_maxlog_sinr_db_vector', 'distributed_gt_maxlog_sinr_db_sorted_vector', ... 
    'maxlog_power_db_vector', 'maxlog_power_db_sorted_vector', 'maxmin_power_db_vector', ...
    'maxmin_power_db_sorted_vector', 'distributed_gt_maxlog_power_db_vector', ... 
    'distributed_gt_maxlog_power_db_sorted_vector', 'maxlog_power_db_vector_per_user', ...
    'maxmin_power_db_vector_per_user', 'distributed_gt_maxlog_power_db_vector_per_user', 'pathloss_db_vector');