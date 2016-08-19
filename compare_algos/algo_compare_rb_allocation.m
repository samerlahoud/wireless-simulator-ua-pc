function [] = algo_compare_rb_allocation(pathloss, BS_to_BS_pathloss, femto_demand, run_instance)
global netconfig;

nb_users = netconfig.nb_users;

[sep_channel_RB_allocation] = rb_allocation_sep_channel_reuse1_hetnet();
[sep_channel_peak_rate, sep_channel_sinr] = ua_hetnet_initial_sinr_computation(pathloss, sep_channel_RB_allocation);
%sep_channel_optimal_pf_ua = optimal_pf_association_hetnet(sep_channel_peak_rate);
sep_channel_optimal_pf_ua = sinr_based_association_hetnet(sep_channel_sinr);
[sep_channel_optimal_pf_rate, sep_channel_optimal_pf_obj] = ua_hetnet_objective_computation(sep_channel_peak_rate, sep_channel_optimal_pf_ua);

[co_channel_reuse1_RB_allocation] = rb_allocation_co_channel_reuse1_hetnet();
[co_channel_reuse1_peak_rate, co_channel_reuse1_sinr] = ua_hetnet_initial_sinr_computation(pathloss, co_channel_reuse1_RB_allocation);
%co_channel_reuse1_optimal_pf_ua = optimal_pf_association_hetnet(co_channel_reuse1_peak_rate);
co_channel_reuse1_optimal_pf_ua = sinr_based_association_hetnet(co_channel_reuse1_sinr);
[co_channel_reuse1_optimal_pf_rate, co_channel_reuse1_optimal_pf_obj] = ua_hetnet_objective_computation(co_channel_reuse1_peak_rate, co_channel_reuse1_optimal_pf_ua);

[reuse1_random_RB_allocation] = rb_allocation_reuse1_random_hetnet(femto_demand);
[reuse1_random_peak_rate, reuse1_random_sinr] = ua_hetnet_initial_sinr_computation(pathloss, reuse1_random_RB_allocation);
%reuse1_random_optimal_pf_ua = optimal_pf_association_hetnet(reuse1_random_peak_rate);
reuse1_random_optimal_pf_ua = sinr_based_association_hetnet(reuse1_random_sinr);
[reuse1_random_optimal_pf_rate, reuse1_random_optimal_pf_obj] = ua_hetnet_objective_computation(reuse1_random_peak_rate, reuse1_random_optimal_pf_ua);

[reuse1_best_response_RB_allocation, nb_rounds] = rb_allocation_reuse1_best_response_hetnet(BS_to_BS_pathloss, femto_demand);
[reuse1_best_response_peak_rate, reuse1_best_response_sinr] = ua_hetnet_initial_sinr_computation(pathloss, reuse1_best_response_RB_allocation);
%reuse1_best_response_optimal_pf_ua = optimal_pf_association_hetnet(reuse1_best_response_peak_rate);
reuse1_best_response_optimal_pf_ua = sinr_based_association_hetnet(reuse1_best_response_sinr);
[reuse1_best_response_optimal_pf_rate, reuse1_best_response_optimal_pf_obj] = ua_hetnet_objective_computation(reuse1_best_response_peak_rate, reuse1_best_response_optimal_pf_ua);

result_file_name = sprintf('./output/user-association-output/rb-allocation-%dusers-%drun.mat', nb_users, run_instance);

save(result_file_name, 'sep_channel_optimal_pf_ua', 'sep_channel_optimal_pf_rate', 'sep_channel_optimal_pf_obj', ...
    'sep_channel_peak_rate', 'sep_channel_sinr', 'sep_channel_RB_allocation', ...
    'co_channel_reuse1_optimal_pf_ua', 'co_channel_reuse1_optimal_pf_rate', 'co_channel_reuse1_optimal_pf_obj', ...
    'co_channel_reuse1_peak_rate', 'co_channel_reuse1_sinr', 'co_channel_reuse1_RB_allocation', ...    
    'reuse1_random_optimal_pf_ua', 'reuse1_random_optimal_pf_rate', 'reuse1_random_optimal_pf_obj', ...
    'reuse1_random_peak_rate', 'reuse1_random_sinr', 'reuse1_random_RB_allocation', ...     
    'reuse1_best_response_optimal_pf_ua', 'reuse1_best_response_optimal_pf_rate', 'reuse1_best_response_optimal_pf_obj', ...
    'reuse1_best_response_peak_rate', 'reuse1_best_response_sinr', 'reuse1_best_response_RB_allocation');
end

