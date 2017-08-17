function [] = algo_compare_user_association(peak_rate, sinr, run_instance)
global netconfig;

nb_users = netconfig.nb_users;

sinr_based_ua = sinr_based_association_hetnet(sinr);
[sinr_based_rate, sinr_based_obj] = ua_hetnet_objective_computation(peak_rate, sinr_based_ua);
range_ext_ua = range_extension_association_hetnet(sinr);
[range_ext_rate, range_ext_obj] = ua_hetnet_objective_computation(peak_rate, range_ext_ua);
small_cell_first_ua = small_cell_first_association_hetnet(sinr);
[small_cell_first_rate, small_cell_first_obj] = ua_hetnet_objective_computation(peak_rate, small_cell_first_ua);
optimal_pf_ua = optimal_pf_association_hetnet(peak_rate);
[optimal_pf_rate, optimal_pf_obj] = ua_hetnet_objective_computation(peak_rate, optimal_pf_ua);
[br_pf_ua, nb_rounds] = best_response_pf_association_hetnet_gradient(peak_rate);
[br_pf_rate, br_pf_obj] = ua_hetnet_objective_computation(peak_rate, br_pf_ua);

result_file_name = sprintf('./output/user-association-output/user-association-%dusers-%drun.mat', nb_users, run_instance);

save(result_file_name, 'sinr_based_ua', 'sinr_based_rate', 'sinr_based_obj', ...
    'range_ext_ua', 'range_ext_rate', 'range_ext_obj', ...
    'small_cell_first_ua', 'small_cell_first_rate', 'small_cell_first_obj', ...
    'optimal_pf_ua', 'optimal_pf_rate', 'optimal_pf_obj', ...
    'br_pf_ua', 'br_pf_rate', 'br_pf_obj', 'nb_rounds');
end

