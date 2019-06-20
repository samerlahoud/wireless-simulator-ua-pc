function ua_plot_results_rb_ua_m_mimo_compare
global netconfig;
nb_iterations = netconfig.nb_iterations;
nb_users = netconfig.nb_users;
%nb_femto_BSs = netconfig.nb_femto_BSs;
%nb_RBs = netconfig.nb_RBs;

output_dir = './output/user-association-output';

cum_m11_rate = [];
cum_m11_obj = [];
cum_m11_ua = [];
cum_m11_macro_traffic = [];
cum_m11_femto_traffic = [];
cum_m11_mmwave_traffic = [];
cum_m11_jain_index = [];
cum_m21_rate = [];
cum_m21_obj = [];
cum_m21_ua = [];
cum_m21_macro_traffic = [];
cum_m21_femto_traffic = [];
cum_m21_mmwave_traffic = [];
cum_m21_jain_index = [];
cum_m31_rate = [];
cum_m31_obj = [];
cum_m31_ua = [];
cum_m31_macro_traffic = [];
cum_m31_femto_traffic = [];
cum_m31_mmwave_traffic = [];
cum_m31_jain_index = [];
cum_m41_rate = [];
cum_m41_obj = [];
cum_m41_ua = [];
cum_m41_macro_traffic = [];
cum_m41_femto_traffic = [];
cum_m41_mmwave_traffic = [];
cum_m41_jain_index = [];
cum_m51_rate = [];
cum_m51_obj = [];
cum_m51_ua = [];
cum_m51_macro_traffic = [];
cum_m51_femto_traffic = [];
cum_m51_mmwave_traffic = [];
cum_m51_jain_index = [];
cum_m61_rate = [];
cum_m61_obj = [];
cum_m61_ua = [];
cum_m61_macro_traffic = [];
cum_m61_femto_traffic = [];
cum_m61_mmwave_traffic = [];
cum_m61_jain_index = [];

cum_m12_rate = [];
cum_m12_obj = [];
cum_m12_ua = [];
cum_m12_macro_traffic = [];
cum_m12_femto_traffic = [];
cum_m12_mmwave_traffic = [];
cum_m12_jain_index = [];
cum_m22_rate = [];
cum_m22_obj = [];
cum_m22_ua = [];
cum_m22_macro_traffic = [];
cum_m22_femto_traffic = [];
cum_m22_mmwave_traffic = [];
cum_m22_jain_index = [];
cum_m32_rate = [];
cum_m32_obj = [];
cum_m32_ua = [];
cum_m32_macro_traffic = [];
cum_m32_femto_traffic = [];
cum_m32_mmwave_traffic = [];
cum_m32_jain_index = [];
cum_m42_rate = [];
cum_m42_obj = [];
cum_m42_ua = [];
cum_m42_macro_traffic = [];
cum_m42_femto_traffic = [];
cum_m42_mmwave_traffic = [];
cum_m42_jain_index = [];
cum_m52_rate = [];
cum_m52_obj = [];
cum_m52_ua = [];
cum_m52_macro_traffic = [];
cum_m52_femto_traffic = [];
cum_m52_mmwave_traffic = [];
cum_m52_jain_index = [];
cum_m62_rate = [];
cum_m62_obj = [];
cum_m62_ua = [];
cum_m62_macro_traffic = [];
cum_m62_femto_traffic = [];
cum_m62_mmwave_traffic = [];
cum_m62_jain_index = [];

cum_m13_rate = [];
cum_m13_obj = [];
cum_m13_ua = [];
cum_m13_macro_traffic = [];
cum_m13_femto_traffic = [];
cum_m13_mmwave_traffic = [];
cum_m13_jain_index = [];
cum_m23_rate = [];
cum_m23_obj = [];
cum_m23_ua = [];
cum_m23_macro_traffic = [];
cum_m23_femto_traffic = [];
cum_m23_mmwave_traffic = [];
cum_m23_jain_index = [];
cum_m33_rate = [];
cum_m33_obj = [];
cum_m33_ua = [];
cum_m33_macro_traffic = [];
cum_m33_femto_traffic = [];
cum_m33_mmwave_traffic = [];
cum_m33_jain_index = [];
cum_m43_rate = [];
cum_m43_obj = [];
cum_m43_ua = [];
cum_m43_macro_traffic = [];
cum_m43_femto_traffic = [];
cum_m43_mmwave_traffic = [];
cum_m43_jain_index = [];
cum_m53_rate = [];
cum_m53_obj = [];
cum_m53_ua = [];
cum_m53_macro_traffic = [];
cum_m53_femto_traffic = [];
cum_m53_mmwave_traffic = [];
cum_m53_jain_index = [];
cum_m63_rate = [];
cum_m63_obj = [];
cum_m63_ua = [];
cum_m63_macro_traffic = [];
cum_m63_femto_traffic = [];
cum_m63_mmwave_traffic = [];
cum_m63_jain_index = [];

for i = 1:nb_iterations
    load(sprintf('%s/rb-ua-100users-uniform-0.15-110dB/radio-conditions-%dusers-%drun.mat', output_dir, nb_users, i));
    load(sprintf('%s/rb-ua-100users-uniform-0.15-110dB/rb-ua-allocation-%dusers-%drun.mat', output_dir, nb_users, i));
    
    nb_BSs = netconfig.nb_BSs;
    nb_macro_BSs = netconfig.nb_macro_BSs;
    nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;
  
    cum_m11_rate = [cum_m11_rate; m1_rate];
    cum_m11_obj = [cum_m11_obj; m1_obj];
    cum_m11_ua = [cum_m11_ua; m1_ua];
    cum_m11_macro_traffic = [cum_m11_macro_traffic; sum(sum(m1_ua(:,1:nb_macro_BSs)))];
    cum_m11_femto_traffic = [cum_m11_femto_traffic; sum(sum(m1_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m11_mmwave_traffic = [cum_m11_mmwave_traffic; sum(sum(m1_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    %cum_m11_jain_index = [cum_m11_jain_index; m11_jain_index];
end

for i = 1:nb_iterations
    load(sprintf('%s/rb-ua-100users-uniform-0.15-m-mimo-psi-045-110dB/radio-conditions-%dusers-%drun.mat', output_dir, nb_users, i));
    load(sprintf('%s/rb-ua-100users-uniform-0.15-m-mimo-psi-045-110dB/rb-ua-allocation-%dusers-%drun.mat', output_dir, nb_users, i));
    
    nb_BSs = netconfig.nb_BSs;
    nb_macro_BSs = netconfig.nb_macro_BSs;
    nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;
    
    cum_m12_rate = [cum_m12_rate; m1_rate];
    cum_m12_obj = [cum_m12_obj; m1_obj];
    cum_m12_ua = [cum_m12_ua; m1_ua];
    cum_m12_macro_traffic = [cum_m12_macro_traffic; sum(sum(m1_ua(:,1:nb_macro_BSs)))];
    cum_m12_femto_traffic = [cum_m12_femto_traffic; sum(sum(m1_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m12_mmwave_traffic = [cum_m12_mmwave_traffic; sum(sum(m1_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    %cum_m12_jain_index = [cum_m12_jain_index; m12_jain_index];
end

for i = 1:nb_iterations
    load(sprintf('%s/rb-ua-100users-uniform-0.15-m-mimo-psi-1-110dB/radio-conditions-%dusers-%drun.mat', output_dir, nb_users, i));
    load(sprintf('%s/rb-ua-100users-uniform-0.15-m-mimo-psi-1-110dB/rb-ua-allocation-%dusers-%drun.mat', output_dir, nb_users, i));
    
    nb_BSs = netconfig.nb_BSs;
    nb_macro_BSs = netconfig.nb_macro_BSs;
    nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;
    
    cum_m13_rate = [cum_m13_rate; m1_rate];
    cum_m13_obj = [cum_m13_obj; m1_obj];
    cum_m13_ua = [cum_m13_ua; m1_ua];
    cum_m13_macro_traffic = [cum_m13_macro_traffic; sum(sum(m1_ua(:,1:nb_macro_BSs)))];
    cum_m13_femto_traffic = [cum_m13_femto_traffic; sum(sum(m1_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m13_mmwave_traffic = [cum_m13_mmwave_traffic; sum(sum(m1_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    %cum_m13_jain_index = [cum_m13_jain_index; m13_jain_index];
end

% Plot results
figure_file_name = sprintf('-%dusers',nb_users);

f=figure;

y = [mean(cum_m11_macro_traffic),mean(cum_m11_femto_traffic),mean(cum_m11_mmwave_traffic); ...
    mean(cum_m12_macro_traffic),mean(cum_m12_femto_traffic),mean(cum_m12_mmwave_traffic); ...
    mean(cum_m13_macro_traffic),mean(cum_m13_femto_traffic),mean(cum_m13_mmwave_traffic);] ...
    *(100./nb_users);

% errY = [std(cum_m11_macro_traffic),std(cum_m11_femto_traffic),std(cum_m11_mmwave_traffic); ...
%     std(cum_m12_macro_traffic),std(cum_m12_femto_traffic),std(cum_m12_mmwave_traffic); ...
%     std(cum_m31_macro_traffic),std(cum_m31_femto_traffic),std(cum_m31_mmwave_traffic); ...
%     std(cum_m32_macro_traffic),std(cum_m32_femto_traffic),std(cum_m32_mmwave_traffic); ...
%     std(cum_m51_macro_traffic),std(cum_m51_femto_traffic),std(cum_m51_mmwave_traffic); ...
%     std(cum_m52_macro_traffic),std(cum_m52_femto_traffic),std(cum_m52_mmwave_traffic);] ...
%     *(100./nb_users);

%h = barwitherr(errY, y);% Plot with errorbars

h = bar(y,'stacked');

hatchfill2(h(1),'single','HatchAngle',0,'HatchDensity',30,'HatchLineWidth',0.5); 
hatchfill2(h(2),'single','HatchAngle',135,'HatchDensity',30,'HatchLineWidth',0.5); 
hatchfill2(h(3),'single','HatchAngle',45,'HatchDensity',30,'HatchLineWidth',0.5); 
[~,legend_h,~,~] = legendflex(h,{'Macro','Femto','mmWave'}); 
hatchfill2(legend_h(length(h)+1),'single','HatchAngle',0,'HatchDensity',10,'HatchColor','k','HatchLineWidth',0.5); 
hatchfill2(legend_h(length(h)+2),'single','HatchAngle',135,'HatchDensity',10,'HatchColor','k','HatchLineWidth',0.5); 
hatchfill2(legend_h(length(h)+3),'single','HatchAngle',45,'HatchDensity',10,'HatchColor','k','HatchLineWidth',0.5);

set(gca,'XTickLabel',{'BR-SA + Cent-UA', 'BR-SA + Cent-UA (mMIMO,0.45)', 'BR-SA + Cent-UA (mMIMO,1)'})
%legend('Macro','Femto','mmWave','Location', 'NorthWest')
ylabel('Percentage of users')
set(gca,'XTickLabelRotation',45);
ylim([0 110])
ax = gca;
ax.YGrid = 'on';
print(f,'-depsc', sprintf('%s/m-mimo-compare/rb-ua-traffic-perc%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/m-mimo-compare/rb-ua-traffic-perc%s.fig', output_dir, figure_file_name));
 
f=figure;
boxplot([cum_m11_obj, cum_m12_obj, cum_m13_obj],...
    'notch', 'off', 'Label', ...
    {'BR-SA + Cent-UA', 'BR-SA + Cent-UA (mMIMO,0.45)', 'BR-SA + Cent-UA (mMIMO,1)'});
ylabel('Objective');
set(gca,'XTickLabelRotation',45);
ax = gca;
ax.YGrid = 'on';
print(f,'-depsc', sprintf('%s/m-mimo-compare/rb-ua-boxplot-objective%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/m-mimo-compare/rb-ua-boxplot-objective%s.fig', output_dir, figure_file_name));

f=figure;
boxplot([cum_m11_rate, cum_m12_rate, cum_m13_rate]./1e6,...
    'Whisker',100, 'Label', ...
    {'BR-SA + Cent-UA', 'BR-SA + Cent-UA (mMIMO,0.45)', 'BR-SA + Cent-UA (mMIMO,1)'});
set(gca,'XTickLabelRotation',45);
ax = gca;
ax.YGrid = 'on';
ylabel('Rate (Mbit/s)');
set(gca,'YScale','log')
print(f,'-depsc', sprintf('%s/m-mimo-compare/rb-ua-boxplot-rate%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/m-mimo-compare/rb-ua-boxplot-rate%s.fig', output_dir, figure_file_name));

% f=figure; 
% h=cdfplot(cum_m11_rate/1e6);
% set(h,'color','c','LineWidth',2)
% hold on;
% h=cdfplot(cum_m12_rate/1e6);
% set(h,'color','r','LineWidth',2)
% h=cdfplot(cum_m31_rate/1e6);
% set(h,'color','b','LineWidth',2)
% h=cdfplot(cum_m32_rate/1e6);
% set(h,'color','g','LineWidth',2)
% h=cdfplot(cum_m51_rate/1e6);
% set(h,'color','k','LineWidth',2)
% h=cdfplot(cum_m52_rate/1e6);
% set(h,'color','y','LineWidth',2)
% title('Rate distribution');
% ylabel('CDF');
% xlabel('Rate (Mbits/s)');
% set(gca,'XScale','log');
% legend({'BR+BR+C', 'BR+BR', 'Co-ch+PR+C', 'Co-ch+PR', 'Co-ch+Power+C', 'Co-ch+Power'}, 'Location', 'NorthWest');
% hold off;
% print(f,'-depsc', sprintf('%s/rb-ua-cdf-rate%s.eps', output_dir, figure_file_name));
% savefig(sprintf('%s/rb-ua-cdf-rate%s.fig', output_dir, figure_file_name));