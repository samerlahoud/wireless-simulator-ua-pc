function [] = algo_compare_rb_ua_allocation(pathloss, BS_to_BS_pathloss, femto_demand, run_instance)
global netconfig;

nb_users = netconfig.nb_users;

% Best response RB allocation + BR UA
[m1_RB_allocation, m1_nb_rounds] = rb_allocation_reuse1_best_response_hetnet(BS_to_BS_pathloss, femto_demand);
[m1_peak_rate, m1_sinr, m1_rx_RB_power] = ua_hetnet_initial_sinr_computation(pathloss, m1_RB_allocation);
m1_ua = best_response_pf_association_hetnet_gradient(m1_peak_rate); %% This is the slowest algorithm to converge
[m1_rate, m1_obj] = ua_hetnet_objective_computation(m1_peak_rate, m1_ua);

% Best response RB allocation + optimal UA
%[m2_RB_allocation, m2_nb_rounds] = rb_allocation_reuse1_best_response_hetnet(BS_to_BS_pathloss, femto_demand);
%[m2_peak_rate, m2_sinr] = ua_hetnet_initial_sinr_computation(pathloss, m2_RB_allocation);
m2_RB_allocation = m1_RB_allocation;
m2_nb_rounds = m1_nb_rounds;
m2_peak_rate = m1_peak_rate;
m2_sinr = m1_sinr;
m2_ua = optimal_pf_association_hetnet(m2_peak_rate);
[m2_rate, m2_obj] = ua_hetnet_objective_computation(m2_peak_rate, m2_ua);

% Random RB allocation + SINR-based UA
[m3_RB_allocation] = rb_allocation_reuse1_random_hetnet(femto_demand);
[m3_peak_rate, m3_sinr, m3_rx_RB_power] = ua_hetnet_initial_sinr_computation(pathloss, m3_RB_allocation);
%m3_ua = sinr_based_association_hetnet(m3_sinr);
m3_ua = power_based_association_hetnet(m3_rx_RB_power);
[m3_rate, m3_obj] = ua_hetnet_objective_computation(m3_peak_rate, m3_ua);

% Sep-channel RB allocation + SC-First UA
[m4_RB_allocation] = rb_allocation_sep_channel_reuse1_hetnet();
[m4_peak_rate, m4_sinr, m4_rx_RB_power] = ua_hetnet_initial_sinr_computation(pathloss, m4_RB_allocation);
m4_ua = small_cell_first_association_hetnet(m4_sinr);
[m4_rate, m4_obj] = ua_hetnet_objective_computation(m4_peak_rate, m4_ua);

% Co-channel RB allocation + SINR-based UA
[m5_RB_allocation] = rb_allocation_co_channel_reuse1_hetnet();
[m5_peak_rate, m5_sinr, m5_rx_RB_power] = ua_hetnet_initial_sinr_computation(pathloss, m5_RB_allocation);
%m5_ua = sinr_based_association_hetnet(m5_sinr);
m5_ua = power_based_association_hetnet(m5_rx_RB_power);
[m5_rate, m5_obj] = ua_hetnet_objective_computation(m5_peak_rate, m5_ua);

% Best response RB allocation + SINR-Based UA
m6_RB_allocation = m1_RB_allocation;
m6_nb_rounds = m1_nb_rounds;
m6_peak_rate = m1_peak_rate;
m6_rx_RB_power = m1_rx_RB_power;
m6_sinr = m1_sinr;
m6_ua = power_based_association_hetnet(m6_rx_RB_power);
[m6_rate, m6_obj] = ua_hetnet_objective_computation(m6_peak_rate, m6_ua);

result_file_name = sprintf('./output/user-association-output/rb-ua-allocation-%dusers-%drun.mat', nb_users, run_instance);

save(result_file_name, 'm1_RB_allocation', 'm1_peak_rate', 'm1_sinr', 'm1_ua', 'm1_rate', 'm1_obj', 'm1_nb_rounds', ...
    'm2_RB_allocation', 'm2_peak_rate', 'm2_sinr', 'm2_ua', 'm2_rate', 'm2_obj', 'm2_nb_rounds', ...
    'm3_RB_allocation', 'm3_peak_rate', 'm3_sinr', 'm3_ua', 'm3_rate', 'm3_obj', ...
    'm4_RB_allocation', 'm4_peak_rate', 'm4_sinr', 'm4_ua', 'm4_rate', 'm4_obj', ...
    'm5_RB_allocation', 'm5_peak_rate', 'm5_sinr', 'm5_ua', 'm5_rate', 'm5_obj', ...
    'm6_RB_allocation', 'm6_peak_rate', 'm6_sinr', 'm6_ua', 'm6_rate', 'm6_obj', ...
    'm1_rx_RB_power', 'm3_rx_RB_power', 'm4_rx_RB_power', 'm5_rx_RB_power');
end

