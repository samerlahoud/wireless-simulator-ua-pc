function []=algo_compare_ee_gee()
% Compare our precomputed algos with Venturino et al.

global netconfig;
total_nb_users=netconfig.total_nb_users;
nb_sectors=netconfig.nb_sectors;
nb_users_per_sector=netconfig.nb_users_per_sector;
nb_RBs=netconfig.nb_RBs;
max_power_per_sector=netconfig.max_power_per_sector;
min_power_per_RB=netconfig.min_power_per_RB;


for i=1:netconfig.nb_iterations
    load(sprintf('./output/1sector-is-500-user-50/results-compare-se-ee-%dusers-%dsectors-%dRBs-%.1fW-%dW-%drun.mat', ...
        nb_users_per_sector,nb_sectors,nb_RBs,min_power_per_RB, max_power_per_sector,i));
    [gee_power_allocation_matrix, gee_sinr_matrix] = central_gee_noise_limited_joint_scheduling_power_allocation_rb(pathloss_matrix, BS);
    
    result_file_name = sprintf('./output/results-compare-gee-ee-%dusers-%dsectors-%dRBs-%.1fW-%dW-%drun.mat',...
        nb_users_per_sector,nb_sectors,nb_RBs,min_power_per_RB,max_power_per_sector,i);
    
    save(result_file_name, 'netconfig', 'BS', 'pathloss_matrix', ...
        'gee_power_allocation_matrix', 'gee_sinr_matrix');
end