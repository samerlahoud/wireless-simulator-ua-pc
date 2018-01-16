function [user_association] = peak_rate_based_association_hetnet(peak_rate)

% Get global configuration parameters
global netconfig;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;

user_association = zeros(nb_users,nb_BSs);
for u = 1:nb_users
    [max_peak_rate,BS_idx] = max(peak_rate(u,:));
    user_association(u,BS_idx) = 1;
end

end