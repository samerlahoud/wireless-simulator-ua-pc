function ua_plot_results_rb_algo_compare
global netconfig;
nb_iterations = netconfig.nb_iterations;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;
nb_femto_BSs = netconfig.nb_femto_BSs;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_RBs = netconfig.nb_RBs;

output_dir = './output/user-association-output/rb-100users-cluster';

cum_sep_channel_optimal_pf_rate = [];
cum_sep_channel_optimal_pf_obj = [];
cum_sep_channel_optimal_pf_ua = [];
cum_co_channel_reuse1_optimal_pf_rate = [];
cum_co_channel_reuse1_optimal_pf_obj = [];
cum_co_channel_reuse1_optimal_pf_ua = [];
cum_reuse1_random_optimal_pf_rate = [];
cum_reuse1_random_optimal_pf_obj = [];
cum_reuse1_random_optimal_pf_ua = [];
cum_reuse1_best_response_optimal_pf_rate = [];
cum_reuse1_best_response_optimal_pf_obj = [];
cum_reuse1_best_response_optimal_pf_ua = [];

cum_optimal_pf_sinr_rank = [];

for i = 1:nb_iterations
    load(sprintf('%s/rb-allocation-%dusers-%drun.mat', output_dir, nb_users, i));
    cum_sep_channel_optimal_pf_rate = [cum_sep_channel_optimal_pf_rate; sep_channel_optimal_pf_rate];
    cum_sep_channel_optimal_pf_obj = [cum_sep_channel_optimal_pf_obj; sep_channel_optimal_pf_obj];
    cum_sep_channel_optimal_pf_ua = [cum_sep_channel_optimal_pf_ua; sep_channel_optimal_pf_ua];
    
    cum_co_channel_reuse1_optimal_pf_rate = [cum_co_channel_reuse1_optimal_pf_rate; co_channel_reuse1_optimal_pf_rate];
    cum_co_channel_reuse1_optimal_pf_obj = [cum_co_channel_reuse1_optimal_pf_obj; co_channel_reuse1_optimal_pf_obj];
    cum_co_channel_reuse1_optimal_pf_ua = [cum_co_channel_reuse1_optimal_pf_ua; co_channel_reuse1_optimal_pf_ua];
    
    cum_reuse1_random_optimal_pf_rate = [cum_reuse1_random_optimal_pf_rate; reuse1_random_optimal_pf_rate];
    cum_reuse1_random_optimal_pf_obj = [cum_reuse1_random_optimal_pf_obj; reuse1_random_optimal_pf_obj];
    cum_reuse1_random_optimal_pf_ua = [cum_reuse1_random_optimal_pf_ua; reuse1_random_optimal_pf_ua];
    
    cum_reuse1_best_response_optimal_pf_rate = [cum_reuse1_best_response_optimal_pf_rate; reuse1_best_response_optimal_pf_rate];
    cum_reuse1_best_response_optimal_pf_obj = [cum_reuse1_best_response_optimal_pf_obj; reuse1_best_response_optimal_pf_obj];
    cum_reuse1_best_response_optimal_pf_ua = [cum_reuse1_best_response_optimal_pf_ua; reuse1_best_response_optimal_pf_ua];

end

% Plot results
figure_file_name = sprintf('-%dusers',nb_users);

f=figure;
boxplot([cum_reuse1_best_response_optimal_pf_obj, cum_sep_channel_optimal_pf_obj, cum_co_channel_reuse1_optimal_pf_obj, cum_reuse1_random_optimal_pf_obj],...
    'notch', 'off', 'Label', {'BR', 'Sep-Channel', 'Co-Channel', 'Random'});
ylabel('Objective');
print(f,'-depsc', sprintf('%s/rb-boxplot-objective%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-boxplot-objective%s.fig', output_dir, figure_file_name));

f=figure; 
%h=cdfplot(cum_reuse1_best_response_optimal_pf_rate/(nb_RBs*1e6/5));
h=cdfplot(cum_reuse1_best_response_optimal_pf_rate/1e6);
set(h,'color','c','LineWidth',2)
hold on;
%h=cdfplot(cum_sep_channel_optimal_pf_rate/(nb_RBs*1e6/5));
h=cdfplot(cum_sep_channel_optimal_pf_rate(cum_sep_channel_optimal_pf_rate>0)/1e6);
set(h,'color','r','LineWidth',2)
%h=cdfplot(cum_co_channel_reuse1_optimal_pf_rate/(nb_RBs*1e6/5));
h=cdfplot(cum_co_channel_reuse1_optimal_pf_rate(cum_co_channel_reuse1_optimal_pf_rate>0)/1e6);
set(h,'color','b','LineWidth',2)
%h=cdfplot(cum_reuse1_random_optimal_pf_rate/(nb_RBs*1e6/5));
h=cdfplot(cum_reuse1_random_optimal_pf_rate/1e6);
set(h,'color','g','LineWidth',2)
title('Rate distribution');
ylabel('CDF');
xlabel('Rate (Mbits/s)');
set(gca,'XScale','log');
legend({'BR', 'Sep-Channel', 'Co-Channel', 'Random'}, 'Location', 'SouthEast');
hold off;
print(f,'-depsc', sprintf('%s/rb-cdf-rate%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-cdf-rate%s.fig', output_dir, figure_file_name));