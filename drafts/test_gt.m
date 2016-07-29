function [power_allocation_matrix, sinr_matrix, time_structure] = test_gt(pathloss_matrix, BS)
% Compute selfish energy efficiency based on projected subgradient
% Numerator is given by the sum-log-sinr
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
dinkelbach_param_vector = dinkelbach_param.*ones(1,nb_sectors);

% Initial value can be arbitrary
%power_allocation_matrix=3*rand(nb_sectors,nb_RBs);
%power_allocation_matrix=ones(nb_sectors,nb_RBs)*max_power_per_sector/nb_RBs;
power_allocation_matrix=ones(nb_sectors,nb_RBs)*min_power_per_RB;

% Cumulate power but this is not necessary
cumulative_power_allocation_matrix=[power_allocation_matrix];

% Choose the number of steps
nb_steps = 5000;
nb_rounds = 0;
nb_subgrad_steps=0;

tic;
while(1)
    nb_rounds = nb_rounds + 1;
    previous_power_allocation_matrix = power_allocation_matrix;
    % Iterate over sectors
    for j=1:nb_sectors
        %dinkelbach_param = netconfig.starting_dinkelbach_param;
        % EE for each sector
        while(1)
            for s=0:nb_steps
                % Divide delta if needed to speed up the convergence
                if mod(s,250)==0 && min_power_per_RB < 0.1
                    gradient_step=gradient_step/4;
                end
                previous_power_allocation_vector = power_allocation_matrix(j,:);
                for k=1:nb_RBs
                    power_allocation_matrix(j,k) = power_allocation_matrix(j,k) + ...
                        gradient_step*(nb_users_per_sector/power_allocation_matrix(j,k) - dinkelbach_param_vector(j) * power_prop_coeff);
                    nb_subgrad_steps=nb_subgrad_steps+1;
                    
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
                % Convergence test
                power_convergence = norm(power_allocation_matrix(j,:) - previous_power_allocation_vector);
                if(power_convergence<gradient_convergence_eps)
                    %disp('cell convergence');
                    cumulative_power_allocation_matrix=[cumulative_power_allocation_matrix;power_allocation_matrix];
                    break;
                end
            end
            
            logsinr=0;
            for i=BS(j).attached_users
                for k=1:nb_RBs
                    interference_mask = eye(nb_sectors,nb_sectors);
                    interference_mask(j,j) = 0;
                    interference = power_allocation_matrix(:,k)'*interference_mask*pathloss_matrix(i,:,k)';
                    sinr=(power_allocation_matrix(j,k)*pathloss_matrix(i,j,k))/(noise_density*RB_bandwidth + interference);
                    logsinr=logsinr+log(sinr);
                end
            end
            power_consumption = power_prop_coeff*sum(power_allocation_matrix(j,:))+power_indep_coeff;
            
            if nb_users_per_sector < nb_RBs
                log_sum_theta = nb_RBs*nb_users_per_sector*log(1/nb_RBs);
            else
                log_sum_theta = nb_RBs*nb_users_per_sector*log(1/nb_users_per_sector);
            end
            %%
            %%log_sum_theta=0;
            objective = (logsinr+log_sum_theta) - dinkelbach_param_vector(j) * power_consumption;
            if (abs(objective) < 0.1)
                %disp('sector dinkelbach convergence');
               % cumulative_power_allocation_matrix=[cumulative_power_allocation_matrix;power_allocation_matrix];
                break;
            else
                dinkelbach_param_vector(j) = (logsinr+log_sum_theta)/power_consumption;
            end
        end
    end
    %cumulative_power_allocation_matrix=[cumulative_power_allocation_matrix;power_allocation_matrix];
    % Convergence test
    power_convergence = norm(power_allocation_matrix - previous_power_allocation_matrix);
    if(power_convergence<gradient_convergence_eps)
%         disp('convergence');
        [plot_round,x]=size(cumulative_power_allocation_matrix);
        plot_round = plot_round/nb_sectors;
        hold on
        for sector_index=1:nb_sectors
            for RB_index=1:nb_RBs
                RB_power_evolution=[];
                for iteration_index=0:plot_round-1
                    RB_power_evolution = [RB_power_evolution, ...
                        cumulative_power_allocation_matrix(sector_index+iteration_index*nb_sectors,RB_index)];
                end
                plot([0:plot_round-1],RB_power_evolution)
            end
        end
        hold off
        sinr_matrix=sinr_computation(pathloss_matrix, BS, power_allocation_matrix);
        break;
    end
end
total_time=toc;
time_structure = struct('steps', nb_subgrad_steps, 'rounds', nb_rounds, 'time', total_time);
%plot([1:3109],cumulative_power_allocation_matrix)
%save('./output/distributed_gt_ee_maxlog_power_iteration.mat', 'cumulative_power_allocation_matrix');
