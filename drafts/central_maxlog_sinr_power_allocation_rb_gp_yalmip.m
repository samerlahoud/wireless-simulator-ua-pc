function [power_allocation_matrix, sinr_matrix] = central_maxlog_sinr_power_allocation_rb_gp_yalmip(netconfig, pathloss_matrix, BS)
% Maximize total SINR in a downlink multi-cell network in obscure YALMIP
% Centralized approach

total_nb_users=netconfig.total_nb_users;
nb_sectors=netconfig.nb_sectors;
nb_RBs=netconfig.nb_RBs;
max_power_per_sector=netconfig.max_power_per_sector;
noise_density=netconfig.noise_density;

% variables are power levels
power_allocation_matrix=sdpvar(nb_sectors,nb_RBs);
sinr_tilde=sdpvar(total_nb_users,nb_sectors,nb_RBs);
rate_tilde=sdpvar(total_nb_users,nb_sectors,nb_RBs);
sinr_matrix=sdpvar(total_nb_users,nb_sectors,nb_RBs);

for j=1:nb_sectors
    for i=BS(j).attached_users
        for k=1:nb_RBs
            interference_mask = eye(nb_sectors,nb_sectors);
            interference_mask(j,j) = 0;
            interference = exp(power_allocation_matrix(:,k)')*interference_mask*pathloss_matrix(i,:,k)';
            sinr = (exp(power_allocation_matrix(j,k))*pathloss_matrix(i,j,k))/(noise_density + interference);
            sinr_matrix(i,j,k) = sinr;
        end
    end
end

Constraints=[];
for j=1:nb_sectors
    Constraints = [Constraints, sum(exp(power_allocation_matrix(j,:))) <= max_power_per_sector];
end
for j=1:nb_sectors
    for i=BS(j).attached_users
        for k=1:nb_RBs
            Constraints = [Constraints, sinr_tilde(i,j,k) <= log(sinr_matrix(i,j,k)), rate_tilde(i,j,k) <= sinr_tilde(i,j,k)];
        end
    end
end

Objective = 0;
for j=1:nb_sectors
    for i=BS(j).attached_users
        for k=1:nb_RBs
            Objective = Objective + log(log(exp(rate_tilde(i,j,k))+1)); 
        end
    end
end

optimize(Constraints,-Objective);
value(sinr_tilde)
value(power_allocation_matrix)

sinr_matrix = sinr;