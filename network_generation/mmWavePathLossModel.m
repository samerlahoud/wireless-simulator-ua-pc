function [ path_loss ] = mmWavePathLossModel( distance_UE_BS, frequency)
 % function to evaluate the urban mmW micro- and picocell pathloss based on the Rappaport model
            % This model is based on an outdoor propagation measurement campaign in New York city
            % cf. Millimeter Wave Channel Modeling and Cellular Capacity Evaluation, published in IEEE JSAC, 2014
            % input:    distance_UE_BS ... actual distance in m
            %           frequency ... both the 28 and 73 GHz are natural candidates for early mmW deployments
            % output:   pathloss in dB
            
            % Pathloss is assumed to have a linear dependence with logarithmic distance + random variation (shadowing 
            % effect: path_loss = alpha + 10*betta*log10(d) + shadowing
            % Model parameter values depend on the mmW frequency as well as on the propagation environment (LOS/NLOS)
                      
mean_shadowing= 0; %in dB

% Randomly choose between a LOS (LOS = 1) and a NLOS environment (LOS = 0)
%LOS = randi([0 1],1,1);
LOS = 0;

% 30 dBm RF power, 24.5 dBi gain at both TX and RX sides

if ((frequency == 28) && (LOS ==1)) % LOS propagation environment
    alpha = 61.4;
    betta = 2;
    std_shadowing = 5.8; % in dB;
    
elseif ((frequency == 28) && (LOS == 0)) % NLOS propagation environment
    alpha = 72.0;
    betta = 2.92;
    std_shadowing = 8.7;
    
elseif ((frequency == 73) && (LOS ==1)) % LOS propagation environment
    alpha = 69.8;
    betta = 2;
    std_shadowing = 5.8;
    
elseif ((frequency == 73) && (LOS ==0)) % NLOS propagation environment
    alpha = 82.7;
    betta = 2.69;
    std_shadowing = 7.7;
end

shadowing = normrnd (mean_shadowing,std_shadowing);
while (shadowing < 0 || shadowing > 10)
    shadowing = normrnd (mean_shadowing,std_shadowing);
end

path_loss = alpha + 10*betta*log10(distance_UE_BS) + shadowing;
end