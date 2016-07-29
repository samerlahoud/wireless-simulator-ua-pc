function [eNodeBs,UEs,sum_log_sinr] = compute_sum_log_sinr(eNodeBs,UEs,pathloss_matrix)
%
% compute R2(pi)
%
global netconfig;
nb_RBs              = netconfig.nb_RBs;
nb_sectors          = netconfig.nb_sectors;
total_nb_users      = netconfig.total_nb_users;
noise_density       = netconfig.noise_density ;
RB_bandwidth        = netconfig.RB_bandwidth;

power_allocation_matrix = zeros(nb_sectors,nb_RBs);
interference            = zeros(total_nb_users,nb_sectors,nb_RBs);
sinr                    = zeros(total_nb_users,nb_sectors,nb_RBs);
log_sinr                = zeros(total_nb_users,nb_sectors,nb_RBs);

% power allocation matrix 
for j_=1:nb_sectors
    power_allocation_matrix(j_,:) = eNodeBs(j_).P;
end
%
for j_=1:nb_sectors
    for i_=eNodeBs(j_).attached_users
        for k_=1:nb_RBs
            interference_mask = eye(nb_sectors,nb_sectors);
            interference_mask(j_,j_) = 0;
            interference(i_,j_,k_) = power_allocation_matrix(:,k_)'*interference_mask*pathloss_matrix(i_,:,k_)';
            sinr(i_,j_,k_)= (power_allocation_matrix(j_,k_)*pathloss_matrix(i_,j_,k_))/(noise_density*RB_bandwidth + interference(i_,j_,k_));
            log_sinr(i_,j_,k_)= log(sinr(i_,j_,k_));
        end
    end
end
%
sum_log_sinr = sum(sum(sum(log_sinr)));    % compute R2(pi)

end
