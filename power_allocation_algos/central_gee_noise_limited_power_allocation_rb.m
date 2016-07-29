%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Maximize GEE in a downlink multi-cell network in noise limited regime
% Centralized approach
% VENTURINO et al.: SCHEDULING AND POWER ALLOCATION IN OFDMA NETWORKS WITH BS COORDINATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [power_allocation_matrix, sinr_matrix] = central_gee_noise_limited_power_allocation_rb(pathloss_matrix, scheduling_matrix, BS)
% Maximize geometric enegry effciency in a downlink multi-cell network
% Centralized approach
% Compute energy efficiency with CVX
% Numerator is given by the GEE algo 3

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

scheduled_user_pathloss = zeros(nb_sectors,nb_RBs);

for j=1:nb_sectors
    for k=1:nb_RBs
        for i=BS(j).attached_users
            if scheduling_matrix(i,k) == 1
                scheduled_user_pathloss(j,k) = pathloss_matrix(i,j,k);
            end
        end
    end
end

while(1)
    % Geometric programming formulation of the problem
    cvx_begin gp
    cvx_solver mosek
    % variables are power levels
    variable power_allocation_matrix(nb_sectors,nb_RBs)
    
    % Expressions used in computations
    expression power_consumption;
    expression sinr_matrix(nb_sectors,nb_RBs);
    expression interference(total_nb_users,nb_sectors,nb_RBs);
    expression objective
    
    % SINR
    for j=1:nb_sectors
        for i=BS(j).attached_users
            for k=1:nb_RBs
                if scheduling_matrix(i,k) == 1
                    interference_mask = eye(nb_sectors,nb_sectors);
                    interference_mask(j,j) = 0;
                    interference(i,j,k) = power_allocation_matrix(:,k)'*interference_mask*pathloss_matrix(i,:,k)';
                    sinr_matrix(i,k)= (power_allocation_matrix(j,k)*pathloss_matrix(i,j,k))/(noise_density*RB_bandwidth + interference(i,j,k));
                    sinr_matrix(i,k)= log(sinr_matrix(i,k));
                end
            end
        end
    end
    
    % Noise limited regime
    %sinr_matrix = log(power_allocation_matrix.*scheduled_user_pathloss./(noise_density*RB_bandwidth));
    
    % Other options
    %snr_matrix = 180e3*log(1+(power_allocation_matrix.*scheduled_user_pathloss)./(noise_density*RB_bandwidth));
    %snr_matrix = 180e3*log(1+(power_allocation_matrix.*scheduled_user_pathloss));
    
    power_consumption = power_prop_coeff*sum(sum(power_allocation_matrix))+nb_sectors*power_indep_coeff;
    objective= sum(sum(sinr_matrix)) - eta * power_consumption;
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
    if (abs(objective) < 0.01)
        break;
    else
        eta=sum(sum(sinr_matrix))/power_consumption;
    end
end
[sinr_matrix] = sinr_computation(pathloss_matrix, BS, power_allocation_matrix);
for j=1:nb_sectors
    for k=1:nb_RBs
        for i=BS(j).attached_users
            if scheduling_matrix(i,k) == 0
                sinr_matrix(i,j,k) = 0;
            end
        end
    end
end
end

