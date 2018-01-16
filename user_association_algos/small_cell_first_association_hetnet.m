function [user_association] = small_cell_first_association_hetnet(rx_power)

% Get global configuration parameters
global netconfig;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;
nb_macro_BSs = netconfig.nb_macro_BSs;
small_cell_first_power_ratio = netconfig.small_cell_first_power_ratio;

user_association = zeros(nb_users,nb_BSs);
for u = 1:nb_users
    [max_sc_power,BS_relative_idx] = max(rx_power(u,nb_macro_BSs+1:nb_BSs));
    [max_power,BS_idx] = max(rx_power(u,:));
    if max_sc_power >= max_power*small_cell_first_power_ratio
        user_association(u,BS_relative_idx+nb_macro_BSs) = 1;
    else
        user_association(u,BS_idx) = 1;
    end
end

end

