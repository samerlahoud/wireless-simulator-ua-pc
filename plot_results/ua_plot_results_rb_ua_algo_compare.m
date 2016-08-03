function ua_plot_results_rb_ua_algo_compare
global netconfig;
nb_iterations = netconfig.nb_iterations;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;
nb_femto_BSs = netconfig.nb_femto_BSs;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_macro_femto_BS = netconfig.nb_macro_femto_BSs;
nb_RBs = netconfig.nb_RBs;

output_dir = './output/user-association-output/';

cum_m1_rate = [];
cum_m1_obj = [];
cum_m1_ua = [];
cum_m1_macro_traffic = [];
cum_m1_femto_traffic = [];
cum_m1_mmwave_traffic = [];
cum_m2_rate = [];
cum_m2_obj = [];
cum_m2_ua = [];
cum_m2_macro_traffic = [];
cum_m2_femto_traffic = [];
cum_m2_mmwave_traffic = [];
cum_m3_rate = [];
cum_m3_obj = [];
cum_m3_ua = [];
cum_m3_macro_traffic = [];
cum_m3_femto_traffic = [];
cum_m3_mmwave_traffic = [];
cum_m4_rate = [];
cum_m4_obj = [];
cum_m4_ua = [];
cum_m4_macro_traffic = [];
cum_m4_femto_traffic = [];
cum_m4_mmwave_traffic = [];
cum_m5_rate = [];
cum_m5_obj = [];
cum_m5_ua = [];
cum_m5_macro_traffic = [];
cum_m5_femto_traffic = [];
cum_m5_mmwave_traffic = [];

cum_optimal_pf_sinr_rank = [];

for i = 1:nb_iterations
    load(sprintf('%s/rb-ua-allocation-%dusers-%drun.mat', output_dir, nb_users, i));
    cum_m1_rate = [cum_m1_rate; m1_rate];
    cum_m1_obj = [cum_m1_obj; m1_obj];
    cum_m1_ua = [cum_m1_ua; m1_ua];
    cum_m1_macro_traffic = [cum_m1_macro_traffic; sum(sum(m1_ua(:,1:nb_macro_BSs)))];
    cum_m1_femto_traffic = [cum_m1_femto_traffic; sum(sum(m1_ua(:,nb_macro_BSs+1:nb_macro_femto_BS)))];
    cum_m1_mmwave_traffic = [cum_m1_mmwave_traffic; sum(sum(m1_ua(:,nb_macro_femto_BS+1:nb_BSs)))];
    
    cum_m2_rate = [cum_m2_rate; m2_rate];
    cum_m2_obj = [cum_m2_obj; m2_obj];
    cum_m2_ua = [cum_m2_ua; m2_ua];
    cum_m2_macro_traffic = [cum_m2_macro_traffic; sum(sum(m2_ua(:,1:nb_macro_BSs)))];
    cum_m2_femto_traffic = [cum_m2_femto_traffic; sum(sum(m2_ua(:,nb_macro_BSs+1:nb_macro_femto_BS)))];
    cum_m2_mmwave_traffic = [cum_m2_mmwave_traffic; sum(sum(m2_ua(:,nb_macro_femto_BS+1:nb_BSs)))];
    
    cum_m3_rate = [cum_m3_rate; m3_rate];
    cum_m3_obj = [cum_m3_obj; m3_obj];
    cum_m3_ua = [cum_m3_ua; m3_ua];
    cum_m3_macro_traffic = [cum_m3_macro_traffic; sum(sum(m3_ua(:,1:nb_macro_BSs)))];
    cum_m3_femto_traffic = [cum_m3_femto_traffic; sum(sum(m3_ua(:,nb_macro_BSs+1:nb_macro_femto_BS)))];
    cum_m3_mmwave_traffic = [cum_m3_mmwave_traffic; sum(sum(m3_ua(:,nb_macro_femto_BS+1:nb_BSs)))];
    
    cum_m4_rate = [cum_m4_rate; m4_rate];
    cum_m4_obj = [cum_m4_obj; m4_obj];
    cum_m4_ua = [cum_m4_ua; m4_ua];
    cum_m4_macro_traffic = [cum_m4_macro_traffic; sum(sum(m4_ua(:,1:nb_macro_BSs)))];
    cum_m4_femto_traffic = [cum_m4_femto_traffic; sum(sum(m4_ua(:,nb_macro_BSs+1:nb_macro_femto_BS)))];
    cum_m4_mmwave_traffic = [cum_m4_mmwave_traffic; sum(sum(m4_ua(:,nb_macro_femto_BS+1:nb_BSs)))];
    
    cum_m5_rate = [cum_m5_rate; m5_rate];
    cum_m5_obj = [cum_m5_obj; m5_obj];
    cum_m5_ua = [cum_m5_ua; m5_ua];
    cum_m5_macro_traffic = [cum_m5_macro_traffic; sum(sum(m5_ua(:,1:nb_macro_BSs)))];
    cum_m5_femto_traffic = [cum_m5_femto_traffic; sum(sum(m5_ua(:,nb_macro_BSs+1:nb_macro_femto_BS)))];
    cum_m5_mmwave_traffic = [cum_m5_mmwave_traffic; sum(sum(m5_ua(:,nb_macro_femto_BS+1:nb_BSs)))];

end

% Plot results
figure_file_name = sprintf('-%dusers',nb_users);

f=figure;
boxplot([cum_m1_macro_traffic, cum_m2_macro_traffic, cum_m3_macro_traffic, cum_m4_macro_traffic, cum_m5_macro_traffic],...
    'notch', 'off', 'Label', {'BR+BR', 'BR+Optim', 'Random+SINR', 'Sep-ch+Femto-First', 'Co-ch+SINR'});
ylabel('Percentage of traffic on macro BSs');
print(f,'-depsc', sprintf('%s/rb-ua-macro-traffic%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-macro-traffic%s.fig', output_dir, figure_file_name));

f=figure;
boxplot([cum_m1_femto_traffic, cum_m2_femto_traffic, cum_m3_femto_traffic, cum_m4_femto_traffic, cum_m5_femto_traffic],...
    'notch', 'off', 'Label', {'BR+BR', 'BR+Optim', 'Random+SINR', 'Sep-ch+Femto-First', 'Co-ch+SINR'});
ylabel('Percentage of traffic on femto BSs');
print(f,'-depsc', sprintf('%s/rb-ua-femto-traffic%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-femto-traffic%s.fig', output_dir, figure_file_name));

f=figure;
boxplot([cum_m1_mmwave_traffic, cum_m2_mmwave_traffic, cum_m3_mmwave_traffic, cum_m4_mmwave_traffic, cum_m5_mmwave_traffic],...
    'notch', 'off', 'Label', {'BR+BR', 'BR+Optim', 'Random+SINR', 'Sep-ch+Femto-First', 'Co-ch+SINR'});
ylabel('Percentage of traffic on mmwave BSs');
print(f,'-depsc', sprintf('%s/rb-ua-mmwave-traffic%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-mmwave-traffic%s.fig', output_dir, figure_file_name));

f=figure;
boxplot([cum_m1_obj, cum_m2_obj, cum_m3_obj, cum_m4_obj, cum_m5_obj],...
    'notch', 'off', 'Label', {'BR+BR', 'BR+Optim', 'Random+SINR', 'Sep-ch+Femto-First', 'Co-ch+SINR'});
ylabel('Objective');
print(f,'-depsc', sprintf('%s/rb-ua-boxplot-objective%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-boxplot-objective%s.fig', output_dir, figure_file_name));

f=figure; 
%h=cdfplot(cum_m4_rate/(nb_RBs*1e6/5));
h=cdfplot(cum_m1_rate/1e6);
set(h,'color','c','LineWidth',2)
hold on;
%h=cdfplot(cum_m1_rate/(nb_RBs*1e6/5));
h=cdfplot(cum_m2_rate/1e6);
set(h,'color','r','LineWidth',2)
%h=cdfplot(cum_m2_rate/(nb_RBs*1e6/5));
h=cdfplot(cum_m3_rate/1e6);
set(h,'color','b','LineWidth',2)
%h=cdfplot(cum_m3_rate/(nb_RBs*1e6/5));
h=cdfplot(cum_m4_rate(cum_m4_rate>0)/1e6);
set(h,'color','g','LineWidth',2)
h=cdfplot(cum_m5_rate(cum_m5_rate>0)/1e6);
set(h,'color','k','LineWidth',2)
title('Rate distribution');
ylabel('CDF');
xlabel('Rate (Mbits/s)');
set(gca,'XScale','log');
legend({'BR+BR', 'BR+Optim', 'Random+SINR', 'Sep-channel+Femto-First', 'Co-channel+SINR'}, 'Location', 'NorthWest');
hold off;
print(f,'-depsc', sprintf('%s/rb-ua-cdf-rate%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-cdf-rate%s.fig', output_dir, figure_file_name));