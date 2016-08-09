function [isNE] = ee_bs_gt_equilibrium_test(pathloss_matrix, BS, power_allocation_matrix, sinr_matrix)
global netconfig;
nb_sectors=netconfig.nb_sectors;
min_power_per_RB=netconfig.min_power_per_RB;
max_power_per_sector=netconfig.max_power_per_sector;
nb_RBs=netconfig.nb_RBs;
%load_params
%[BS,user,pathloss_matrix]=generate_radio_conditions;
%[power_allocation_matrix, sinr_matrix] = distributed_gt_ee_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS);

[objective] = ee_bs_objective_computation(BS, sinr_matrix, power_allocation_matrix);
isNE=true;

for j=1:nb_sectors
   perturb_power_allocation_matrix = power_allocation_matrix;
   max_power_margin = max_power_per_sector - sum(power_allocation_matrix(j,:));
   if max_power_margin <= 1e-4
       continue
   else
       perturb_power_allocation_matrix(j,:) = perturb_power_allocation_matrix(j,:)+min(0.1,max_power_margin/nb_RBs);
   end
   perturb_sinr_matrix = sinr_computation(pathloss_matrix, BS, perturb_power_allocation_matrix);
   [perturb_objective] = ee_bs_objective_computation(BS, perturb_sinr_matrix, perturb_power_allocation_matrix);
   if perturb_objective(j) > objective(j)
       disp('not an equilibrium');
       isNE=false;
   %else
   %    perturb_objective(j) - objective(j)
   end
end

for j=1:nb_sectors
   perturb_power_allocation_matrix = power_allocation_matrix;
   min_power_margin = min(power_allocation_matrix(j,:)) - min_power_per_RB;
   if min_power_margin <= 1e-4
       continue
   else
       perturb_power_allocation_matrix(j,:) = perturb_power_allocation_matrix(j,:)-min(0.1,min_power_margin);
   end
   perturb_sinr_matrix = sinr_computation(pathloss_matrix, BS, perturb_power_allocation_matrix);
   [perturb_objective] = ee_bs_objective_computation(BS, perturb_sinr_matrix, perturb_power_allocation_matrix);
   if perturb_objective(j) > objective(j)
       disp('not an equilibrium');
       isNE=false;
   end
end

end

