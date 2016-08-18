% load system params
global netconfig
netconfig.debug_level = 1;         % Debug options  0=no output 1=basic output 2=extended output
netconfig.gradient_step = 0.01; % step is usually 0.001 as for distributed BR (overloaded in the corresponding function)
netconfig.gradient_convergence_eps = 1e-3; % 1e-3 for centralized 1e-6 for distributed BR

netconfig.nb_iterations = 5;
netconfig.nb_users = 100;
netconfig.nb_RBs = 100;

netconfig.RB_bandwidth = 180e3;         % Frequency in Hz
netconfig.macro_tx_power = 10^(4.3-3);    % in Watt (43dBm)
netconfig.femto_tx_power = 10^(2.5-3);    % in Watt (25dBm)

netconfig.tx_antenna_gain = 10^(15/10);   % in dBi
netconfig.rx_antenna_gain = 1;            % dBi "LTE, the UMTS long term evolution: from theory to practice by Stefania Sesia, Issam Toufik, Matthew Baker pg 517 (22.4.1)"
netconfig.noise_density        = 10^(-20.4);
%netconfig.thermal_noise_power = 1e-14;  % in Watt (-110dBm)
netconfig.femto_first_sinr = -2;
netconfig.range_extension_bias = 5;
netconfig.reuse_min_pathloss = 1e+13;
netconfig.user_distribution = 'normal'; % 'uniform' or 'normal'

% mmwave params
netconfig.mmwave_tx_power = 1;    % in Watt (30dBm)
netconfig.mmwave_bandwidth = 1e9; % 1 GHz
netconfig.mmwave_tx_antenna_gain = 10^(15/10);   % 24 in dBi in Rappapport et al. 
netconfig.mmwave_rx_antenna_gain = 1;