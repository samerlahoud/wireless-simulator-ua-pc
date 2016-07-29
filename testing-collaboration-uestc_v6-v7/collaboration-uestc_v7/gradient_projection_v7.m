clear;
clc;
%load('test_conditions');
load_params;
[eNodeBs,UEs,pathloss_matrix]=generate_radio_conditions;

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

% Initial value can be arbitrary
power_allocation_matrix=ones(nb_sectors,nb_RBs)*1;

% Choose the numebr of steps
max_nb_steps = 5000;

% Starting Dinkelbach parameter
eta                  =  2;

while(1) 
    % for delta = 0.1 reduce every 100 steps
    % for delta = 0.01 reduce every 500 steps
    delta=0.001;
    epsilon=1e-4;
    
    for s=1:max_nb_steps
        % Divide delta if needed to speed up the convergence
        % if mod(s,500)==0
        %   delta=delta/2;
        %end
        
        previous_power_allocation_matrix = power_allocation_matrix;
        
        % Compute the gradient with the new modified expression
        for j=1:nb_sectors
            for k=1:nb_RBs
                partial_grad = 0;
                for l=1:nb_sectors
                    if l == j
                        continue;
                    else
                        for i=eNodeBs(l).attached_users
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
                    delta*(nb_users_per_sector/power_allocation_matrix(j,k) - partial_grad - eta * power_prop_coeff);
                
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
        if(power_convergence<epsilon)
            disp('convergence');
            break;
        end
    end
    
    % Objective computation with no modification from v6
    logsinr=0;
    for j=1:nb_sectors
        for i=eNodeBs(j).attached_users
            for k=1:nb_RBs
                interference_mask = eye(nb_sectors,nb_sectors);
                interference_mask(j,j) = 0;
                interference = power_allocation_matrix(:,k)'*interference_mask*pathloss_matrix(i,:,k)';
                sinr= (power_allocation_matrix(j,k)*pathloss_matrix(i,j,k))/(noise_density*RB_bandwidth + interference);
                logsinr = logsinr + log(sinr);
            end
        end
    end
    power_consumption = power_prop_coeff*sum(sum(power_allocation_matrix))+nb_sectors*power_indep_coeff;
    objective=logsinr - eta * power_consumption
    
    % Dinkelbach convergence
    if (abs(objective) < 0.1)
        break;
    else
        eta = logsinr/power_consumption
    end
end