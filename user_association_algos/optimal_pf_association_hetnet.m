function [user_association] = optimal_pf_association_hetnet(peak_rate)

global netconfig;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;

% Geometric programming formulation of the problem
cvx_begin
cvx_solver mosek
variable theta(nb_users,nb_BSs) %binary

% Expressions used in computations
expression nb_users_per_BS(nb_BSs)
expression lin_expression_obj
expression log_expression_obj

for u = 1:nb_users
    for b = 1:nb_BSs
        if peak_rate(u,b) >= 1e-4
            lin_expression_obj = lin_expression_obj + theta(u,b)*log(peak_rate(u,b));
        end
    end
end

for b = 1:nb_BSs
    nb_users_per_BS(b) = sum(theta(:,b));
end

log_expression_obj = sum(entr(nb_users_per_BS));

objective = lin_expression_obj + log_expression_obj;
maximize(objective)

subject to
for u = 1:nb_users
    sum(theta(u,:)) <= 1;
end
% Adding BS occupancy constraint
% for b = 1:nb_BSs
%     sum(theta(:,b)) <= 1;
% end

% for u = 1:nb_users
%     for b = 1:nb_BSs
%         if peak_rate(u,b) == 0
%             theta(u,b) == 0;
%         end
%     end
% end
% QoS constraint? 
0 <= theta <= 1;
cvx_end

user_association = theta;
for u = 1:nb_users
    for b = 1:nb_BSs
        if user_association(u,b) <= 1e-4
            user_association(u,b) = 0;
        elseif user_association(u,b) >= 0.9999
            user_association(u,b) = 1;
        end
    end
end

end

