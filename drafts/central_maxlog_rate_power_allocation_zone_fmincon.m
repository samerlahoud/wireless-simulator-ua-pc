function [power_allocation_matrix, sinr_matrix] = central_maxlog_rate_power_allocation_zone_fmincon(netconfig, pathloss_matrix, BS)
% Tentative log(1+sinr) no success neither in GP nor direct convex
% Centralized approach

total_nb_users=netconfig.total_nb_users;
nb_sectors=netconfig.nb_sectors;
nb_RBs=netconfig.nb_RBs;
max_power_per_sector=netconfig.max_power_per_sector;
noise_density=netconfig.noise_density;

syms power_allocation_matrix p;
for j=1:nb_sectors
    for k=1:nb_RBs
        power_allocation_matrix(j,k)=sprintf('p(%d,%d)',j,k);
    end
end

objective=0;
for j=1:nb_sectors
    for i=BS(j).attached_users
        for k=1:nb_RBs
            interference_mask = eye(nb_sectors,nb_sectors);
            interference_mask(j,j) = 0;
            interference = exp(power_allocation_matrix(:,k)')*interference_mask*pathloss_matrix(i,:,k)';
            sinr = (exp(power_allocation_matrix(j,k))*pathloss_matrix(i,j,k))/(noise_density + interference);
            rate = log(1+sinr);
            objective = objective + log(rate);
        end
    end
end

objective=inline(char(objective),'p');

%for j=1:nb_sectors sum(power_allocation_matrix(j,:)) <= 100*max_power_per_sector;

option=optimset('Display','on','Algorithm','interior-point');
% Consider a starting point where the power ratio equals 1 for all cells
% The lower bound is equal to 0.0001 to avoid numerical instabilities
[rb_optimal_power] = fmincon(objective,ones(nb_sectors,nb_RBs),[],[],[],[],0.0001.*ones(nb_sectors,nb_RBs),5.*ones(nb_sectors,nb_RBs),[],option)
%disp(rb_optimal_power)
%matFilename = sprintf('./results.mat');
%save(matFilename,'rb_optimal_power');