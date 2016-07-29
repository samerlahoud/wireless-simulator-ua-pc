function [complete_time] = algo_compare_maxsinr_pmax(netconfig, pmax_vector)

tic
[BS,user,pathloss_matrix]=generate_radio_conditions(netconfig);
tmp_netconfig = netconfig;

for pmax = pmax_vector
    %[time_allocation] = central_max_sinr_scheduling_rb_gp(netconfig,pathloss_matrix,BS);
    tmp_netconfig.max_power_per_sector = pmax;
    [maxmin_power_allocation_matrix,maxmin_sinr_matrix] = central_maxmin_sinr_power_allocation_rb_gp(tmp_netconfig, pathloss_matrix, BS);
    [maxlog_power_allocation_matrix,maxlog_sinr_matrix] = central_maxlog_sinr_power_allocation_rb_gp(tmp_netconfig, pathloss_matrix, BS);
    [distributed_gt_maxlog_power_allocation_matrix,distributed_gt_maxlog_sinr_matrix] = distributed_gt_maxlog_sinr_power_allocation_rb_gp(tmp_netconfig, pathloss_matrix, BS);
    % Result formatting
    maxlog_sinr_db = 10*log10(maxlog_sinr_matrix);
    maxlog_sinr_db_vector = sort(maxlog_sinr_db(maxlog_sinr_db>-Inf));
    maxmin_sinr_db = 10*log10(maxmin_sinr_matrix);
    maxmin_sinr_db_vector = sort(maxmin_sinr_db(maxmin_sinr_db>-Inf));
    distributed_gt_maxlog_sinr_db = 10*log10(distributed_gt_maxlog_sinr_matrix);
    distributed_gt_maxlog_sinr_db_vector = sort(distributed_gt_maxlog_sinr_db(distributed_gt_maxlog_sinr_db>-Inf));
    
    maxlog_power_vector = reshape(maxlog_power_allocation_matrix, [], 1);
    maxlog_power_db_vector = sort(10*log10(maxlog_power_vector./tmp_netconfig.max_power_per_sector));
    maxmin_power_vector = reshape(maxmin_power_allocation_matrix, [], 1);
    maxmin_power_db_vector = sort(10*log10(maxmin_power_vector./tmp_netconfig.max_power_per_sector));
    distributed_gt_maxlog_power_vector = reshape(distributed_gt_maxlog_power_allocation_matrix, [], 1);
    distributed_gt_maxlog_power_db_vector = sort(10*log10(distributed_gt_maxlog_power_vector./tmp_netconfig.max_power_per_sector));
    
    hold on
    cdfplot(distributed_gt_maxlog_sinr_db_vector);
end
complete_time=toc;

% f=figure;
% hist([maxlog_sinr_db_vector, maxmin_sinr_db_vector, distributed_gt_maxlog_sinr_db_vector]);
% colormap summer;
% legend({'Max-Log', 'Max-min', 'Distributed-GT'}, 'Location', 'NorthWest');
% title('SINR distribution');
% ylabel('Occurrences');
% xlabel('SINR (dB)');
% %filename= ['sinr-hist_' netconfig.nb_users_per_sector netconfig.nb_sectors netconfig.nb_RBs netconfig.max_power_per_sector '.eps']
% print(f,'-depsc', './output/sinr-hist.eps');
% 
% f=figure; 
% h=cdfplot(maxlog_sinr_db_vector);
% set(h,'Marker','o','MarkerEdgeColor','b','LineStyle','none')
% hold on;
% h=cdfplot(maxmin_sinr_db_vector);
% set(h,'Marker','+','MarkerEdgeColor','r','LineStyle','none')
% h=cdfplot(distributed_gt_maxlog_sinr_db_vector);
% set(h,'Marker','^','MarkerEdgeColor','g','LineStyle','none')
% title('SINR distribution');
% ylabel('CDF');
% xlabel('SINR (dB)');
% legend({'Max-Log', 'Max-min', 'Distributed-GT'}, 'Location', 'NorthWest');
% hold off;
% print(f,'-depsc', './output/sinr-cdf.eps');
% 
% f=figure;
% hist([maxlog_power_db_vector, maxmin_power_db_vector, distributed_gt_maxlog_power_db_vector]);
% colormap summer;
% legend({'Max-Log', 'Max-min', 'Distributed-GT'}, 'Location', 'NorthWest');
% title('Power distribution');
% ylabel('Occurrences');
% xlabel('Power ratio (dB)');
% print(f,'-depsc', './output/power-hist.eps');
% 
% f=figure; 
% h=cdfplot(maxlog_power_db_vector);
% set(h,'Marker','o','MarkerEdgeColor','b','LineStyle','none')
% hold on;
% h=cdfplot(maxmin_power_db_vector);
% set(h,'Marker','+','MarkerEdgeColor','r','LineStyle','none')
% h=cdfplot(distributed_gt_maxlog_power_db_vector);
% set(h,'Marker','^','MarkerEdgeColor','g','LineStyle','none')
% title('Power distribution');
% ylabel('CDF');
% xlabel('Power ratio (dB)');
% legend({'Max-Log', 'Max-min', 'Distributed-GT'}, 'Location', 'NorthWest');
% hold off;
% print(f,'-depsc', './output/power-cdf.eps');