function [user_association] = sinr_based_association_hetnet(sinr)

% Get global configuration parameters
global netconfig;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;

user_association = zeros(nb_users,nb_BSs);
for u = 1:nb_users
    [max_sinr,BS_idx] = max(sinr(u,:));
    user_association(u,BS_idx) = 1;
end

end