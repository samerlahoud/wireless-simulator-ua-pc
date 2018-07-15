function ua_plot_results_rb_ua_reuse_pathloss_compare
% This generates all plots but for two out of three pathloss thresholds
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

for i = 1:nb_iterations
    load(sprintf('%s/rb-ua-100users-uniform-0.15-120dB/radio-conditions-%dusers-%drun.mat', output_dir, nb_users, i));
    load(sprintf('%s/rb-ua-100users-uniform-0.15-120dB/rb-ua-allocation-%dusers-%drun.mat', output_dir, nb_users, i));
    
    nb_BSs = netconfig.nb_BSs;
    nb_macro_BSs = netconfig.nb_macro_BSs;
    nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;
    
    m11_jain_index = ((sum(m1_rate))^2)/(nb_users*sum(m1_rate.^2));
    m21_jain_index = ((sum(m2_rate))^2)/(nb_users*sum(m2_rate.^2));
    m31_jain_index = ((sum(m3_rate))^2)/(nb_users*sum(m3_rate.^2));
    m41_jain_index = ((sum(m4_rate))^2)/(nb_users*sum(m4_rate.^2));
    m51_jain_index = ((sum(m5_rate))^2)/(nb_users*sum(m5_rate.^2));
    m61_jain_index = ((sum(m6_rate))^2)/(nb_users*sum(m6_rate.^2));
    
    cum_m11_rate = [cum_m11_rate; m1_rate];
    cum_m11_obj = [cum_m11_obj; m1_obj];
    cum_m11_ua = [cum_m11_ua; m1_ua];
    cum_m11_macro_traffic = [cum_m11_macro_traffic; sum(sum(m1_ua(:,1:nb_macro_BSs)))];
    cum_m11_femto_traffic = [cum_m11_femto_traffic; sum(sum(m1_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m11_mmwave_traffic = [cum_m11_mmwave_traffic; sum(sum(m1_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m11_jain_index = [cum_m11_jain_index; m11_jain_index];
    
    cum_m21_rate = [cum_m21_rate; m2_rate];
    cum_m21_obj = [cum_m21_obj; m2_obj];
    cum_m21_ua = [cum_m21_ua; m2_ua];
    cum_m21_macro_traffic = [cum_m21_macro_traffic; sum(sum(m2_ua(:,1:nb_macro_BSs)))];
    cum_m21_femto_traffic = [cum_m21_femto_traffic; sum(sum(m2_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m21_mmwave_traffic = [cum_m21_mmwave_traffic; sum(sum(m2_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m21_jain_index = [cum_m21_jain_index; m21_jain_index];
    
    cum_m31_rate = [cum_m31_rate; m3_rate];
    cum_m31_obj = [cum_m31_obj; m3_obj];
    cum_m31_ua = [cum_m31_ua; m3_ua];
    cum_m31_macro_traffic = [cum_m31_macro_traffic; sum(sum(m3_ua(:,1:nb_macro_BSs)))];
    cum_m31_femto_traffic = [cum_m31_femto_traffic; sum(sum(m3_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m31_mmwave_traffic = [cum_m31_mmwave_traffic; sum(sum(m3_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m31_jain_index = [cum_m31_jain_index; m31_jain_index];
    
    cum_m41_rate = [cum_m41_rate; m4_rate];
    cum_m41_obj = [cum_m41_obj; m4_obj];
    cum_m41_ua = [cum_m41_ua; m4_ua];
    cum_m41_macro_traffic = [cum_m41_macro_traffic; sum(sum(m4_ua(:,1:nb_macro_BSs)))];
    cum_m41_femto_traffic = [cum_m41_femto_traffic; sum(sum(m4_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m41_mmwave_traffic = [cum_m41_mmwave_traffic; sum(sum(m4_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m41_jain_index = [cum_m41_jain_index; m41_jain_index];
    
    cum_m51_rate = [cum_m51_rate; m5_rate];
    cum_m51_obj = [cum_m51_obj; m5_obj];
    cum_m51_ua = [cum_m51_ua; m5_ua];
    cum_m51_macro_traffic = [cum_m51_macro_traffic; sum(sum(m5_ua(:,1:nb_macro_BSs)))];
    cum_m51_femto_traffic = [cum_m51_femto_traffic; sum(sum(m5_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m51_mmwave_traffic = [cum_m51_mmwave_traffic; sum(sum(m5_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m51_jain_index = [cum_m51_jain_index; m51_jain_index];
    
    cum_m61_rate = [cum_m61_rate; m6_rate];
    cum_m61_obj = [cum_m61_obj; m6_obj];
    cum_m61_ua = [cum_m61_ua; m6_ua];
    cum_m61_macro_traffic = [cum_m61_macro_traffic; sum(sum(m6_ua(:,1:nb_macro_BSs)))];
    cum_m61_femto_traffic = [cum_m61_femto_traffic; sum(sum(m6_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m61_mmwave_traffic = [cum_m61_mmwave_traffic; sum(sum(m6_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m61_jain_index = [cum_m61_jain_index; m61_jain_index];   

end

for i = 1:nb_iterations
    load(sprintf('%s/rb-ua-100users-uniform-0.15-110dB/radio-conditions-%dusers-%drun.mat', output_dir, nb_users, i));
    load(sprintf('%s/rb-ua-100users-uniform-0.15-110dB/rb-ua-allocation-%dusers-%drun.mat', output_dir, nb_users, i));
    
    nb_BSs = netconfig.nb_BSs;
    nb_macro_BSs = netconfig.nb_macro_BSs;
    nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;
    
    m12_jain_index = ((sum(m1_rate))^2)/(nb_users*sum(m1_rate.^2));
    m22_jain_index = ((sum(m2_rate))^2)/(nb_users*sum(m2_rate.^2));
    m32_jain_index = ((sum(m3_rate))^2)/(nb_users*sum(m3_rate.^2));
    m42_jain_index = ((sum(m4_rate))^2)/(nb_users*sum(m4_rate.^2));
    m52_jain_index = ((sum(m5_rate))^2)/(nb_users*sum(m5_rate.^2));
    m62_jain_index = ((sum(m6_rate))^2)/(nb_users*sum(m6_rate.^2));
    
    cum_m12_rate = [cum_m12_rate; m1_rate];
    cum_m12_obj = [cum_m12_obj; m1_obj];
    cum_m12_ua = [cum_m12_ua; m1_ua];
    cum_m12_macro_traffic = [cum_m12_macro_traffic; sum(sum(m1_ua(:,1:nb_macro_BSs)))];
    cum_m12_femto_traffic = [cum_m12_femto_traffic; sum(sum(m1_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m12_mmwave_traffic = [cum_m12_mmwave_traffic; sum(sum(m1_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m12_jain_index = [cum_m12_jain_index; m12_jain_index];
    
    cum_m22_rate = [cum_m22_rate; m2_rate];
    cum_m22_obj = [cum_m22_obj; m2_obj];
    cum_m22_ua = [cum_m22_ua; m2_ua];
    cum_m22_macro_traffic = [cum_m22_macro_traffic; sum(sum(m2_ua(:,1:nb_macro_BSs)))];
    cum_m22_femto_traffic = [cum_m22_femto_traffic; sum(sum(m2_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m22_mmwave_traffic = [cum_m22_mmwave_traffic; sum(sum(m2_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m22_jain_index = [cum_m22_jain_index; m22_jain_index];
    
    cum_m32_rate = [cum_m32_rate; m3_rate];
    cum_m32_obj = [cum_m32_obj; m3_obj];
    cum_m32_ua = [cum_m32_ua; m3_ua];
    cum_m32_macro_traffic = [cum_m32_macro_traffic; sum(sum(m3_ua(:,1:nb_macro_BSs)))];
    cum_m32_femto_traffic = [cum_m32_femto_traffic; sum(sum(m3_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m32_mmwave_traffic = [cum_m32_mmwave_traffic; sum(sum(m3_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m32_jain_index = [cum_m32_jain_index; m32_jain_index];
    
    cum_m42_rate = [cum_m42_rate; m4_rate];
    cum_m42_obj = [cum_m42_obj; m4_obj];
    cum_m42_ua = [cum_m42_ua; m4_ua];
    cum_m42_macro_traffic = [cum_m42_macro_traffic; sum(sum(m4_ua(:,1:nb_macro_BSs)))];
    cum_m42_femto_traffic = [cum_m42_femto_traffic; sum(sum(m4_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m42_mmwave_traffic = [cum_m42_mmwave_traffic; sum(sum(m4_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m42_jain_index = [cum_m42_jain_index; m42_jain_index];
    
    cum_m52_rate = [cum_m52_rate; m5_rate];
    cum_m52_obj = [cum_m52_obj; m5_obj];
    cum_m52_ua = [cum_m52_ua; m5_ua];
    cum_m52_macro_traffic = [cum_m52_macro_traffic; sum(sum(m5_ua(:,1:nb_macro_BSs)))];
    cum_m52_femto_traffic = [cum_m52_femto_traffic; sum(sum(m5_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m52_mmwave_traffic = [cum_m52_mmwave_traffic; sum(sum(m5_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m52_jain_index = [cum_m52_jain_index; m52_jain_index];
    
    cum_m62_rate = [cum_m62_rate; m6_rate];
    cum_m62_obj = [cum_m62_obj; m6_obj];
    cum_m62_ua = [cum_m62_ua; m6_ua];
    cum_m62_macro_traffic = [cum_m62_macro_traffic; sum(sum(m6_ua(:,1:nb_macro_BSs)))];
    cum_m62_femto_traffic = [cum_m62_femto_traffic; sum(sum(m6_ua(:,nb_macro_BSs+1:nb_macro_femto_BSs)))];
    cum_m62_mmwave_traffic = [cum_m62_mmwave_traffic; sum(sum(m6_ua(:,nb_macro_femto_BSs+1:nb_BSs)))];
    cum_m62_jain_index = [cum_m62_jain_index; m62_jain_index];   

end

% Plot results
figure_file_name = sprintf('-%dusers',nb_users);

f=figure;

y = [mean(cum_m11_macro_traffic),mean(cum_m11_femto_traffic),mean(cum_m11_mmwave_traffic); ...
    mean(cum_m12_macro_traffic),mean(cum_m12_femto_traffic),mean(cum_m12_mmwave_traffic); ...
    mean(cum_m31_macro_traffic),mean(cum_m31_femto_traffic),mean(cum_m31_mmwave_traffic); ...
    mean(cum_m32_macro_traffic),mean(cum_m32_femto_traffic),mean(cum_m32_mmwave_traffic); ...
    mean(cum_m51_macro_traffic),mean(cum_m51_femto_traffic),mean(cum_m51_mmwave_traffic); ...
    mean(cum_m52_macro_traffic),mean(cum_m52_femto_traffic),mean(cum_m52_mmwave_traffic)]...
    *(100./nb_users);

errY = [std(cum_m11_macro_traffic),std(cum_m11_femto_traffic),std(cum_m11_mmwave_traffic); ...
    std(cum_m12_macro_traffic),std(cum_m12_femto_traffic),std(cum_m12_mmwave_traffic); ...
    std(cum_m31_macro_traffic),std(cum_m31_femto_traffic),std(cum_m31_mmwave_traffic); ...
    std(cum_m32_macro_traffic),std(cum_m32_femto_traffic),std(cum_m32_mmwave_traffic); ...
    std(cum_m51_macro_traffic),std(cum_m51_femto_traffic),std(cum_m51_mmwave_traffic); ...
    std(cum_m52_macro_traffic),std(cum_m52_femto_traffic),std(cum_m52_mmwave_traffic);] ...
    *(100./nb_users);

h = barwitherr(errY, y);% Plot with errorbars

set(gca,'XTickLabel',{'BR+BR+C', 'BR+BR', 'Co-ch+PR+C', 'Co-ch+PR', 'Co-ch+Power+C', 'Co-ch+Power'})
legend('Macro','Femto','mmWave')
ylabel('Percentage of traffic')
set(h(1),'FaceColor','k');
ylim([0 110])
print(f,'-depsc', sprintf('%s/rb-ua-traffic-perc%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-traffic-perc%s.fig', output_dir, figure_file_name));

% f=figure;
% boxplot([cum_m1_macro_traffic, cum_m2_macro_traffic, cum_m3_macro_traffic, cum_m4_macro_traffic, cum_m5_macro_traffic, cum_m6_macro_traffic],...
%     'notch', 'off', 'Label', {'BR+BR', 'BR+Optim', 'Co-ch+PR', 'Sep-ch+SC-First', 'Co-ch+Power', 'BR+Power'});
% ylabel('Percentage of traffic on macro BSs');
% print(f,'-depsc', sprintf('%s/rb-ua-macro-traffic%s.eps', output_dir, figure_file_name));
% savefig(sprintf('%s/rb-ua-macro-traffic%s.fig', output_dir, figure_file_name));
% 
% f=figure;
% boxplot([cum_m1_femto_traffic, cum_m2_femto_traffic, cum_m3_femto_traffic, cum_m4_femto_traffic, cum_m5_femto_traffic, cum_m6_femto_traffic],...
%     'notch', 'off', 'Label', {'BR+BR', 'BR+Optim', 'Co-ch+PR', 'Sep-ch+SC-First', 'Co-ch+Power', 'BR+Power'});
% ylabel('Percentage of traffic on femto BSs');
% print(f,'-depsc', sprintf('%s/rb-ua-femto-traffic%s.eps', output_dir, figure_file_name));
% savefig(sprintf('%s/rb-ua-femto-traffic%s.fig', output_dir, figure_file_name));
% 
% f=figure;
% boxplot([cum_m1_mmwave_traffic, cum_m2_mmwave_traffic, cum_m3_mmwave_traffic, cum_m4_mmwave_traffic, cum_m5_mmwave_traffic, cum_m6_mmwave_traffic],...
%     'notch', 'off', 'Label', {'BR+BR', 'BR+Optim', 'Co-ch+PR', 'Sep-ch+SC-First', 'Co-ch+Power', 'BR+Power'});
% ylabel('Percentage of traffic on mmwave BSs');
% print(f,'-depsc', sprintf('%s/rb-ua-mmwave-traffic%s.eps', output_dir, figure_file_name));
% savefig(sprintf('%s/rb-ua-mmwave-traffic%s.fig', output_dir, figure_file_name));
% 
f=figure;
boxplot([cum_m11_obj, cum_m12_obj, cum_m31_obj, cum_m32_obj, cum_m51_obj, cum_m52_obj],...
    'notch', 'off', 'Label', {'BR+BR+C', 'BR+BR', 'Co-ch+PR+C', 'Co-ch+PR', 'Co-ch+Power+C', 'Co-ch+Power'});
ylabel('Objective');
print(f,'-depsc', sprintf('%s/rb-ua-boxplot-objective%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-boxplot-objective%s.fig', output_dir, figure_file_name));

f=figure;
boxplot([cum_m11_jain_index, cum_m12_jain_index, cum_m31_jain_index, cum_m32_jain_index, cum_m51_jain_index, cum_m52_jain_index],...
    'notch', 'off', 'Label', {'BR+BR+C', 'BR+BR', 'Co-ch+PR+C', 'Co-ch+PR', 'Co-ch+Power+C', 'Co-ch+Power'});
ylabel('Jain index');
print(f,'-depsc', sprintf('%s/rb-ua-jain-index%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-jain-index%s.fig', output_dir, figure_file_name));

f=figure; 
h=cdfplot(cum_m11_rate/1e6);
set(h,'color','c','LineWidth',2)
hold on;
h=cdfplot(cum_m12_rate/1e6);
set(h,'color','r','LineWidth',2)
h=cdfplot(cum_m31_rate/1e6);
set(h,'color','b','LineWidth',2)
h=cdfplot(cum_m32_rate/1e6);
set(h,'color','g','LineWidth',2)
h=cdfplot(cum_m51_rate/1e6);
set(h,'color','k','LineWidth',2)
h=cdfplot(cum_m52_rate/1e6);
set(h,'color','y','LineWidth',2)
title('Rate distribution');
ylabel('CDF');
xlabel('Rate (Mbits/s)');
set(gca,'XScale','log');
legend({'BR+BR+C', 'BR+BR', 'Co-ch+PR+C', 'Co-ch+PR', 'Co-ch+Power+C', 'Co-ch+Power'}, 'Location', 'NorthWest');
hold off;
print(f,'-depsc', sprintf('%s/rb-ua-cdf-rate%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-cdf-rate%s.fig', output_dir, figure_file_name));