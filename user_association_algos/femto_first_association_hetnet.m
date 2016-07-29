function [user_association] = femto_first_association_hetnet(sinr)

% Get global configuration parameters
global netconfig;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;
nb_femto_BSs = netconfig.nb_femto_BSs;
nb_macro_BSs = netconfig.nb_macro_BSs;
femto_first_sinr = netconfig.femto_first_sinr;

user_association = zeros(nb_users,nb_BSs);
for u = 1:nb_users
    [max_sinr,BS_relative_idx] = max(sinr(u,nb_macro_BSs+1:nb_BSs));
    if max_sinr >= femto_first_sinr
        user_association(u,BS_relative_idx+nb_macro_BSs) = 1;
    else
        [max_sinr,BS_idx] = max(sinr(u,:));
        user_association(u,BS_idx) = 1;
    end
end

end

