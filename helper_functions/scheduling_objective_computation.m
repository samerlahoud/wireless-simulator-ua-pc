% Compute EE objective based on power allocation and SINR values
function [objective] = scheduling_objective_computation

global netconfig;
nb_sectors=netconfig.nb_sectors;
nb_users_per_sector=netconfig.nb_users_per_sector;
nb_RBs = netconfig.nb_RBs;

log_sum_theta=0;
%beware of distributed_gt_ee_maxlog_sinr_power_allocation_gradient

for j=1:nb_sectors
    if nb_users_per_sector < nb_RBs
        log_sum_theta = log_sum_theta + nb_RBs*nb_users_per_sector*log(1/nb_RBs);
    else
        log_sum_theta = log_sum_theta + nb_RBs*nb_users_per_sector*log(1/nb_users_per_sector);
    end
end
objective=log_sum_theta;
end

