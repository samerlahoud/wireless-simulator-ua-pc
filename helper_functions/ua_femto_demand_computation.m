function [femto_demand] = ua_femto_demand_computation(user_pathloss, BS_to_BS_pathloss, reuse_min_pathloss, nb_femto_RBs)

% If pathloss is higher than reuse_pathloss (130dB for ex), 
%femtos are considered sufficiently far to reuse the spectrum

% Get global configuration parameters
global netconfig;
nb_users = netconfig.nb_users;
nb_femto_BSs = netconfig.nb_femto_BSs;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;

femto_to_femto_pathloss = BS_to_BS_pathloss(nb_macro_BSs+1:nb_macro_femto_BSs,...
    nb_macro_BSs+1:nb_macro_femto_BSs);
user_femto_pathloss = user_pathloss(:,nb_macro_BSs+1:nb_macro_femto_BSs);
femto_demand = zeros(nb_femto_BSs,1);

user_femto_association = zeros(nb_users,nb_femto_BSs);
for u = 1:nb_users
    [~,femto_idx] = min(user_femto_pathloss(u,:));
    user_femto_association(u,femto_idx) = 1;
end

nb_users_per_femto = sum(user_femto_association)';
nb_concurrent_users_per_femto = zeros(nb_femto_BSs,1);

for f=1:nb_femto_BSs
    if nb_users_per_femto(f) == 0
        femto_demand(f) = 0;
    else
        for g=1:nb_femto_BSs
            if (femto_to_femto_pathloss(f,g) < reuse_min_pathloss)
                nb_concurrent_users_per_femto(f) = nb_concurrent_users_per_femto(f) + nb_users_per_femto(g);
            end
        end
        if nb_concurrent_users_per_femto(f) == 0
            nb_concurrent_users_per_femto(f) = nb_users_per_femto(f);
        end
        femto_demand(f) = ceil((nb_users_per_femto(f)/nb_concurrent_users_per_femto(f)).*nb_femto_RBs);
    end
end
end