function [eNodeBs,UEs] = central_ee_maxlog_sinr_power_allocation(eNodeBs,UEs,g)
% 
% per-cell scheduling and multi-cell power control
%
global netconfig
N_RB              = netconfig.nb_RBs;
power_prop_coeff  = netconfig.power_prop_coeff;    % Pj(1)
power_indep_coeff = netconfig.power_indep_coeff;
min_power_per_RB  = netconfig.min_power_per_RB;   
number_of_bts     = length(eNodeBs);
%
%% Initial for RB and power per RB allocation
%
% print_log(1,'Initial for RB and power per RB allocation\n');
[eNodeBs,UEs] = sys_init_alloc_power_RB(eNodeBs,UEs,g);
%
%% Transformation of pathloss matrix's dimension 
%
g_temp = dim_transform(g); 
%
%% Per-Cell Scheduling
%
% print_log(1,'Solution of the Per-Cell Scheduling Problem\n');
[eNodeBs,sum_log_theta] = per_cell_scheduling(eNodeBs); 
%
%% Algorithm 1
%
epsilon = 1e-3;  % Maximum tolerance
eta = []; 
current_tti = 1;
iteration_n = 1;
eta(iteration_n) = 0;    % initial value for eta, satisfying F(1)>=0
delta_t = min_power_per_RB^2/current_tti; % initial value for gradient step size 
need_next_iteration = ones(1,number_of_bts);
% 
trace = struct('energy_efficiency',0);

%% Major loop
while (1)    % while objective < epsilon, break
%
% Multi-Cell Power Control
%
while(1)
% compute R2(pi)
[eNodeBs,UEs,sum_log_sinr] = compute_sum_log_sinr(eNodeBs,UEs,g); 
%
% print_log(1,'Solution of the Multi-Cell Power Control Problem\n');
[eNodeBs,UEs,delta_P] = multi_cell_power_control_Gradient_Based(eNodeBs,UEs,g_temp,eta(iteration_n),delta_t,need_next_iteration); % restart for power allocation 
%
for j_=1:number_of_bts
    if(need_next_iteration(j_)~=0)
        if ~any(delta_P(j_,:) > epsilon)
            need_next_iteration(j_) = 0;
        end
    end
end

if ~any(need_next_iteration)
    break;
end
current_tti = current_tti + 1;
delta_t = min_power_per_RB^2/current_tti;
end
% compute R(theta,pi)
utility_value = sum_log_sinr;
% utility_value = sum_log_theta + sum_log_sinr; 
%
% compute P(pi)
power_consumption = 0;
for j_=1:number_of_bts
    power_consumption = power_consumption + sum(eNodeBs(j_).P);
end
power_consumption = power_prop_coeff * power_consumption + number_of_bts * power_indep_coeff;
%
objective = utility_value - eta(iteration_n) * power_consumption;

% save the results of every TTI for analysis
trace(iteration_n).energy_efficiency = eta(iteration_n);
trace(iteration_n).eNodeBs = eNodeBs; 

if (objective < epsilon)
    break;
else
    eta(iteration_n+1) = utility_value/power_consumption;   % compute newer eta
end
iteration_n = iteration_n + 1;
end
%
save('results_trace_eNodeBs.mat','trace','eNodeBs');
%
end

