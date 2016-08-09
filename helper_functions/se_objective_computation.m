% Compute SE (numerator in EE objective) based on SINR values
function [objective] = se_objective_computation(sinr_matrix)

global netconfig;
nb_sectors=netconfig.nb_sectors;
power_prop_coeff = netconfig.power_prop_coeff;
power_indep_coeff=netconfig.power_indep_coeff;

log_sinr=sum(sum(sum(log(sinr_matrix(sinr_matrix>0)))));
log_sum_theta = scheduling_objective_computation;
objective=(log_sinr+log_sum_theta);
end