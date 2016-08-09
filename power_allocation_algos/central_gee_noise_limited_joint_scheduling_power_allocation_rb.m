%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Maximize GEE in a downlink multi-cell network in noise limited regime
% Centralized approach
% VENTURINO et al.: SCHEDULING AND POWER ALLOCATION IN OFDMA NETWORKS WITH BS COORDINATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [power_allocation_matrix, sinr_matrix] = central_gee_noise_limited_joint_scheduling_power_allocation_rb(pathloss_matrix, BS)
% Maximize geometric enegry effciency in a downlink multi-cell network
% Centralized approach
% Compute energy efficiency with CVX
% Numerator is given by the GEE algo 3

global netconfig;

nb_RBs = netconfig.nb_RBs;
nb_sectors=netconfig.nb_sectors;
min_power_per_RB = netconfig.min_power_per_RB;
max_power_per_sector = netconfig.max_power_per_sector;
power_prop_coeff = netconfig.power_prop_coeff;
power_indep_coeff = netconfig.power_indep_coeff;

%power_allocation_matrix=ones(nb_sectors,nb_RBs)*min_power_per_RB;
power_allocation_matrix=ones(nb_sectors,nb_RBs)*max_power_per_sector/nb_RBs;
while(1)
    old_power_allocation_matrix = power_allocation_matrix;
    [scheduling_matrix] = central_gee_max_snr_scheduling(pathloss_matrix, power_allocation_matrix, BS);
    [power_allocation_matrix, sinr_matrix] = central_gee_noise_limited_power_allocation_rb(pathloss_matrix, scheduling_matrix, BS);
    %gee_objective_computation(sinr_matrix, power_allocation_matrix)
    if norm(old_power_allocation_matrix - power_allocation_matrix) < 1e-3
        break;
    end
end