function [power_allocation_matrix] = central_max_SE_power_allocation_gp(netconfig, pathloss_matrix, BS)
% Maximize spectral efficiency in a downlink multi-cell network
% Centralized approach

total_nb_users=netconfig.total_nb_users;
nb_sectors=netconfig.nb_sectors;
nb_RBs=netconfig.nb_RBs;
min_power_per_RB=netconfig.min_power_per_RB;
max_power_per_RB=netconfig.max_power_per_RB;
noise_density=netconfig.noise_density;

min_power_vector=min_power_per_RB*ones(nb_sectors,nb_RBs);
max_power_vector=max_power_per_RB*ones(nb_sectors,nb_RBs);

% Geometric programming formulation of the problem
cvx_begin gp
cvx_solver mosek
% variables are power levels
variable power_allocation_matrix(nb_sectors,nb_RBs)
variable user_sinr(total_nb_users)

% Expressions used in computations
expression interference(nb_sectors,total_nb_users,nb_RBs)
expression sinr(total_nb_users)

for j=1:nb_sectors
    for i=BS(j).attached_users
        for k=1:nb_RBs
            interference_mask = eye(nb_sectors,nb_sectors);
            interference_mask(j,j) = 0;
            interference(i,j,k) = power_allocation_matrix(:,k)'*interference_mask*pathloss_matrix(i,:)';
        end
    end
end

for i=1:total_nb_users
    sinr(i)=0;
    for j=1:nb_sectors
        if any(BS(j).attached_users == i)
            for k=1:nb_RBs
                sinr(i)=sinr(i)+log((power_allocation_matrix(j,k)*pathloss_matrix(i,j))/(noise_density + interference(i,j,k)));           
            end
        end
    end 
end

maximize(sum(log(user_sinr)))

subject to
% constraints are power limits
min_power_vector <= power_allocation_matrix <= max_power_vector;
for i=1:total_nb_users
    sinr(i) >= user_sinr(i) 
end
%sum(power_allocation_matrix) <= 10;
% for j=1:nb_sectors
%     for i=BS(j).attached_users
%         for k=1:nb_RBs
%             (power_allocation_matrix(j,k)*pathloss_matrix(i,j))/(noise_density + interference(i,j,k)) >= 0.001;
%         end
%     end
% end
cvx_end
user_sinr