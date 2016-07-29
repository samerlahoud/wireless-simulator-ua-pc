% load system params
global netconfig
netconfig.debug_level          = 1;         % Debug options  0=no output ?? 1=basic output ?? 2=extended output
netconfig.inter_site_dist      = 500; % 250 or 500m
netconfig.user_max_dist        = 200; % up to 200 for inter_site_dist 500m
netconfig.nb_RBs               = 15;
netconfig.min_power_per_RB     = 0.1;  % should be striclty larger than 0, beware of instability (reduce gradient step for 0.01)    
netconfig.power_prop_coeff     = 4.7;
netconfig.power_indep_coeff    = 130;
netconfig.noise_density        = 10^(-20.4);
netconfig.RB_bandwidth         = 180e3;    % Frequency in Hz
netconfig.nb_iterations        = 30;
netconfig.gradient_step        = 0.001;
netconfig.gradient_convergence_eps = 1e-4; % best 1e-4
netconfig.starting_dinkelbach_param =  2; %-0.4;

% netconfig.sectorized           = true;
% netconfig.nb_sectors           = 7; %best interfereing sectorized seven
% netconfig.max_power_per_sector = 20; %or should be divided by 3?
% netconfig.nb_users_per_sector  = 10;

netconfig.sectorized           = false;
netconfig.nb_sectors           = 7;
netconfig.max_power_per_sector = 20;
netconfig.nb_users_per_sector  = 10;

% netconfig.sectorized           = false;
% netconfig.nb_sectors           = 9;
% netconfig.max_power_per_sector = 20;
% netconfig.nb_users_per_sector  = 8;

netconfig.total_nb_users       = netconfig.nb_users_per_sector * netconfig.nb_sectors;
