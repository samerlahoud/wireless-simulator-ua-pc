% Simulation main file
clear;
clc;
load_params;
%load('test_conditions');
%[BS,user,pathloss_matrix]=generate_radio_conditions;
%save('test_conditions','BS','user','pathloss_matrix');

nb_iterations=netconfig.nb_iterations;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compare spectral efficiency and energy efficiency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:nb_iterations
%         file_name = sprintf('./output/se-ee-results/results-compare-se-ee-%dusers-%dsectors-%dRBs-%.1fW-%dW-%drun.mat',...
%         netconfig.nb_users_per_sector,netconfig.nb_sectors,netconfig.nb_RBs,netconfig.min_power_per_RB,netconfig.max_power_per_sector,i);
%         load(file_name);
   [BS,user,pathloss_matrix]=generate_radio_conditions_v2;
   %[BS,user,pathloss_matrix]=generate_radio_conditions;
    complete_time = algo_compare_se_ee_gradient(BS, pathloss_matrix, i)
end
%plot_results_algo_compare_se_ee;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Testing real topology
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[BS,user,pathloss_matrix]=network_generation_test;
%netconfig.nb_sectors           = 18;
%netconfig.total_nb_users       = 100;
%central_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compare spectral efficiency aproaches MaxMin - MaxLog - GT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for i = 1:nb_iterations
%     [BS,user,pathloss_matrix]=generate_radio_conditions;
%     complete_time = algo_compare_maxsinr(BS, pathloss_matrix, i);
% end
%plot_results_algo_compare_maxsinr;

% Varying pmax
%complete_time = algo_compare_maxsinr_pmax(netconfig, [20, 30, 80]);