%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation of Joint scheduling and power control for energy efficiency in
% multi-cell networks (2015)
% Samer Lahoud samer.lahoud@irisa.fr
% Kinda Khawam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [power_allocation_matrix, sinr_matrix] = central_ee_maxlog_sinr_power_allocation_rb_gp(pathloss_matrix, BS)
% Maximize enegry effciency in a downlink multi-cell network
% Centralized approach
% Compute energy efficiency with CVX
% Numerator is given by the sum-log-sinr

global netconfig;
nb_sectors=netconfig.nb_sectors;
nb_RBs=netconfig.nb_RBs;
RB_bandwidth = netconfig.RB_bandwidth;
max_power_per_sector=netconfig.max_power_per_sector;
min_power_per_RB=netconfig.min_power_per_RB;
noise_density=netconfig.noise_density;
% Dinkelbach coefficient
eta = 2;
power_prop_coeff = netconfig.power_prop_coeff;
power_indep_coeff = netconfig.power_indep_coeff;
total_nb_users=netconfig.total_nb_users;
while(1)
    % Geometric programming formulation of the problem
    cvx_begin gp
    cvx_solver mosek
    % variables are power levels
    variable power_allocation_matrix(nb_sectors,nb_RBs)
    
    % Expressions used in computations
    expression interference(total_nb_users,nb_sectors,nb_RBs)
    expression sinr(total_nb_users,nb_sectors,nb_RBs)
    expression log_sinr(total_nb_users,nb_sectors,nb_RBs)
    expression power_consumption;
    expression objective
    
    for j=1:nb_sectors
        for i=BS(j).attached_users
            for k=1:nb_RBs
                interference_mask = eye(nb_sectors,nb_sectors);
                interference_mask(j,j) = 0;
                interference(i,j,k) = power_allocation_matrix(:,k)'*interference_mask*pathloss_matrix(i,:,k)';
                sinr(i,j,k)= (power_allocation_matrix(j,k)*pathloss_matrix(i,j,k))/(noise_density*RB_bandwidth + interference(i,j,k));
                log_sinr(i,j,k)= log(sinr(i,j,k));
            end
        end
    end
    
    power_consumption = power_prop_coeff*sum(sum(power_allocation_matrix))+nb_sectors*power_indep_coeff;
    objective=sum(sum(sum(log_sinr))) - eta * power_consumption;
    maximize(objective);
    
    subject to
    % constraints are power limits for each BS
    for j=1:nb_sectors
        sum(power_allocation_matrix(j,:)) <= max_power_per_sector;
    end
    for j=1:nb_sectors
        for k=1:nb_RBs
            power_allocation_matrix(j,k) >= min_power_per_RB;
        end
    end
    cvx_end
    % Dinkelbach stop condition
    objective = objective + scheduling_objective_computation;
    if (abs(objective) < 0.01)
        break;
    else
        eta=(sum(sum(sum(log_sinr)))+scheduling_objective_computation)/power_consumption;
    end
end
sinr_matrix = sinr;
end

