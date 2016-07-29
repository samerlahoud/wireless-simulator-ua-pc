function [cum_min_power_ee,cum_max_power_ee]=algo_compare_se_ee_pmax_gradient(BS, pathloss_matrix)
global netconfig;
nb_sectors=netconfig.nb_sectors;
nb_users_per_sector=netconfig.nb_users_per_sector;
nb_RBs=netconfig.nb_RBs;
min_power_per_RB=netconfig.min_power_per_RB;
max_power_per_sector=netconfig.max_power_per_sector;
%result_file_name = sprintf('./output/results-compare-se-ee-%dusers-%dsectors-%dRBs-%.1fW-%dW-%drun.mat',...
%    nb_users_per_sector,nb_sectors,nb_RBs,min_power_per_RB,max_power_per_sector,run_instance);

cum_min_power_ee=[];
cum_max_power_ee=[];
for min_power_iter=0.1:0.4:2
    netconfig.min_power_per_RB=min_power_iter;
    [ee_power_allocation_matrix,ee_sinr_matrix] = ...
       central_ee_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS);
    [maxlog_power_allocation_matrix,maxlog_sinr_matrix] = ...
       central_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS);
    [gt_power_allocation_matrix,gt_sinr_matrix] = ...
        distributed_gt_ee_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS);
    maxlog_objective=ee_objective_computation(maxlog_sinr_matrix, maxlog_power_allocation_matrix);
    ee_objective=ee_objective_computation(ee_sinr_matrix, ee_power_allocation_matrix);
    gt_objective=ee_objective_computation(gt_sinr_matrix, gt_power_allocation_matrix);
    cum_min_power_ee=[cum_min_power_ee;ee_objective,gt_objective,maxlog_objective];
end

%Back to original params
load_params;

for max_power_iter=10:10:60
    netconfig.max_power_per_sector=max_power_iter;
    [ee_power_allocation_matrix,ee_sinr_matrix] = ...
       central_ee_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS);
    [maxlog_power_allocation_matrix,maxlog_sinr_matrix] = ...
       central_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS);
    [gt_power_allocation_matrix,gt_sinr_matrix] = ...
        distributed_gt_ee_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS);
    maxlog_objective=ee_objective_computation(maxlog_sinr_matrix, maxlog_power_allocation_matrix);
    ee_objective=ee_objective_computation(ee_sinr_matrix, ee_power_allocation_matrix);
    gt_objective=ee_objective_computation(gt_sinr_matrix, gt_power_allocation_matrix);
    cum_max_power_ee=[cum_max_power_ee;ee_objective,gt_objective,maxlog_objective];
end

figure;
plot([0.1:0.4:2],cum_min_power_ee,'x-');
legend({'Central-EE', 'Distributed-EE', 'Central-SE'}, 'Location', 'NorthEast');

figure;
plot([10:10:60],cum_max_power_ee,'x-');
legend({'Central-EE', 'Distributed-EE', 'Central-SE'}, 'Location', 'NorthEast');
% heuristics

% [ee_nointerf_power_allocation_matrix,ee_nointerf_sinr_matrix] = ...
%     central_ee_maxlog_sinr_nointerf_power_allocation_gradient(pathloss_matrix, BS);
% 
% pmax_power_allocation_matrix=(max_power_per_sector/nb_RBs).*ones(nb_sectors,nb_RBs);
% pmax_sinr_matrix = sinr_computation(pathloss_matrix, BS, pmax_power_allocation_matrix);
% 
% pmin_power_allocation_matrix=min_power_per_RB.*ones(nb_sectors,nb_RBs);
% pmin_sinr_matrix = sinr_computation(pathloss_matrix, BS, pmin_power_allocation_matrix);
% 
% complete_time=toc;
% 
% save(result_file_name, 'netconfig', 'BS', 'pathloss_matrix', ...
%    'ee_power_allocation_matrix', 'ee_sinr_matrix', ...
%    'maxlog_power_allocation_matrix', 'maxlog_sinr_matrix', ...
%    'pmax_power_allocation_matrix', 'pmax_sinr_matrix', 'pmin_power_allocation_matrix', ...
%    'pmin_sinr_matrix','ee_nointerf_power_allocation_matrix','ee_nointerf_sinr_matrix', ...
%    'gt_power_allocation_matrix','gt_sinr_matrix');

%save(result_file_name, 'gt_power_allocation_matrix','gt_sinr_matrix', '-append');