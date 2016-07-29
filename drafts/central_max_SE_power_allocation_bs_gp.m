function [power_allocation_vector] = central_max_SE_power_allocation_gp(netconfig, pathloss_matrix, BS)
% Maximize spectral efficiency in a downlink multi-cell network
% Centralized approach

total_nb_users=netconfig.total_nb_users;
nb_sectors=netconfig.nb_sectors;
nb_RBs=netconfig.nb_RBs;
min_power_vector=netconfig.max_power_per_RB*ones(nb_sectors,1);
max_power_vector=netconfig.max_power_per_RB*ones(nb_sectors,1);
noise_density=netconfig.noise_density;

% Geometric programming formulation of the problem
cvx_begin gp
cvx_solver mosek
% variables are power levels
variable power_allocation_vector(nb_sectors)

% Expressions used in computations
expression interference(nb_sectors,total_nb_users)
expression objective

for j=1:nb_sectors
    for i=BS(j).attached_users
        %for k=1:nb_RBs
            interference_mask = eye(nb_sectors,nb_sectors);
            interference_mask(j,j) = 0;
            %interference(i,j,k) = power_allocation_matrix(:,k)'*interference_mask*pathloss_matrix(i,:)';
            interference(i,j) = power_allocation_vector'*interference_mask*pathloss_matrix(i,:)';
        %end
    end
end

objective=0;
for j=1:nb_sectors
    for i=BS(j).attached_users
        %for k=1:nb_RBs
            %objective = objective + log((power_allocation_matrix(j,k)*pathloss_matrix(i,j))/(noise_density + interference(i,j,k)));
            objective = objective + log((power_allocation_vector(j)*pathloss_matrix(i,j))/(noise_density + interference(i,j)));
         %end
    end
end
maximize(objective)

subject to
% constraints are power limits
min_power_vector <= power_allocation_vector <= max_power_vector;
% for j=1:nb_sectors
%     for i=BS(j).attached_users
%         %for k=1:nb_RBs
%             %objective = objective + log((power_allocation_matrix(j,k)*pathloss_matrix(i,j))/(noise_density + interference(i,j,k)));
%             log((power_allocation_vector(j)*pathloss_matrix(i,j))/(noise_density + interference(i,j))) >= -10^-20;
%          %end
%     end
% end

%SINR >= 0.02
cvx_end