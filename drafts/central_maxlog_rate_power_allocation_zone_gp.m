function [power_allocation_matrix, sinr_matrix] = central_maxlog_rate_power_allocation_zone_gp(netconfig, pathloss_matrix, BS)
% Tentative log(1+sinr) no success neither in GP nor direct convex
% Centralized approach

total_nb_users=netconfig.total_nb_users;
nb_sectors=netconfig.nb_sectors;
nb_RBs=netconfig.nb_RBs;
max_power_per_sector=netconfig.max_power_per_sector;
noise_density=netconfig.noise_density;

% Geometric programming formulation of the problem
cvx_begin
cvx_solver mosek
% variables are power levels
variable power_allocation_matrix(nb_sectors,nb_RBs)

% Expressions used in computations
expression interference
expression sinr(total_nb_users,nb_sectors,nb_RBs)
variable rho_tilde(total_nb_users,nb_sectors,nb_RBs)
expression objective

for j=1:nb_sectors
    for i=BS(j).attached_users
        for k=1:nb_RBs
            interference_mask = eye(nb_sectors,nb_sectors);
            interference_mask(j,j) = 0;
            interference = exp(power_allocation_matrix(:,k)')*interference_mask*pathloss_matrix(i,:,k)';
            sinr(i,j,k) = (exp(power_allocation_matrix(j,k))*pathloss_matrix(i,j,k))/(noise_density + interference);
        end
    end
end

objective=sum(sum(sum(log(log(exp(rho_tilde)+1)))));
maximize(objective);

subject to
% constraints are power limits for each BS
for j=1:nb_sectors
    sum(exp(power_allocation_matrix(j,:))) <= max_power_per_sector;
end
exp(rho_tilde) <= sinr;
sinr >= zeros(total_nb_users,nb_sectors,nb_RBs);
rho_tilde >= zeros(total_nb_users,nb_sectors,nb_RBs);

cvx_end
sinr_matrix = sinr;