function ua_plot_results_rb_ua_algo_compare
global netconfig;
nb_iterations = netconfig.nb_iterations;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;
nb_femto_BSs = netconfig.nb_femto_BSs;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;
nb_RBs = netconfig.nb_RBs;

output_dir = './output/user-association-output/rb-ua-100users-uniform-0.15-110dB/';

cum_m1_rate = [];
cum_m1_obj = [];
cum_m1_ua = [];
cum_m1_macro_traffic = [];
cum_m1_femto_traffic = [];
cum_m1_mmwave_traffic = [];
cum_m1_jain_index = [];
cum_m2_rate = [];
cum_m2_obj = [];
cum_m2_ua = [];
cum_m2_macro_traffic = [];
cum_m2_femto_traffic = [];
cum_m2_mmwave_traffic = [];
cum_m2_jain_index = [];
cum_m3_rate = [];
cum_m3_obj = [];
cum_m3_ua = [];
cum_m3_macro_traffic = [];
cum_m3_femto_traffic = [];
cum_m3_mmwave_traffic = [];
cum_m3_jain_index = [];
cum_m4_rate = [];
cum_m4_obj = [];
cum_m4_ua = [];
cum_m4_macro_traffic = [];
cum_m4_femto_traffic = [];
cum_m4_mmwave_traffic = [];
cum_m4_jain_index = [];
cum_m5_rate = [];
cum_m5_obj = [];
cum_m5_ua = [];
cum_m5_macro_traffic = [];
cum_m5_femto_traffic = [];
cum_m5_mmwave_traffic = [];
cum_m5_jain_index = [];
cum_m6_rate = [];
cum_m6_obj = [];
cum_m6_ua = [];
cum_m6_macro_traffic = [];
cum_m6_femto_traffic = [];
cum_m6_mmwave_traffic = [];
cum_m6_jain_index = [];

cum_optimal_pf_sinr_rank = [];

for i = 1:nb_iterations
    load(sprintf('%s/rb-ua-allocation-%dusers-%drun.mat', output_dir, nb_users, i));
    
    m1_jain_index = ((sum(m1_rate))^2)/(nb_users*sum(m1_rate.^2));
    m2_jain_index = ((sum(m2_rate))^2)/(nb_users*sum(m2_rate.^2));
    m3_jain_index = ((sum(m3_rate))^2)/(nb_users*sum(m3_rate.^2));
    m4_jain_index = ((sum(m4_rate))^2)/(nb_users*sum(m4_rate.^2));
    m5_jain_index = ((sum(m5_rate))^2)/(nb_users*sum(m5_rate.^2));
    m6_jain_index = ((sum(m6_rate))^2)/(nb_users*sum(m6_rate.^2));
    
    cum_m1_rate = [cum_m1_rate; m1_rate];
    cum_m1_obj = [cum_m1_obj; m1_obj];
    cum_m1_ua = [cum_m1_ua; m1_ua];
    cum_m1_macro_traffic = [cum_m1_macro_traffic; sum(sum(m1_ua(:,1:nb_macro_BSs)))];
    cum_m1_femto_traffic = [cum_m1_femto_traffic; sum(sum(m1_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m1_mmwave_traffic = [cum_m1_mmwave_traffic; sum(sum(m1_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m1_jain_index = [cum_m1_jain_index; m1_jain_index];
    
    cum_m2_rate = [cum_m2_rate; m2_rate];
    cum_m2_obj = [cum_m2_obj; m2_obj];
    cum_m2_ua = [cum_m2_ua; m2_ua];
    cum_m2_macro_traffic = [cum_m2_macro_traffic; sum(sum(m2_ua(:,1:nb_macro_BSs)))];
    cum_m2_femto_traffic = [cum_m2_femto_traffic; sum(sum(m2_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m2_mmwave_traffic = [cum_m2_mmwave_traffic; sum(sum(m2_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m2_jain_index = [cum_m2_jain_index; m2_jain_index];
    
    cum_m3_rate = [cum_m3_rate; m3_rate];
    cum_m3_obj = [cum_m3_obj; m3_obj];
    cum_m3_ua = [cum_m3_ua; m3_ua];
    cum_m3_macro_traffic = [cum_m3_macro_traffic; sum(sum(m3_ua(:,1:nb_macro_BSs)))];
    cum_m3_femto_traffic = [cum_m3_femto_traffic; sum(sum(m3_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m3_mmwave_traffic = [cum_m3_mmwave_traffic; sum(sum(m3_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m3_jain_index = [cum_m3_jain_index; m3_jain_index];
    
    cum_m4_rate = [cum_m4_rate; m4_rate];
    cum_m4_obj = [cum_m4_obj; m4_obj];
    cum_m4_ua = [cum_m4_ua; m4_ua];
    cum_m4_macro_traffic = [cum_m4_macro_traffic; sum(sum(m4_ua(:,1:nb_macro_BSs)))];
    cum_m4_femto_traffic = [cum_m4_femto_traffic; sum(sum(m4_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m4_mmwave_traffic = [cum_m4_mmwave_traffic; sum(sum(m4_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m4_jain_index = [cum_m4_jain_index; m4_jain_index];
    
    cum_m5_rate = [cum_m5_rate; m5_rate];
    cum_m5_obj = [cum_m5_obj; m5_obj];
    cum_m5_ua = [cum_m5_ua; m5_ua];
    cum_m5_macro_traffic = [cum_m5_macro_traffic; sum(sum(m5_ua(:,1:nb_macro_BSs)))];
    cum_m5_femto_traffic = [cum_m5_femto_traffic; sum(sum(m5_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m5_mmwave_traffic = [cum_m5_mmwave_traffic; sum(sum(m5_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m5_jain_index = [cum_m5_jain_index; m5_jain_index];
    
    cum_m6_rate = [cum_m6_rate; m6_rate];
    cum_m6_obj = [cum_m6_obj; m6_obj];
    cum_m6_ua = [cum_m6_ua; m6_ua];
    cum_m6_macro_traffic = [cum_m6_macro_traffic; sum(sum(m6_ua(:,1:nb_macro_BSs)))];
    cum_m6_femto_traffic = [cum_m6_femto_traffic; sum(sum(m6_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m6_mmwave_traffic = [cum_m6_mmwave_traffic; sum(sum(m6_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m6_jain_index = [cum_m6_jain_index; m6_jain_index];
end

% Plot results
figure_file_name = sprintf('-%dusers',nb_users);

f=figure;
boxplot([cum_m1_rate, cum_m2_rate, cum_m3_rate, cum_m4_rate(cum_m4_rate>0), cum_m5_rate(cum_m5_rate>0), cum_m6_rate(cum_m6_rate>0)]./1e6,...
        'Label', {'BR-SA + BR-UA', 'BR-SA + Cent-UA', 'CoCh-SA + PR-UA', 'SepCh-SA + SCFirst-UA', 'CoCh-SA + Pow-UA', 'BR-SA + Pow-UA'}, ...
        'Whisker',100);
set(gca,'XTickLabelRotation',90);
ax = gca;
ax.YGrid = 'on';
ylabel('Rate (Mbit/s)');
set(gca,'YScale','log')
print(f,'-depsc', sprintf('%s/rb-ua-boxplot-rate%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-boxplot-rate%s.fig', output_dir, figure_file_name));

f=figure;

y = [mean(cum_m1_macro_traffic),mean(cum_m1_femto_traffic),mean(cum_m1_mmwave_traffic); ...
    mean(cum_m2_macro_traffic),mean(cum_m2_femto_traffic),mean(cum_m2_mmwave_traffic); ...
    mean(cum_m3_macro_traffic),mean(cum_m3_femto_traffic),mean(cum_m3_mmwave_traffic); ...
    mean(cum_m4_macro_traffic),mean(cum_m4_femto_traffic),mean(cum_m4_mmwave_traffic); ...
    mean(cum_m5_macro_traffic),mean(cum_m5_femto_traffic),mean(cum_m5_mmwave_traffic); ...
    mean(cum_m6_macro_traffic),mean(cum_m6_femto_traffic),mean(cum_m6_mmwave_traffic)]...
    *(100./nb_users);

errY = [std(cum_m1_macro_traffic),std(cum_m1_femto_traffic),std(cum_m1_mmwave_traffic); ...
    std(cum_m2_macro_traffic),std(cum_m2_femto_traffic),std(cum_m2_mmwave_traffic); ...
    std(cum_m3_macro_traffic),std(cum_m3_femto_traffic),std(cum_m3_mmwave_traffic); ...
    std(cum_m4_macro_traffic),std(cum_m4_femto_traffic),std(cum_m4_mmwave_traffic); ...
    std(cum_m5_macro_traffic),std(cum_m5_femto_traffic),std(cum_m5_mmwave_traffic); ...
    std(cum_m6_macro_traffic),std(cum_m6_femto_traffic),std(cum_m6_mmwave_traffic);] ...
    *(100./nb_users);

%h = barwitherr(errY, y);% Plot with errorbars

h = bar(y,'stacked');

set(gca,'XTickLabel',{'BR-SA + BR-UA', 'BR-SA + Cent-UA', 'CoCh-SA + PR-UA', 'SepCh-SA + SCFirst-UA', 'CoCh-SA + Pow-UA', 'BR-SA + Pow-UA'})
legend('Macro','Femto','mmWave')
ylabel('Percentage of users')
set(gca,'XTickLabelRotation',90);
ylim([0 110])
ax = gca;
ax.YGrid = 'on';
print(f,'-depsc', sprintf('%s/rb-ua-traffic-perc%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-traffic-perc%s.fig', output_dir, figure_file_name));

f=figure;
boxplot([cum_m1_macro_traffic, cum_m2_macro_traffic, cum_m3_macro_traffic, cum_m4_macro_traffic, cum_m5_macro_traffic, cum_m6_macro_traffic],...
    'notch', 'off', 'Label', {'BR-SA+BR-UA', 'BR-SA+Cent-UA', 'CoCh-SA+PR-UA', 'SepCh-SA+SCFirst-UA', 'CoCh-SA+Pow-UA', 'BR-SA+Pow-UA'});
ylabel('Percentage of traffic on macro BSs');
set(gca,'XTickLabelRotation',45);
print(f,'-depsc', sprintf('%s/rb-ua-macro-traffic%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-macro-traffic%s.fig', output_dir, figure_file_name));

f=figure;
boxplot([cum_m1_femto_traffic, cum_m2_femto_traffic, cum_m3_femto_traffic, cum_m4_femto_traffic, cum_m5_femto_traffic, cum_m6_femto_traffic],...
    'notch', 'off', 'Label', {'BR-SA+BR-UA', 'BR-SA+Cent-UA', 'CoCh-SA+PR-UA', 'SepCh-SA+SCFirst-UA', 'CoCh-SA+Pow-UA', 'BR-SA+Pow-UA'});
ylabel('Percentage of traffic on femto BSs');
set(gca,'XTickLabelRotation',45);
print(f,'-depsc', sprintf('%s/rb-ua-femto-traffic%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-femto-traffic%s.fig', output_dir, figure_file_name));

f=figure;
boxplot([cum_m1_mmwave_traffic, cum_m2_mmwave_traffic, cum_m3_mmwave_traffic, cum_m4_mmwave_traffic, cum_m5_mmwave_traffic, cum_m6_mmwave_traffic],...
    'notch', 'off', 'Label', {'BR-SA+BR-UA', 'BR-SA+Cent-UA', 'CoCh-SA+PR-UA', 'SepCh-SA+SCFirst-UA', 'CoCh-SA+Pow-UA', 'BR-SA+Pow-UA'});
ylabel('Percentage of traffic on mmwave BSs');
set(gca,'XTickLabelRotation',45);
print(f,'-depsc', sprintf('%s/rb-ua-mmwave-traffic%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-mmwave-traffic%s.fig', output_dir, figure_file_name));

f=figure;
boxplot([cum_m1_obj, cum_m2_obj, cum_m3_obj, cum_m4_obj, cum_m5_obj, cum_m6_obj],...
    'notch', 'off', 'Label', {'BR-SA + BR-UA', 'BR-SA + Cent-UA', 'CoCh-SA + PR-UA', 'SepCh-SA + SCFirst-UA', 'CoCh-SA + Pow-UA', 'BR-SA + Pow-UA'});
ylabel('Objective');
set(gca,'XTickLabelRotation',90);
ax = gca;
ax.YGrid = 'on';
print(f,'-depsc', sprintf('%s/rb-ua-boxplot-objective%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-boxplot-objective%s.fig', output_dir, figure_file_name));

f=figure;
boxplot([cum_m1_jain_index, cum_m2_jain_index, cum_m3_jain_index, cum_m4_jain_index, cum_m5_jain_index, cum_m6_jain_index],...
    'notch', 'off', 'Label', {'BR-SA+BR-UA', 'BR-SA+Cent-UA', 'CoCh-SA+PR-UA', 'SepCh-SA+SCFirst-UA', 'CoCh-SA+Pow-UA', 'BR-SA+Pow-UA'});
ylabel('Jain index');
set(gca,'XTickLabelRotation',45);
print(f,'-depsc', sprintf('%s/rb-ua-jain-index%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-jain-index%s.fig', output_dir, figure_file_name));

f=figure; 
h=cdfplot(cum_m1_rate/1e6);
%set(h,'color','c','LineWidth',2)
set(h,'LineWidth',2,'LineStyle', '-')
hold on;
h=cdfplot(cum_m2_rate/1e6);
%set(h,'color','r','LineWidth',2)
set(h,'LineWidth',2,'LineStyle', '-')
h=cdfplot(cum_m3_rate/1e6);
%set(h,'color','b','LineWidth',2)
set(h,'LineWidth',2,'LineStyle', '--')
h=cdfplot(cum_m4_rate/1e6);
%set(h,'color','g','LineWidth',2)
set(h,'LineWidth',2,'LineStyle', '--')
h=cdfplot(cum_m5_rate/1e6);
%set(h,'color','k','LineWidth',2)
set(h,'LineWidth',2,'LineStyle', ':')
h=cdfplot(cum_m6_rate/1e6);
%set(h,'color','y','LineWidth',2)
set(h,'LineWidth',2,'LineStyle', ':')
title('');
ylabel('CDF');
xlabel('Rate (Mbit/s)');
set(gca,'XScale','log');
legend({'BR-SA + BR-UA', 'BR-SA + Cent-UA', 'CoCh-SA + PR-UA', 'SepCh-SA + SCFirst-UA', 'CoCh-SA + Pow-UA', 'BR-SA + Pow-UA'}, 'Location', 'NorthEast');
hold off;
print(f,'-depsc', sprintf('%s/rb-ua-cdf-rate%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-cdf-rate%s.fig', output_dir, figure_file_name));
