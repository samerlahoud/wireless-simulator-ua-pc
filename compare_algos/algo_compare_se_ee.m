function [complete_time]=algo_compare_se_ee(BS, pathloss_matrix, run_instance)
global netconfig;
nb_sectors=netconfig.nb_sectors;
nb_users_per_sector=netconfig.nb_users_per_sector;
nb_RBs=netconfig.nb_RBs;
max_power_per_sector=netconfig.max_power_per_sector;
min_power_per_RB=netconfig.min_power_per_RB;

result_file_name = sprintf('./output/se-ee-results/results-compare-se-ee-%dusers-%dsectors-%dRBs-%.1fW-%dW-%drun.mat',...
    nb_users_per_sector,nb_sectors,nb_RBs,min_power_per_RB,max_power_per_sector,run_instance);

tic
%[time_allocation] = central_max_sinr_scheduling_rb_gp(netconfig,pathloss_matrix,BS);
[ee_power_allocation_matrix,ee_sinr_matrix] = ...
    central_ee_maxlog_sinr_power_allocation_rb_gp(pathloss_matrix, BS);
[maxlog_power_allocation_matrix,maxlog_sinr_matrix] = ...
    central_maxlog_sinr_power_allocation_rb_gp(pathloss_matrix, BS);
complete_time=toc;

save(result_file_name, 'netconfig', 'BS', 'pathloss_matrix', 'ee_power_allocation_matrix', ...
    'ee_sinr_matrix', 'maxlog_power_allocation_matrix', 'maxlog_sinr_matrix');