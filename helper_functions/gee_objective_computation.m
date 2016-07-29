% Compute GEE objective based on power allocation and SINR values
function [objective] = gee_objective_computation(sinr_matrix, power_allocation_matrix)
% Venturino objective

global netconfig;
nb_sectors=netconfig.nb_sectors;
power_prop_coeff = netconfig.power_prop_coeff;
power_indep_coeff=netconfig.power_indep_coeff;

log_sinr=sum(sum(sum(log(sinr_matrix(sinr_matrix>0)))));
power_consumption = power_prop_coeff*sum(sum(power_allocation_matrix))+nb_sectors*power_indep_coeff;
objective=log_sinr/power_consumption;
end