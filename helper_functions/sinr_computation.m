% Compute SINR based on power allocation
function [sinr_matrix] = sinr_computation(pathloss_matrix, BS, power_allocation_matrix)

global netconfig;
nb_sectors = netconfig.nb_sectors;
nb_RBs=netconfig.nb_RBs;
noise_density=netconfig.noise_density;
RB_bandwidth=netconfig.RB_bandwidth;
total_nb_users=netconfig.total_nb_users;

sinr_matrix =zeros(total_nb_users,nb_sectors,nb_RBs);
for j=1:nb_sectors
    for i=BS(j).attached_users
        for k=1:nb_RBs
            interference_mask = eye(nb_sectors,nb_sectors);
            interference_mask(j,j) = 0;
            interference = power_allocation_matrix(:,k)'*interference_mask*pathloss_matrix(i,:,k)';
            sinr_matrix(i,j,k)= (power_allocation_matrix(j,k)*pathloss_matrix(i,j,k))/(noise_density*RB_bandwidth + interference);
        end
    end
end

end

