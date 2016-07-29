load('./output/se-ee-results/results-compare-se-ee-6users-9sectors-10RBs-20W-1run')
nb_RBs = netconfig.nb_RBs;
nb_sectors = netconfig.nb_sectors;
nb_users_per_sector = netconfig.nb_users_per_sector;
f=figure;
plot([1:netconfig.nb_sectors],sum(ee_power_allocation_matrix'),'--bo', ...
    [1:netconfig.nb_sectors],sum(maxlog_power_allocation_matrix'),'--k*');
xlabel('Sector')
ylabel('Power (W)');
legend('ee','se');

% Take the mean value of the SINR for each user on all RBs
ee_mean_sinr_per_user = sum(ee_sinr_matrix,3)/nb_RBs;
% Merge to get on vector and reshape 
ee_mean_sinr_matrix = reshape(sum(ee_mean_sinr_per_user,2), nb_users_per_sector, nb_sectors)

f=figure
notBoxPlot(10*log(ee_mean_sinr_matrix))
xlabel('Sector');
ylabel('SINR per user (ee)')

% Take the mean value of the SINR for each user on all RBs
maxlog_mean_sinr_per_user = sum(maxlog_sinr_matrix,3)/nb_RBs;
% Merge to get on vector and reshape 
maxlog_mean_sinr_matrix = reshape(sum(maxlog_mean_sinr_per_user,2), nb_users_per_sector, nb_sectors)

f=figure
notBoxPlot(10*log(maxlog_mean_sinr_matrix))
xlabel('Sector');
ylabel('SINR per user (maxlog)')