function [power_allocation_matrix, sinr_matrix] = central_maxmin_sinr_power_allocation_rb_gp(pathloss_matrix, BS)
% Maximize minimum SINR in a downlink multi-cell network
% Centralized approach

global netconfig;
total_nb_users=netconfig.total_nb_users;
nb_sectors=netconfig.nb_sectors;
nb_RBs=netconfig.nb_RBs;
max_power_per_sector=netconfig.max_power_per_sector;
noise_density=netconfig.noise_density;
RB_bandwidth=netconfig.RB_bandwidth;

% Geometric programming formulation of the problem
cvx_begin gp
cvx_solver mosek
% variables are power levels
variable power_allocation_matrix(nb_sectors,nb_RBs)

% Expressions used in computations
expression interference(total_nb_users,nb_sectors,nb_RBs)
expression sinr(total_nb_users,nb_sectors,nb_RBs)

for j=1:nb_sectors
    for i=BS(j).attached_users
        for k=1:nb_RBs
            interference_mask = eye(nb_sectors,nb_sectors);
            interference_mask(j,j) = 0;
            interference(i,j,k) = power_allocation_matrix(:,k)'*interference_mask*pathloss_matrix(i,:,k)';
            sinr(i,j,k)= (power_allocation_matrix(j,k)*pathloss_matrix(i,j,k))/(noise_density*RB_bandwidth + interference(i,j,k));
        end
    end
end

objective=min(min(min(sinr)));
maximize(objective)

subject to
% constraints are power limits for each BS
for j=1:nb_sectors
    sum(power_allocation_matrix(j,:)) <= max_power_per_sector;
end 
cvx_end

% As there are no binding constraints on SINR, we should compute the SINR
% based on the optimal power allocation (if else we will get all SINR equal
% to the minimum value).
sinr_matrix = zeros(total_nb_users,nb_sectors,nb_RBs);
for j=1:nb_sectors
    for i=BS(j).attached_users
        for k=1:nb_RBs
            sinr_matrix(i,j,k) = (power_allocation_matrix(j,k)*pathloss_matrix(i,j,k))/(noise_density*RB_bandwidth + interference(i,j,k));
        end
    end
end