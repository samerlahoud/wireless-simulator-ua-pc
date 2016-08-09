function [user_association] = range_extension_association_hetnet(sinr)

% Get global configuration parameters
global netconfig;
nb_BSs = netconfig.nb_BSs;
nb_users = netconfig.nb_users;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_femto_BSs = netconfig.nb_femto_BSs;
range_extension_bias = netconfig.range_extension_bias;

user_association = zeros(nb_users,nb_BSs);
biased_sinr = sinr + [zeros(nb_users,nb_macro_BSs), ones(nb_users,nb_femto_BSs)+range_extension_bias];
for u = 1:nb_users
    %[min_pathloss,BS_idx] = min(pathloss(u,:));
    [max_sinr,BS_idx] = max(biased_sinr(u,:));
    user_association(u,BS_idx) = 1;
end

end

