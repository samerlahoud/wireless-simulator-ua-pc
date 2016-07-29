function [eNodeBs,sum_log_theta] = per_cell_scheduling(eNodeBs)
% 
% per-cell scheduling  
%
global netconfig;
%
N_RB          = netconfig.nb_RBs;
UE_per_eNodeB = netconfig.nb_users_per_sector;
number_of_bts = length(eNodeBs);

if N_RB <= UE_per_eNodeB
    theta = ones(1,N_RB)/UE_per_eNodeB; % 1*k
else
    theta = ones(1,N_RB)/N_RB; % 1*k
end

sum_log_theta = 0;  % compute R1(theta), the result is optimal value

for j_=1:number_of_bts
    eNodeBs(j_).theta = theta; 
    sum_log_theta = sum_log_theta + sum(log(theta));  
end

end