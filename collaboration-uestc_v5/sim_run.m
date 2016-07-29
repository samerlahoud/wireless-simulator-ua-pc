%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation of Joint scheduling and power control for energy efficiency in
% multi-cell networks (2015)
% Samer Lahoud samer.lahoud@irisa.fr
% Kinda Khawam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
tic;

% General simulator configuration
netconfig.nb_iterations=2;
netconfig.nb_users_per_sector=8;
netconfig.nb_sectors=9;
netconfig.nb_RBs=15;
netconfig.total_nb_users=netconfig.nb_users_per_sector*netconfig.nb_sectors;
netconfig.min_power_per_RB=0;
netconfig.max_power_per_sector=60;
netconfig.power_prop_coeff = 4.7;
netconfig.power_indep_coeff = 130;
netconfig.noise_density=10^(-13);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute energy efficiency solutions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:netconfig.nb_iterations
    [BS,user,pathloss_matrix]=generate_radio_conditions(netconfig);
    complete_time = algo_compute_ee(netconfig, BS, pathloss_matrix, i);
end