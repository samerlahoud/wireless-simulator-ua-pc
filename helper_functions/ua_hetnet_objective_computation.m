function [user_rate, objective_value] = ua_hetnet_objective_computation(peak_rate, user_association)

% Get global configuration parameters
global netconfig;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;

user_rate = zeros(nb_users,1);
objective_value = 0;

% for u = 1:nb_users
%     associated_BS_idx = find(user_association(u,:)==1);
%     user_rate(u) = peak_rate(u,associated_BS_idx)/sum(user_association(:,associated_BS_idx));
% end

for u = 1:nb_users
    for b = 1:nb_BSs
        if sum(user_association(:,b)) >= 1e-4
            user_rate(u) = user_rate(u) + user_association(u,b)*peak_rate(u,b)/sum(user_association(:,b));
        end
    end
end

for u = 1:nb_users
    for b = 1:nb_BSs
        if peak_rate(u,b) >= 1e-4 && sum(user_association(:,b)) >= 1e-4
            objective_value = objective_value + user_association(u,b)*log(peak_rate(u,b)/sum(user_association(:,b)));
        end
    end
end

end

