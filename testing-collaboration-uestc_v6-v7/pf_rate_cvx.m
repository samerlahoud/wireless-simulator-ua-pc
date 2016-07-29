clear;
clc;
load_params;
%[eNodeBs,UEs,pathloss_matrix]=generate_radio_conditions;
%save('test_conditions','eNodeBs','UEs','pathloss_matrix');

load('test_conditions');

% Maximize enegry effciency in a downlink multi-cell network
% Centralized approach

total_nb_users = netconfig.total_nb_users;
nb_sectors = netconfig.nb_sectors;
nb_RBs = netconfig.nb_RBs;
RB_bandwidth = netconfig.RB_bandwidth;
max_power_per_sector = netconfig.max_power_per_sector;
min_power_per_RB = netconfig.min_power_per_RB;
noise_density = netconfig.noise_density;


% Geometric programming formulation of the problem
cvx_begin
cvx_solver mosek
% variables are power levels
variable power_allocation_matrix(nb_sectors,nb_RBs)
variable rho(total_nb_users,nb_sectors,nb_RBs)

% Expressions used in computations
expression constraint_expr(total_nb_users,nb_sectors,nb_RBs)
expression objective

for j=1:nb_sectors
    for i=eNodeBs(j).attached_users
        for k=1:nb_RBs
            interference = 0;
            for j_p=1:nb_sectors
                if j_p == j
                    continue
                else
                    interference = interference + exp(rho(i,j,k)+ power_allocation_matrix(j_p,k) - power_allocation_matrix(j,k))* ...
                        pathloss_matrix(i,j_p,k)/pathloss_matrix(i,j,k);
                end
            end
            constraint_expr(i,j,k) = exp(rho(i,j,k)-power_allocation_matrix(j,k))*(noise_density*RB_bandwidth/pathloss_matrix(i,j,k))+ ...
               interference; 
        end
    end
end
% 
% power_consumption = power_prop_coeff*sum(sum(power_allocation_matrix))+nb_sectors*power_indep_coeff;
objective=sum(sum(sum(rho)));
maximize(objective);

subject to
% constraints are power limits for each BS
for j=1:nb_sectors
    for k=1:nb_RBs
        exp(power_allocation_matrix(j,k)) >= min_power_per_RB;
    end
end
for j=1:nb_sectors
    sum(exp(power_allocation_matrix(j,:))) <= max_power_per_sector;
end
for j=1:nb_sectors
    for i=eNodeBs(j).attached_users
        for k=1:nb_RBs
            constraint_expr(i,j,k) <= 1;
        end
    end
end
cvx_end
