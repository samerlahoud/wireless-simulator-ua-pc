%% load system params
global netconfig
netconfig.debug_level          = 1;         % Debug options  0=no output £» 1=basic output £» 2=extended output
netconfig.nb_users_per_sector  = 8;
netconfig.nb_sectors           = 9;
netconfig.nb_RBs               = 15;
netconfig.total_nb_users       = netconfig.nb_users_per_sector * netconfig.nb_sectors;
netconfig.min_power_per_RB     = 0.1;
netconfig.max_power_per_sector = 60; 
netconfig.power_prop_coeff     = 4.7;
netconfig.power_indep_coeff    = 130;
netconfig.noise_density        = 10^(-20.4);
netconfig.RB_bandwidth         = 180e3;    % Frequency in Hz

