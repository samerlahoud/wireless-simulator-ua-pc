function [] = algo_compare_rb_ua_mimo_allocation(rx_power, BS_to_BS_pathloss, femto_demand, run_instance)
global netconfig;

nb_users = netconfig.nb_users;

m1_rx_RB_power = rx_power;

% Best response RB allocation + Optimal UA
[m1_RB_allocation, m1_nb_rounds] = rb_allocation_reuse1_best_response_hetnet(BS_to_BS_pathloss, femto_demand);
[m1_peak_rate, m1_sinr] = ua_hetnet_initial_sinr_computation(rx_power, m1_RB_allocation);
m1_ua = optimal_pf_association_hetnet(m1_peak_rate);
[m1_rate, m1_obj] = ua_hetnet_objective_computation(m1_peak_rate, m1_ua);

result_file_name = sprintf('./output/user-association-output/rb-ua-allocation-%dusers-%drun.mat', nb_users, run_instance);

save(result_file_name, 'm1_RB_allocation', 'm1_peak_rate', 'm1_sinr', 'm1_ua', 'm1_rate', 'm1_obj', ...
    'm1_nb_rounds', 'm1_rx_RB_power');
end

