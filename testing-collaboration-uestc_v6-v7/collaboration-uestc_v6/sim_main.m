%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute energy efficiency solutions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initial for metwork model
%
print_log(1,'Initialization of metwork model\n');
[eNodeBs,UEs,pathloss_matrix]=generate_radio_conditions;  % return the pathloss matrix
%
%% cvx solutions 
%
print_log(1,'realization of cvx solution\n');
complete_time = algo_compute_ee_cvx(netconfig,eNodeBs,pathloss_matrix); 
%
%% Algorithm 1 solutions for the Decoupled Energy Efficiency Problem
%
print_log(1,'realization of Algorithm 1\n');
[eNodeBs,UEs] = central_ee_maxlog_sinr_power_allocation(eNodeBs,UEs,pathloss_matrix); 
%
