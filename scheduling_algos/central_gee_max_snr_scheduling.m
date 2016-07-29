function [scheduling_matrix] = central_gee_max_snr_scheduling(pathloss_matrix, power_allocation_matrix, BS)
% Maximize GEE in a downlink multi-cell network in noise limited regime
% Centralized approach
% VENTURINO et al.: SCHEDULING AND POWER ALLOCATION IN OFDMA NETWORKS WITH BS COORDINATION
% Algo 3

global netconfig;

nb_sectors=netconfig.nb_sectors;
nb_users_per_sector=netconfig.nb_users_per_sector;
nb_RBs = netconfig.nb_RBs;
noise_density = netconfig.noise_density;
RB_bandwidth = netconfig.RB_bandwidth;

scheduling_matrix = zeros(nb_users_per_sector*nb_sectors,nb_RBs);

% Random allocation
% for j=1:nb_sectors
%     for k=1:nb_RBs
%         user_tmp_idx = randperm(nb_users_per_sector);
%         user_idx = BS(j).attached_users(user_tmp_idx(1));
%         scheduling_matrix(user_idx,k)=1;
%     end
% end

for j=1:nb_sectors
    scheduled_users_per_sector=[];
    for k=1:nb_RBs
        user_idx=0;
        max_snr=-Inf;
        
        if length(scheduled_users_per_sector) == length(BS(j).attached_users)
            scheduled_users_per_sector=[];
        end
        unscheduled_users = setdiff(BS(j).attached_users,scheduled_users_per_sector);
        
        % Uncomment for round robin
        %for i=unscheduled_users
        for i=BS(j).attached_users
            %user_snr = log(1+pathloss_matrix(i,j,k)*power_allocation_matrix(j,k)/(noise_density*RB_bandwidth));     
            interference_mask = eye(nb_sectors,nb_sectors);
            interference_mask(j,j) = 0;
            interference(i,j,k) = power_allocation_matrix(:,k)'*interference_mask*pathloss_matrix(i,:,k)';
            user_snr = (power_allocation_matrix(j,k)*pathloss_matrix(i,j,k))/(noise_density*RB_bandwidth + interference(i,j,k));
            
            if user_snr > max_snr
                max_snr = user_snr;
                user_idx = i;
            end
        end
        scheduling_matrix(user_idx,k)=1;
        scheduled_users_per_sector=[scheduled_users_per_sector,user_idx];
    end
end