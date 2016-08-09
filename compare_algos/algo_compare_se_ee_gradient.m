function [complete_time]=algo_compare_se_ee_gradient(BS, pathloss_matrix, run_instance)
global netconfig;
nb_sectors=netconfig.nb_sectors;
nb_users_per_sector=netconfig.nb_users_per_sector;
nb_RBs=netconfig.nb_RBs;
max_power_per_sector=netconfig.max_power_per_sector;
min_power_per_RB=netconfig.min_power_per_RB;

result_file_name = sprintf('./output/results-compare-se-ee-%dusers-%dsectors-%dRBs-%.1fW-%dW-%drun.mat',...
    nb_users_per_sector,nb_sectors,nb_RBs,min_power_per_RB,max_power_per_sector,run_instance);

tic
%[time_allocation] = central_max_sinr_scheduling_rb_gp(netconfig,pathloss_matrix,BS);

[ee_power_allocation_matrix,ee_sinr_matrix,ee_time_structure] = ...
   central_ee_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS);
[maxlog_power_allocation_matrix,maxlog_sinr_matrix] = ...
   central_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS);
[gt_power_allocation_matrix,gt_sinr_matrix,gt_time_structure] = ...
    distributed_gt_ee_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS);

% heuristics

[ee_nointerf_power_allocation_matrix,ee_nointerf_sinr_matrix] = ...
    central_ee_maxlog_sinr_nointerf_power_allocation_gradient(pathloss_matrix, BS);

pmax_power_allocation_matrix=(max_power_per_sector/nb_RBs).*ones(nb_sectors,nb_RBs);
pmax_sinr_matrix = sinr_computation(pathloss_matrix, BS, pmax_power_allocation_matrix);

pmin_power_allocation_matrix=min_power_per_RB.*ones(nb_sectors,nb_RBs);
pmin_sinr_matrix = sinr_computation(pathloss_matrix, BS, pmin_power_allocation_matrix);

complete_time=toc;

save(result_file_name, 'netconfig', 'BS', 'pathloss_matrix', ...
   'ee_power_allocation_matrix', 'ee_sinr_matrix', 'ee_time_structure', ...
   'maxlog_power_allocation_matrix', 'maxlog_sinr_matrix', ...
   'pmax_power_allocation_matrix', 'pmax_sinr_matrix', 'pmin_power_allocation_matrix', ...
   'pmin_sinr_matrix','ee_nointerf_power_allocation_matrix','ee_nointerf_sinr_matrix', ...
   'gt_power_allocation_matrix','gt_sinr_matrix', 'gt_time_structure');

%save(result_file_name, 'gt_power_allocation_matrix','gt_sinr_matrix', '-append');