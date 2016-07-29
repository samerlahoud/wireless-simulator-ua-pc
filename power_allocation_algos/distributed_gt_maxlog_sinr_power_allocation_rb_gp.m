function [power_allocation_matrix, sinr_matrix] = distributed_gt_maxlog_sinr_power_allocation_rb_gp(pathloss_matrix, BS)
% Maximize totan SINR in a downlink multi-cell network
% Distributed approach: max power on all RBs
global netconfig;
total_nb_users=netconfig.total_nb_users;
nb_sectors=netconfig.nb_sectors;
nb_RBs=netconfig.nb_RBs;
max_power_per_sector=netconfig.max_power_per_sector;
noise_density=netconfig.noise_density;
RB_bandwidth=netconfig.RB_bandwidth;

power_allocation_matrix=(max_power_per_sector/nb_RBs).*ones(nb_sectors,nb_RBs);

for j=1:nb_sectors
    for i=BS(j).attached_users
        for k=1:nb_RBs
            interference_mask = eye(nb_sectors,nb_sectors);
            interference_mask(j,j) = 0;
            interference(i,j,k) = power_allocation_matrix(:,k)'*interference_mask*pathloss_matrix(i,:,k)';
        end
    end
end

objective=0;
for j=1:nb_sectors
    for i=BS(j).attached_users
        for k=1:nb_RBs
            objective = objective + log((power_allocation_matrix(j,k)*pathloss_matrix(i,j,k))/(noise_density*RB_bandwidth + interference(i,j,k)));
        end
    end
end

sinr_matrix = zeros(total_nb_users,nb_sectors,nb_RBs);
for j=1:nb_sectors
    for i=BS(j).attached_users
        for k=1:nb_RBs
            sinr_matrix(i,j,k) = (power_allocation_matrix(j,k)*pathloss_matrix(i,j,k))/(noise_density*RB_bandwidth + interference(i,j,k));
        end
    end
end