function [user_association] = power_based_association_hetnet(rx_RB_power)

% Get global configuration parameters
global netconfig;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;

user_association = zeros(nb_users,nb_BSs);
for u = 1:nb_users
    [max_power,BS_idx] = max(rx_RB_power(u,:));
    user_association(u,BS_idx) = 1;
end

end