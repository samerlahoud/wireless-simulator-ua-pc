% Simulation main file
clear;
clc;
load_hetnet_params;

nb_iterations = netconfig.nb_iterations;
nb_users = netconfig.nb_users;
nb_RBs = netconfig.nb_RBs;
reuse_min_pathloss = netconfig.reuse_min_pathloss;
%nb_femto_RBs = netconfig.nb_femto_RBs;

%% Compare UAs with BR RB allocation
% for i = 1:nb_iterations
%     [BS_abs, BS_ord, user_abs, user_ord, pathloss, BS_to_BS_pathloss]=generate_hetnet_radio_conditions_femto_mmwave;
%     [femto_demand] = ua_femto_demand_computation(pathloss, BS_to_BS_pathloss, reuse_min_pathloss, nb_RBs/2);    
%     [RB_allocation, nb_rounds] = rb_allocation_reuse1_best_response_hetnet(BS_to_BS_pathloss, femto_demand);
%     [peak_rate, sinr] = ua_hetnet_initial_sinr_computation(pathloss, RB_allocation);
%     algo_compare_user_association(peak_rate, sinr, i);
%     result_file_name = sprintf('./output/user-association-output/radio-conditions-%dusers-%drun.mat', nb_users, i);
%     save(result_file_name, 'netconfig', 'BS_abs', 'BS_ord', 'user_abs', 'user_ord', ...
%     'pathloss', 'BS_to_BS_pathloss', 'peak_rate', 'sinr', 'femto_demand', 'RB_allocation');
% end

% Compare RB allocation with opitmal UA
% for i = 1:nb_iterations
%     [BS_abs, BS_ord, user_abs, user_ord, pathloss, BS_to_BS_pathloss]=generate_hetnet_radio_conditions_femto_mmwave;
%     [femto_demand] = ua_femto_demand_computation(pathloss, BS_to_BS_pathloss, reuse_min_pathloss, nb_RBs/2);
%     %load(sprintf('./output/user-association-output/rb-100users-cluster/radio-conditions-%dusers-%drun.mat', nb_users, i));
%     algo_compare_rb_allocation(pathloss, BS_to_BS_pathloss, femto_demand, i);
%     result_file_name = sprintf('./output/user-association-output/radio-conditions-%dusers-%drun.mat', nb_users, i);
%     save(result_file_name, 'netconfig', 'BS_abs', 'BS_ord', 'user_abs', 'user_ord', ...
%     'pathloss', 'BS_to_BS_pathloss', 'femto_demand');
% end

% Compare RB allocation with Pow-UA
for i = 1:nb_iterations
    [BS_abs, BS_ord, user_abs, user_ord, pathloss, BS_to_BS_pathloss, rx_power]=enerate_hetnet_radio_conditions_femto_mmwave_variable;
    [femto_demand] = ua_demand_computation(rx_power, BS_to_BS_pathloss, reuse_min_pathloss);
    algo_compare_rb_allocation(rx_power, BS_to_BS_pathloss, femto_demand, i);
    result_file_name = sprintf('./output/user-association-output/radio-conditions-%dusers-%drun.mat', nb_users, i);
    save(result_file_name, 'netconfig', 'BS_abs', 'BS_ord', 'user_abs', 'user_ord', ...
    'pathloss', 'BS_to_BS_pathloss', 'femto_demand');
end

%% Compare Selected RB allocation and UA
% % for i = 1:nb_iterations
% %     [BS_abs, BS_ord, user_abs, user_ord, pathloss, BS_to_BS_pathloss, rx_power]=generate_hetnet_radio_conditions_femto_mmwave_variable;
% %     [femto_demand] = ua_demand_computation(rx_power, BS_to_BS_pathloss, reuse_min_pathloss);
% %     algo_compare_rb_ua_allocation(rx_power, BS_to_BS_pathloss, femto_demand, i);
% %     result_file_name = sprintf('./output/user-association-output/radio-conditions-%dusers-%drun.mat', nb_users, i);
% %     save(result_file_name, 'netconfig', 'BS_abs', 'BS_ord', 'user_abs', 'user_ord', ...
% %     'pathloss', 'BS_to_BS_pathloss', 'femto_demand');
% % end

%% Use same radio conditions to compare clustering
% for i = 1:nb_iterations
%     load(sprintf('./output/user-association-output/radio-conditions-100users-%drun', i));
%     netconfig.reuse_min_pathloss = reuse_min_pathloss;
%     [femto_demand] = ua_demand_computation(rx_power, BS_to_BS_pathloss, reuse_min_pathloss);
%     algo_compare_rb_ua_allocation(rx_power, BS_to_BS_pathloss, femto_demand, i);
%     result_file_name = sprintf('./output/user-association-output/radio-conditions-%dusers-%drun.mat', nb_users, i);
%     save(result_file_name, 'netconfig', 'BS_abs', 'BS_ord', 'user_abs', 'user_ord', ...
%     'pathloss', 'BS_to_BS_pathloss', 'femto_demand');
% end

%plot_user_association;
