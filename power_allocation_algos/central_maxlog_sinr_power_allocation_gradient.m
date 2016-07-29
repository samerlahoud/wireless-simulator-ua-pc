%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation of Joint scheduling and power control for energy efficiency in
% multi-cell networks (2015)
% Samer Lahoud samer.lahoud@irisa.fr
% Kinda Khawam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [power_allocation_matrix,sinr_matrix] = central_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS)
global netconfig;
% Maximize sum-log-sinr based on projected subgradient

% Typical netconfig parameters
power_prop_coeff  = netconfig.power_prop_coeff;    % Pj(1)
power_indep_coeff = netconfig.power_indep_coeff;
min_power_per_RB  = netconfig.min_power_per_RB;
max_power_per_sector = netconfig.max_power_per_sector;
total_nb_users = netconfig.total_nb_users;
nb_sectors = netconfig.nb_sectors;
nb_RBs = netconfig.nb_RBs;
RB_bandwidth = netconfig.RB_bandwidth;
nb_users_per_sector  = netconfig.nb_users_per_sector;
noise_density        = netconfig.noise_density;
gradient_step = netconfig.gradient_step;
gradient_convergence_eps = netconfig.gradient_convergence_eps;

% Initial value can be arbitrary
power_allocation_matrix=ones(nb_sectors,nb_RBs)*1;

% Cumulate power but this is not necessary
cumulative_power_allocation_matrix=[power_allocation_matrix];

nb_steps = 5000;
% for delta = 0.1 reduce every 100 steps
% for delta = 0.01 reduce every 500 steps

for s=0:nb_steps
    % Divide delta if needed to speed up the convergence
    if mod(s,250)==0 && min_power_per_RB < 0.1
      gradient_step=gradient_step/4;
    end
    
    previous_power_allocation_matrix = power_allocation_matrix;
    
    % Compute the gradient with the new modified expression
    for j=1:nb_sectors
        for k=1:nb_RBs
            partial_grad = 0;
            for l=1:nb_sectors
                if l == j
                    continue;
                else
                    for i=BS(l).attached_users
                        interf = 0;
                        for j_prime=1:nb_sectors
                            if j_prime == l
                                continue;
                            else
                                interf = interf + ...
                                    pathloss_matrix(i,j_prime,k)*power_allocation_matrix(j_prime,k);
                            end
                        end
                        partial_grad = partial_grad + ...
                            (pathloss_matrix(i,j,k)/(interf+(noise_density*RB_bandwidth)));
                    end
                end
            end
            power_allocation_matrix(j,k) = power_allocation_matrix(j,k) + ...
                gradient_step*(nb_users_per_sector/power_allocation_matrix(j,k) - partial_grad);
            
            % Projection on positive orthant
            if power_allocation_matrix(j,k) <= min_power_per_RB
                power_allocation_matrix(j,k) = min_power_per_RB;
            end
        end
        
        % Projection on simplex max_power_per_sector
        if (sum(power_allocation_matrix(j,:)) > max_power_per_sector)
            sorted_power_allocation_vector  = sort(power_allocation_matrix(j,:),'descend');
            N_tilde = size(sorted_power_allocation_vector,2);
            sorted_power_allocation_vector(end+1) = -Inf;
            while(N_tilde > 0)
                if ((sorted_power_allocation_vector(N_tilde) > sorted_power_allocation_vector(N_tilde+1)) && ...
                        (sorted_power_allocation_vector(N_tilde) > (sum(sorted_power_allocation_vector(1:N_tilde))-max_power_per_sector)/N_tilde))
                    mu = (sum(sorted_power_allocation_vector(1:N_tilde))-max_power_per_sector)/N_tilde;
                    power_allocation_matrix(j,:) = max(power_allocation_matrix(j,:) - mu, min_power_per_RB);
                    break;
                else
                    N_tilde = N_tilde - 1;
                end
            end
        end
    end
    
    % Convergence test
    power_convergence = norm(power_allocation_matrix - previous_power_allocation_matrix);
    if(power_convergence<gradient_convergence_eps)
        %disp('convergence');
        break;
    end
    cumulative_power_allocation_matrix=[cumulative_power_allocation_matrix;power_allocation_matrix];
end
sinr_matrix=sinr_computation(pathloss_matrix, BS, power_allocation_matrix);

%Plot power evolution
%     hold on
%     for sector_index=1:nb_sectors
%         for RB_index=1:nb_RBs
%             RB_power_evolution=[];
%             for iteration_index=0:s-1
%                 RB_power_evolution = [RB_power_evolution, ...
%                     cumulative_power_allocation_matrix(sector_index+iteration_index*nb_sectors,RB_index)];
%             end
%             plot([0:s-1],RB_power_evolution)
%         end
%     end
%     hold off
    
