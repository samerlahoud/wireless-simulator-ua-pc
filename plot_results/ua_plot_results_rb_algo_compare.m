function ua_plot_results_rb_algo_compare
global netconfig;
nb_iterations = netconfig.nb_iterations;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;
nb_femto_BSs = netconfig.nb_femto_BSs;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_RBs = netconfig.nb_RBs;
nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;

output_dir = './output/user-association-output/';

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
cum_m1_macro_traffic = [];
cum_m1_femto_traffic = [];
cum_m1_mmwave_traffic = [];
cum_m2_macro_traffic = [];
cum_m2_femto_traffic = [];
cum_m2_mmwave_traffic = [];
cum_m3_macro_traffic = [];
cum_m3_femto_traffic = [];
cum_m3_mmwave_traffic = [];
cum_m4_macro_traffic = [];
cum_m4_femto_traffic = [];
cum_m4_mmwave_traffic = [];

cum_optimal_pf_sinr_rank = [];

for i = 1:nb_iterations
    load(sprintf('%s/rb-allocation-%dusers-%drun.mat', output_dir, nb_users, i));
    cum_sep_channel_optimal_pf_rate = [cum_sep_channel_optimal_pf_rate; sep_channel_optimal_pf_rate];
    cum_sep_channel_optimal_pf_obj = [cum_sep_channel_optimal_pf_obj; sep_channel_optimal_pf_obj];
    cum_sep_channel_optimal_pf_ua = [cum_sep_channel_optimal_pf_ua; sep_channel_optimal_pf_ua];
    cum_m1_macro_traffic = [cum_m1_macro_traffic; sum(sum(sep_channel_optimal_pf_ua(:,1:nb_macro_BSs)))];
    cum_m1_femto_traffic = [cum_m1_femto_traffic; sum(sum(sep_channel_optimal_pf_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m1_mmwave_traffic = [cum_m1_mmwave_traffic; sum(sum(sep_channel_optimal_pf_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    
    cum_co_channel_reuse1_optimal_pf_rate = [cum_co_channel_reuse1_optimal_pf_rate; co_channel_reuse1_optimal_pf_rate];
    cum_co_channel_reuse1_optimal_pf_obj = [cum_co_channel_reuse1_optimal_pf_obj; co_channel_reuse1_optimal_pf_obj];
    cum_co_channel_reuse1_optimal_pf_ua = [cum_co_channel_reuse1_optimal_pf_ua; co_channel_reuse1_optimal_pf_ua];
    cum_m2_macro_traffic = [cum_m2_macro_traffic; sum(sum(co_channel_reuse1_optimal_pf_ua(:,1:nb_macro_BSs)))];
    cum_m2_femto_traffic = [cum_m2_femto_traffic; sum(sum(co_channel_reuse1_optimal_pf_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m2_mmwave_traffic = [cum_m2_mmwave_traffic; sum(sum(co_channel_reuse1_optimal_pf_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    
    cum_reuse1_random_optimal_pf_rate = [cum_reuse1_random_optimal_pf_rate; reuse1_random_optimal_pf_rate];
    cum_reuse1_random_optimal_pf_obj = [cum_reuse1_random_optimal_pf_obj; reuse1_random_optimal_pf_obj];
    cum_reuse1_random_optimal_pf_ua = [cum_reuse1_random_optimal_pf_ua; reuse1_random_optimal_pf_ua];
    cum_m3_macro_traffic = [cum_m3_macro_traffic; sum(sum(reuse1_random_optimal_pf_ua(:,1:nb_macro_BSs)))];
    cum_m3_femto_traffic = [cum_m3_femto_traffic; sum(sum(reuse1_random_optimal_pf_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m3_mmwave_traffic = [cum_m3_mmwave_traffic; sum(sum(reuse1_random_optimal_pf_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    
    cum_reuse1_best_response_optimal_pf_rate = [cum_reuse1_best_response_optimal_pf_rate; reuse1_best_response_optimal_pf_rate];
    cum_reuse1_best_response_optimal_pf_obj = [cum_reuse1_best_response_optimal_pf_obj; reuse1_best_response_optimal_pf_obj];
    cum_reuse1_best_response_optimal_pf_ua = [cum_reuse1_best_response_optimal_pf_ua; reuse1_best_response_optimal_pf_ua];
    cum_m4_macro_traffic = [cum_m4_macro_traffic; sum(sum(reuse1_best_response_optimal_pf_ua(:,1:nb_macro_BSs)))];
    cum_m4_femto_traffic = [cum_m4_femto_traffic; sum(sum(reuse1_best_response_optimal_pf_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m4_mmwave_traffic = [cum_m4_mmwave_traffic; sum(sum(reuse1_best_response_optimal_pf_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];

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

% Plot results
figure_file_name = sprintf('-%dusers',nb_users);

f=figure;

y = [mean(cum_m1_macro_traffic),mean(cum_m1_femto_traffic),mean(cum_m1_mmwave_traffic); ...
    mean(cum_m2_macro_traffic),mean(cum_m2_femto_traffic),mean(cum_m2_mmwave_traffic); ...
    mean(cum_m3_macro_traffic),mean(cum_m3_femto_traffic),mean(cum_m3_mmwave_traffic); ...
    mean(cum_m4_macro_traffic),mean(cum_m4_femto_traffic),mean(cum_m4_mmwave_traffic)]...
    *(100./nb_users);

errY = [std(cum_m1_macro_traffic),std(cum_m1_femto_traffic),std(cum_m1_mmwave_traffic); ...
    std(cum_m2_macro_traffic),std(cum_m2_femto_traffic),std(cum_m2_mmwave_traffic); ...
    std(cum_m3_macro_traffic),std(cum_m3_femto_traffic),std(cum_m3_mmwave_traffic); ...
    std(cum_m4_macro_traffic),std(cum_m4_femto_traffic),std(cum_m4_mmwave_traffic)]...
    *(100./nb_users);

h = barwitherr(errY, y);% Plot with errorbars

set(gca,'XTickLabel',{'Sep-ch+SINR', 'Co-ch+SINR', 'Random+SINR', 'BR+SINR'})
legend('Macro','Femto','mmWave')
ylabel('Percentage of traffic')
set(h(1),'FaceColor','k');
ylim([0 110])
print(f,'-depsc', sprintf('%s/rb-ua-traffic-perc%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-traffic-perc%s.fig', output_dir, figure_file_name));