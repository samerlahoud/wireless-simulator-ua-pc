%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation of Joint scheduling and power control for energy efficiency in
% multi-cell networks (2015)
% Samer Lahoud samer.lahoud@irisa.fr
% Kinda Khawam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;    % CLOSE ALL  closes all the open figure windows.
clc;          % CLC clears the command window and homes the cursor.
clear;        % CLEAR  Clear variables and functions from memory.
clear global; % CLEAR GLOBAL removes all global variables.
tic;

%% General simulator configuration
%
load_params;
print_log(1,'General simulator configuration\n');
%
sim_main;
%
print_log(1,'result_analysis\n');
result_analysis;
