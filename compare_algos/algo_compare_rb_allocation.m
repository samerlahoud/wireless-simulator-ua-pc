function [] = algo_compare_rb_allocation(rx_power, BS_to_BS_pathloss, femto_demand, run_instance)
global netconfig;

nb_users = netconfig.nb_users;

m1_rx_RB_power = rx_power;
m2_rx_RB_power = rx_power;

% Best response RB allocation + Pow-UA
[m1_RB_allocation, m1_nb_rounds] = rb_allocation_reuse1_best_response_hetnet(BS_to_BS_pathloss, femto_demand);
[m1_peak_rate, m1_sinr] = ua_hetnet_initial_sinr_computation(rx_power, m1_RB_allocation);
m1_ua = power_based_association_hetnet(m1_rx_RB_power);
[m1_rate, m1_obj] = ua_hetnet_objective_computation(m1_peak_rate, m1_ua);

% Co-channel RB allocation + Pow-UA
[m2_RB_allocation] = rb_allocation_co_channel_reuse1_hetnet();
[m2_peak_rate, m2_sinr] = ua_hetnet_initial_sinr_computation(rx_power, m2_RB_allocation);
m2_ua = power_based_association_hetnet(m2_rx_RB_power);
[m2_rate, m2_obj] = ua_hetnet_objective_computation(m2_peak_rate, m2_ua);

result_file_name = sprintf('./output/user-association-output/rb-allocation-%dusers-%drun.mat', nb_users, run_instance);

save(result_file_name, 'm1_RB_allocation', 'm1_peak_rate', 'm1_sinr', 'm1_ua', ...
    'm1_rate', 'm1_obj', 'm1_nb_rounds', 'm1_rx_RB_power', ...
    'm2_RB_allocation', 'm2_peak_rate', 'm2_sinr', 'm2_ua', 'm2_rate', 'm2_obj', 'm2_rx_RB_power');
end

