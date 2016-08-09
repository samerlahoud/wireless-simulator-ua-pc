% Compute per BS EE objective based on power allocation and SINR values
function [objective] = ee_bs_objective_computation(BS, sinr_matrix, power_allocation_matrix)

global netconfig;
nb_sectors=netconfig.nb_sectors;
nb_RBs=netconfig.nb_RBs;
power_prop_coeff = netconfig.power_prop_coeff;
power_indep_coeff=netconfig.power_indep_coeff;

log_sinr=zeros(1,nb_sectors);
for j=1:nb_sectors
    for i=BS(j).attached_users
        for k=1:nb_RBs
            log_sinr(j)=log_sinr(j)+log(sinr_matrix(i,j,k));
        end
    end
end
power_consumption = power_prop_coeff*sum(power_allocation_matrix,2)+power_indep_coeff;
objective=log_sinr./power_consumption';
end

