function plot_results_algo_compare_maxsinr

global netconfig;
cum_maxlog_sinr_db_vector=[];
cum_maxlog_sinr_db_sorted_vector=[];
cum_maxmin_sinr_db_vector=[];
cum_maxmin_sinr_db_sorted_vector=[];
cum_distributed_gt_maxlog_sinr_db_vector=[];
cum_distributed_gt_maxlog_sinr_db_sorted_vector=[];
cum_maxlog_power_db_vector=[];
cum_maxlog_power_db_sorted_vector=[];
cum_maxmin_power_db_vector=[];
cum_maxmin_power_db_sorted_vector=[];
cum_distributed_gt_maxlog_power_db_vector=[];
cum_distributed_gt_maxlog_power_db_sorted_vector=[];
cum_maxlog_power_db_vector_per_user=[];
cum_maxmin_power_db_vector_per_user=[];
cum_distributed_gt_maxlog_power_db_vector_per_user=[];
cum_pathloss_db_vector=[];

% Load results
for i=1:netconfig.nb_iterations
    load(sprintf('./output/results-compare-maxsinr-%dusers-%dsectors-%dRBs-%dW-%drun', ...
        netconfig.nb_users_per_sector,netconfig.nb_sectors,...
        netconfig.nb_RBs,netconfig.max_power_per_sector,i));
    cum_maxlog_sinr_db_vector=[cum_maxlog_sinr_db_vector; maxlog_sinr_db_vector];
    cum_maxlog_sinr_db_sorted_vector=[cum_maxlog_sinr_db_sorted_vector; maxlog_sinr_db_sorted_vector];
    cum_maxmin_sinr_db_vector=[cum_maxmin_sinr_db_vector; maxmin_sinr_db_vector];
    cum_maxmin_sinr_db_sorted_vector=[cum_maxmin_sinr_db_sorted_vector; maxmin_sinr_db_sorted_vector];
    cum_distributed_gt_maxlog_sinr_db_vector=[cum_distributed_gt_maxlog_sinr_db_vector; distributed_gt_maxlog_sinr_db_vector];
    cum_distributed_gt_maxlog_sinr_db_sorted_vector=[cum_distributed_gt_maxlog_sinr_db_sorted_vector; distributed_gt_maxlog_sinr_db_sorted_vector];
    cum_maxlog_power_db_vector=[cum_maxlog_power_db_vector; maxlog_power_db_vector];
    cum_maxlog_power_db_sorted_vector=[cum_maxlog_power_db_sorted_vector; maxlog_power_db_sorted_vector];
    cum_maxmin_power_db_vector=[cum_maxmin_power_db_vector; maxmin_power_db_vector];
    cum_maxmin_power_db_sorted_vector=[cum_maxmin_power_db_sorted_vector; maxmin_power_db_sorted_vector];
    cum_distributed_gt_maxlog_power_db_vector=[cum_distributed_gt_maxlog_power_db_vector; distributed_gt_maxlog_power_db_vector];
    cum_distributed_gt_maxlog_power_db_sorted_vector=[cum_distributed_gt_maxlog_power_db_sorted_vector; distributed_gt_maxlog_power_db_sorted_vector];
    cum_maxlog_power_db_vector_per_user=[cum_maxlog_power_db_vector_per_user; maxlog_power_db_vector_per_user];
    cum_maxmin_power_db_vector_per_user=[cum_maxmin_power_db_vector_per_user; maxmin_power_db_vector_per_user];
    cum_distributed_gt_maxlog_power_db_vector_per_user=[cum_distributed_gt_maxlog_power_db_vector_per_user; distributed_gt_maxlog_power_db_vector_per_user];
    cum_pathloss_db_vector=[cum_pathloss_db_vector; pathloss_db_vector];
end

% Plot results
figure_file_name = sprintf('-%dusers-%dsectors-%dRBs-%dW',netconfig.nb_users_per_sector,...
    netconfig.nb_sectors,netconfig.nb_RBs,netconfig.max_power_per_sector);
% f=figure; 
% plot(maxlog_sinr_db_vector,'bo');
% hold on;
% plot(maxmin_sinr_db_vector,'r+');
% plot(distributed_gt_maxlog_sinr_db_vector,'g^');
% title('SINR distribution');
% xlabel('Users');
% ylabel('SINR (dB)');
% legend({'Max-Log', 'Max-min', 'Distributed-GT'}, 'Location', 'NorthWest');
% hold off;
% print(f,'-depsc', sprintf('./output/sinr-curves%s.eps', figure_file_name));

sinr_db_min=min([cum_maxlog_sinr_db_sorted_vector' cum_maxmin_sinr_db_sorted_vector' cum_distributed_gt_maxlog_sinr_db_sorted_vector']);
sinr_db_max=max([cum_maxlog_sinr_db_sorted_vector' cum_maxmin_sinr_db_sorted_vector' cum_distributed_gt_maxlog_sinr_db_sorted_vector']);
binranges = sinr_db_min - mod(sinr_db_min,10):20:sinr_db_max + mod(-sinr_db_max,10);
[bincounts] = histc([cum_maxlog_sinr_db_sorted_vector, cum_maxmin_sinr_db_sorted_vector, cum_distributed_gt_maxlog_sinr_db_sorted_vector],binranges);
f=figure;
%hist([maxlog_sinr_db_vector, maxmin_sinr_db_vector, distributed_gt_maxlog_sinr_db_vector]);
bar(binranges,bincounts,'histc')
colormap summer;
legend({'Max-log', 'Max-min', 'Distributed-GT'}, 'Location', 'NorthWest');
title('SINR distribution');
ylabel('Occurrences');
xlabel('SINR (dB)');
print(f,'-depsc', sprintf('./output/sinr-hist%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-hist%s.fig', figure_file_name));

f=figure; 
h=cdfplot(cum_maxlog_sinr_db_sorted_vector);
set(h,'Marker','o','MarkerEdgeColor','b','LineStyle','none')
hold on;
h=cdfplot(cum_maxmin_sinr_db_sorted_vector);
set(h,'Marker','+','MarkerEdgeColor','r','LineStyle','none')
h=cdfplot(cum_distributed_gt_maxlog_sinr_db_sorted_vector);
set(h,'Marker','^','MarkerEdgeColor','g','LineStyle','none')
title('SINR distribution');
ylabel('CDF');
xlabel('SINR (dB)');
legend({'Max-log', 'Max-min', 'Distributed-GT'}, 'Location', 'NorthWest');
hold off;
print(f,'-depsc', sprintf('./output/sinr-cdf%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-cdf%s.fig', figure_file_name));

power_db_min=min([cum_maxlog_power_db_sorted_vector' cum_maxmin_power_db_sorted_vector' cum_distributed_gt_maxlog_power_db_sorted_vector']);
power_db_max=max([cum_maxlog_power_db_sorted_vector' cum_maxmin_power_db_sorted_vector' cum_distributed_gt_maxlog_power_db_sorted_vector']);
binranges = power_db_min - mod(power_db_min,10):10:power_db_max + mod(-power_db_max,10);
[bincounts] = histc([cum_maxlog_power_db_sorted_vector, cum_maxmin_power_db_sorted_vector, cum_distributed_gt_maxlog_power_db_sorted_vector],binranges);
f=figure;
bar(binranges,bincounts,'histc')
%hist([maxlog_power_db_vector, maxmin_power_db_vector, distributed_gt_maxlog_power_db_vector]);
colormap summer;
legend({'Max-log', 'Max-min', 'Distributed-GT'}, 'Location', 'NorthWest');
title('Power distribution');
ylabel('Occurrences');
xlabel('Power ratio (dB)');
print(f,'-depsc', sprintf('./output/power-hist%s.eps', figure_file_name));
savefig(sprintf('./output/power-hist%s.fig', figure_file_name));

f=figure; 
h=cdfplot(cum_maxlog_power_db_sorted_vector);
set(h,'Marker','o','MarkerEdgeColor','b','LineStyle','none')
hold on;
h=cdfplot(cum_maxmin_power_db_sorted_vector);
set(h,'Marker','+','MarkerEdgeColor','r','LineStyle','none')
h=cdfplot(cum_distributed_gt_maxlog_power_db_sorted_vector);
set(h,'Marker','^','MarkerEdgeColor','g','LineStyle','none')
title('Power distribution');
ylabel('CDF');
xlabel('Power ratio (dB)');
legend({'Max-log', 'Max-min', 'Distributed-GT'}, 'Location', 'NorthWest');
print(f,'-depsc', sprintf('./output/power-cdf%s.eps', figure_file_name));
savefig(sprintf('./output/power-cdf%s.fig', figure_file_name));

f=figure; 
ax(1) = subplot(3,1,1);
h=scatter(cum_maxlog_power_db_vector_per_user, cum_maxlog_sinr_db_vector);
set(h,'Marker','o','MarkerEdgeColor','b');
ylabel('SINR (dB)');
xlabel('Power ratio (dB)');
title('Max-log');
ax(2) = subplot(3,1,2);
h=scatter(cum_maxmin_power_db_vector_per_user, cum_maxmin_sinr_db_vector);
set(h,'Marker','+','MarkerEdgeColor','r');
ylabel('SINR (dB)');
xlabel('Power ratio (dB)');
title('Max-min');
ax(3) = subplot(3,1,3);
h=scatter(cum_distributed_gt_maxlog_power_db_vector_per_user, cum_distributed_gt_maxlog_sinr_db_vector);
set(h,'Marker','^','MarkerEdgeColor','g')
title('SINR vs Power ratio');
ylabel('SINR (dB)');
xlabel('Power ratio (dB)');
title('Distributed-GT');
linkaxes(ax,'x');
print(f,'-depsc', sprintf('./output/sinr-power-scatter%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-power-scatter%s.fig', figure_file_name));

f=figure; 
h=scatter3(cum_pathloss_db_vector, cum_maxlog_power_db_vector_per_user, cum_maxlog_sinr_db_vector);
set(h,'Marker','o','MarkerEdgeColor','b')
hold on;
h=scatter3(cum_pathloss_db_vector, cum_maxmin_power_db_vector_per_user, cum_maxmin_sinr_db_vector);
set(h,'Marker','+','MarkerEdgeColor','r')
h=scatter3(cum_pathloss_db_vector, cum_distributed_gt_maxlog_power_db_vector_per_user, cum_distributed_gt_maxlog_sinr_db_vector);
set(h,'Marker','^','MarkerEdgeColor','g')
title('SINR vs Power ratio vs Pathloss');
zlabel('SINR (dB)');
ylabel('Power ratio (dB)');
xlabel('Pathloss (dB)');
legend({'Max-log', 'Max-min', 'Distributed-GT'}, 'Location', 'NorthWest');
hold off;
print(f,'-depsc', sprintf('./output/sinr-power-pathloss-scatter%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-power-pathloss-scatter%s.fig', figure_file_name));

cum_maxlog_power_db_vector_per_user_filtered=cum_maxlog_power_db_vector_per_user(cum_maxlog_sinr_db_vector > -Inf);
cum_maxlog_sinr_db_vector_filtered=cum_maxlog_sinr_db_vector(cum_maxlog_sinr_db_vector > -Inf);
cum_maxmin_power_db_vector_per_user_filtered=cum_maxmin_power_db_vector_per_user(cum_maxmin_sinr_db_vector > -Inf);
cum_maxmin_sinr_db_vector_filtered=cum_maxmin_sinr_db_vector(cum_maxmin_sinr_db_vector > -Inf);
cum_distributed_gt_maxlog_power_db_vector_per_user_filtered=cum_distributed_gt_maxlog_power_db_vector_per_user(cum_distributed_gt_maxlog_sinr_db_vector > -Inf);
cum_distributed_gt_maxlog_sinr_db_vector_filtered=cum_distributed_gt_maxlog_sinr_db_vector(cum_distributed_gt_maxlog_sinr_db_vector > -Inf);

f=figure;
h=cloudPlot(cum_maxlog_power_db_vector_per_user_filtered,cum_maxlog_sinr_db_vector_filtered,[],[],[50 50]);
title('SINR vs Power ratio - Max-Log');
ylabel('SINR (dB)');
xlabel('Power ratio (dB)');
colormap jet;
colorbar('location','eastoutside');
print(f,'-depsc', sprintf('./output/sinr-power-cloud-maxlog%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-power-cloud-maxlogt%s.fig', figure_file_name));

f=figure;
h=cloudPlot(cum_maxmin_power_db_vector_per_user_filtered,cum_maxmin_sinr_db_vector_filtered,[],[],[50 50]);
title('SINR vs Power ratio - Max-min');
ylabel('SINR (dB)');
xlabel('Power ratio (dB)');
colormap jet;
colorbar('location','eastoutside');
print(f,'-depsc', sprintf('./output/sinr-power-cloud-maxmin%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-power-cloud-maxmin%s.fig', figure_file_name));

f=figure;
h=cloudPlot(cum_distributed_gt_maxlog_power_db_vector_per_user_filtered,cum_distributed_gt_maxlog_sinr_db_vector_filtered,[],[],[50 50]);
title('SINR vs Power ratio - Distributed-GT');
ylabel('SINR (dB)');
xlabel('Power ratio (dB)');
colormap jet;
colorbar('location','eastoutside');
print(f,'-depsc', sprintf('./output/sinr-power-cloud-distributed-gt%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-power-cloud-distributed-gt%s.fig', figure_file_name));

%%%
x = cum_maxlog_power_db_vector_per_user_filtered;
y = cum_maxlog_sinr_db_vector_filtered;
n = 25; % Number of bins
xi = linspace(min(x(:)), max(x(:)), n);
yi = linspace(min(y(:)), max(y(:)), n);
xr = interp1(xi, 0.5:numel(xi)-0.5, x, 'nearest');
yr = interp1(yi, 0.5:numel(yi)-0.5, y, 'nearest');
Z = accumarray([yr xr] + 0.5, 1, [n n]);
 
f=figure;
h=surf(xi, yi, Z);
xlabel('Power ratio (dB)');
ylabel('SINR (dB)');
zlabel('count');
colormap jet;
colorbar('location','eastoutside');
print(f,'-depsc', sprintf('./output/sinr-power-3d-maxlog%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-power-3d-maxlog%s.fig', figure_file_name));

x = cum_maxmin_power_db_vector_per_user_filtered;
y = cum_maxmin_sinr_db_vector_filtered;
n = 25; % Number of bins
xi = linspace(min(x(:)), max(x(:)), n);
yi = linspace(min(y(:)), max(y(:)), n);
xr = interp1(xi, 0.5:numel(xi)-0.5, x, 'nearest');
yr = interp1(yi, 0.5:numel(yi)-0.5, y, 'nearest');
Z = accumarray([yr xr] + 0.5, 1, [n n]);
 
f=figure;
h=surf(xi, yi, Z);
xlabel('Power ratio (dB)');
ylabel('SINR (dB)');
zlabel('count');
colormap jet;
colorbar('location','eastoutside');
print(f,'-depsc', sprintf('./output/sinr-power-3d-maxmin%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-power-3d-maxmin%s.fig', figure_file_name));

f=figure;
boxplot([cum_maxlog_sinr_db_vector_filtered cum_maxmin_sinr_db_vector_filtered ...
    cum_distributed_gt_maxlog_sinr_db_vector_filtered], 'notch', 'off', ...
    'Label', {'Max-log', 'Max-min', 'Distributed-GT'});
ylabel('SINR (dB)');
print(f,'-depsc', sprintf('./output/boxplot-sinr%s.eps', figure_file_name));
savefig(sprintf('./output/boxplot-sinr%s.fig', figure_file_name));

f=figure;
boxplot([cum_maxlog_power_db_vector_per_user_filtered cum_maxmin_power_db_vector_per_user_filtered ...
    cum_distributed_gt_maxlog_power_db_vector_per_user_filtered], 'notch', 'off', ...
    'Label', {'Max-log', 'Max-min', 'Distributed-GT'});
ylabel('Power ratio (dB)');
print(f,'-depsc', sprintf('./output/boxplot-power%s.eps', figure_file_name));
savefig(sprintf('./output/boxplot-power%s.fig', figure_file_name));

f=figure;
subplot(2,2,1)
h=bagplot([cum_maxlog_power_db_vector_per_user_filtered cum_maxlog_sinr_db_vector_filtered],...
    'databag', '0', 'datafence', '0');
title('SINR vs Power ratio - Max-Log');
ylabel('SINR (dB)');
xlabel('Power ratio (dB)');

subplot(2,2,2)
h=scatter(cum_maxlog_power_db_vector_per_user_filtered, cum_maxlog_sinr_db_vector_filtered);
title('SINR vs Power ratio - Max-Log');
ylabel('SINR (dB)');
xlabel('Power ratio (dB)');

subplot(2,2,3)
h=bagplot([cum_maxmin_power_db_vector_per_user_filtered cum_maxmin_sinr_db_vector_filtered],...
    'databag', '0', 'datafence', '0');
title('SINR vs Power ratio - Max-min');
ylabel('SINR (dB)');
xlabel('Power ratio (dB)');

subplot(2,2,4)
h=scatter(cum_maxmin_power_db_vector_per_user_filtered,cum_maxmin_sinr_db_vector_filtered);
title('SINR vs Power ratio - Max-min');
ylabel('SINR (dB)');
xlabel('Power ratio (dB)');

print(f,'-depsc', sprintf('./output/sinr-power-scatter-bag%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-power-scatter-bag%s.fig', figure_file_name));

f=figure;
subplot(3,4,1)
h=scatter(cum_pathloss_db_vector, cum_maxlog_power_db_vector_per_user);
title('Max-Log');
ylabel('Power ratio (dB)');
xlabel('Pathloss (dB)');

subplot(3,4,2)
h=scatter(cum_pathloss_db_vector, cum_maxlog_sinr_db_vector);
title('Max-Log');
ylabel('SINR (dB)');
xlabel('Pathloss (dB)');

subplot(3,4,3)
h=cloudPlot(cum_pathloss_db_vector, cum_maxlog_power_db_vector_per_user,[],[],[50 50]);
colormap jet;
colorbar('location','eastoutside');
title('Max-Log');
ylabel('Power ratio (dB)');
xlabel('Pathloss (dB)');

subplot(3,4,4)
h=cloudPlot(cum_pathloss_db_vector, cum_maxlog_sinr_db_vector,[],[],[50 50]);
colormap jet;
colorbar('location','eastoutside');
title('Max-Log');
ylabel('SINR (dB)');
xlabel('Pathloss (dB)');

subplot(3,4,5)
h=scatter(cum_pathloss_db_vector, cum_maxmin_power_db_vector_per_user);
title('Max-min');
ylabel('Power ratio (dB)');
xlabel('Pathloss (dB)');

subplot(3,4,6)
h=scatter(cum_pathloss_db_vector, cum_maxmin_sinr_db_vector);
title('Max-min');
ylabel('SINR (dB)');
xlabel('Pathloss (dB)');

subplot(3,4,7)
h=cloudPlot(cum_pathloss_db_vector, cum_maxmin_power_db_vector_per_user,[],[],[50 50]);
colormap jet;
colorbar('location','eastoutside');
title('Max-min');
ylabel('Power ratio (dB)');
xlabel('Pathloss (dB)');

subplot(3,4,8)
h=cloudPlot(cum_pathloss_db_vector, cum_maxmin_sinr_db_vector,[],[],[50 50]);
colormap jet;
colorbar('location','eastoutside');
title('Max-min');
ylabel('SINR (dB)');
xlabel('Pathloss (dB)');

subplot(3,4,9)
h=scatter(cum_pathloss_db_vector, cum_distributed_gt_maxlog_power_db_vector_per_user);
title('Distributed-GT');
ylabel('Power ratio (dB)');
xlabel('Pathloss (dB)');

subplot(3,4,10)
h=scatter(cum_pathloss_db_vector, cum_distributed_gt_maxlog_sinr_db_vector);
title('Distributed-GT');
ylabel('SINR (dB)');
xlabel('Pathloss (dB)');

subplot(3,4,11)
h=cloudPlot(cum_pathloss_db_vector, cum_distributed_gt_maxlog_power_db_vector_per_user,[],[],[50 50]);
colormap jet;
colorbar('location','eastoutside');
title('Distributed-GT');
ylabel('Power ratio (dB)');
xlabel('Pathloss (dB)');

subplot(3,4,12)
h=cloudPlot(cum_pathloss_db_vector, cum_distributed_gt_maxlog_sinr_db_vector,[],[],[50 50]);
colormap jet;
colorbar('location','eastoutside');
title('Distributed-GT');
ylabel('SINR (dB)');
xlabel('Pathloss (dB)');

print(f,'-depsc', sprintf('./output/sinr-power-pathloss-scatter%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-power-pathloss-scatter%s.fig', figure_file_name));
