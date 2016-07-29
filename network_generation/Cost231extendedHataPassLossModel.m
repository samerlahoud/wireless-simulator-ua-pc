function [ path_loss ] = Cost231extendedHataPassLossModel( distance_UE_BS, type_environment)
 % function to evaluate the suburban macrocell pathloss based on the COST 231
            % extended Hata model, see 3GPP TR25.996 and 3gpp TR 36.942 (rural) and COST 231 book
            % (c) Martin Wrulich, INTHFT
            % input:    distance_UE_BS ... actual distance in m
            % output:   pl_NLOS  ... NLOS pathloss in dB
            
            % for d_min = 35 => path loss = 99.4590 with shadowing = 10 dB  and 'urban'; 
            % for d= cell_range= 500 m =>  path loss = 140.1403 with shadowing = 10 dB and 'urban';
            
frequency= 2000; %frequency in MHz
distance_UE_BS= distance_UE_BS./1000; % distance in Km
path_loss=0;
mean_shadowing= 0; %in dB
std_shadowing = 10; % in dB;

shadowing = normrnd (0,10);
while (shadowing < 0 || shadowing > 10)
    shadowing = normrnd (0,10);
end

 % values according to TR25.996
if type_environment == 'urban'
    Cm = 3;
    h_base = 30; %3gpp TR 36.942
    h_mobile = 1.5;
                           
    a = (1.1*log10(frequency) - 0.7)*h_mobile - ...
        (1.56*log10(frequency)-0.8);

    path_loss = 46.3 + 33.9*log10(frequency) - 13.82*log10(h_base) - a + (44.9 - 6.55*log10(h_base))*log10(distance_UE_BS) + Cm + shadowing; 
                
elseif type_environment == 'rural'
       h_base= 45;
                
       path_loss = 69.55 + 26.16*log10(frequency) - 13.82*log10(h_base) + ...
           (44.9 - 6.55*log10(h_base))*log10(distance_UE_BS) - 4.78*(log10(frequency))^2 + 18.33*log10(frequency)-40.94 + shadowing;                      
end

end

