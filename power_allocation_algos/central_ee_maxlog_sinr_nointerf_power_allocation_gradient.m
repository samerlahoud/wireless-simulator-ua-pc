%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation of Joint scheduling and power control for energy efficiency in
% multi-cell networks (2015)
% Samer Lahoud samer.lahoud@irisa.fr
% Kinda Khawam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [power_allocation_matrix,sinr_matrix] = central_ee_maxlog_sinr_nointerf_power_allocation_gradient(pathloss_matrix, BS)
% Compute energy efficiency based on projected subgradient
% Numerator is given by the sum-log-sinr
% no interference model
global netconfig;

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
dinkelbach_param = netconfig.starting_dinkelbach_param;

% Initial value can be arbitrary
power_allocation_matrix=ones(nb_sectors,nb_RBs)*1;

% Cumulate power but this is not necessary
cumulative_power_allocation_matrix=[power_allocation_matrix];

% Choose the numebr of steps
nb_steps = 5000;
cum_nb_steps = [];

while(1) 
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
                power_allocation_matrix(j,k) = power_allocation_matrix(j,k) + ...
                    gradient_step*(nb_users_per_sector/power_allocation_matrix(j,k) - dinkelbach_param * power_prop_coeff);
                
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
            cum_nb_steps = [cum_nb_steps, s];
            break;
        end
        cumulative_power_allocation_matrix=[cumulative_power_allocation_matrix;power_allocation_matrix];
    end
    
    % Objective is computed with no interference to ensure convergence
    logsinr=0;
    for j=1:nb_sectors
        for i=BS(j).attached_users
            for k=1:nb_RBs
                logsinr = logsinr + log((power_allocation_matrix(j,k)*pathloss_matrix(i,j,k))/(noise_density*RB_bandwidth));
            end
        end
    end

    power_consumption = power_prop_coeff*sum(sum(power_allocation_matrix))+nb_sectors*power_indep_coeff;
    log_sum_theta = scheduling_objective_computation;
    objective=(logsinr+log_sum_theta) - dinkelbach_param * power_consumption;
    
    % For comparison interference is taken into account to compute the real
    % SINR although the model does not account for interference
    sinr_matrix=sinr_computation(pathloss_matrix, BS, power_allocation_matrix);
    
    if (abs(objective) < 0.1)
%         hold on
%         for sector_index=1:nb_sectors
%             for RB_index=1:nb_RBs
%                 RB_power_evolution=[];
%                 for iteration_index=0:sum(cum_nb_steps)
%                     RB_power_evolution = [RB_power_evolution, ...
%                         cumulative_power_allocation_matrix(sector_index+iteration_index*nb_sectors,RB_index)];
%                 end
%                 plot([0:sum(cum_nb_steps)],RB_power_evolution)
%             end
%         end
%         hold off
        break;
    else
        dinkelbach_param = (logsinr+log_sum_theta)/power_consumption;
    end
end