function [theta] = central_max_sinr_scheduling_rb_gp(netconfig, pathloss_matrix, BS)
% Maximize spectral efficiency in a downlink multi-cell network
% Centralized approach

nb_users_per_sector = netconfig.nb_users_per_sector;
total_nb_users=netconfig.total_nb_users;
nb_sectors=netconfig.nb_sectors;
nb_RBs=netconfig.nb_RBs;

theta = zeros(nb_users_per_sector,nb_sectors,nb_RBs)
for j=1:nb_sectors
    for i=BS(j).attached_users
        theta(i,j,:) = 1/size(BS(1).attached_users,2);
    end
end
% % Geometric programming formulation of the problem
% cvx_begin gp
% cvx_solver mosek
% % variables are allocation ratios
% variable theta(total_nb_users,nb_RBs)
% 
% maximize(sum(sum(log(theta))))
% 
% subject to
% for i=1:total_nb_users
%     sum(theta(i,:)) <= 1;
% end
% for k=1:nb_RBs
%     sum(theta(:,k)) <= 1;
% end
%cvx_end