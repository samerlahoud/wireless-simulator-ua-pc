function [user_association] = best_response_pf_association_hetnet(peak_rate)

global netconfig;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;

user_association = 0.1.*ones(nb_users,nb_BSs);

while(1)
    previous_user_association = user_association;
    for u=1:nb_users
        % Geometric programming formulation of the problem
        cvx_begin quiet
        cvx_solver mosek
        variable theta(nb_BSs) %binary
        
        % Expressions used in computations
        expression nb_users_per_BS(nb_BSs)
        expression concurrent_user_association(nb_BSs)
        expression substract_term(nb_BSs)
        expression lin_expression_obj
        expression log_expression_obj
        
        for b = 1:nb_BSs
            if peak_rate(u,b) >= 1e-4
                lin_expression_obj = lin_expression_obj + theta(b)*log(peak_rate(u,b));
            end
        end
        
        for b = 1:nb_BSs
            concurrent_user_association(b) = sum(user_association(:,b)) - user_association(u,b);
            nb_users_per_BS(b) = theta(b) + concurrent_user_association(b);
            substract_term(b) = concurrent_user_association(b)*log(nb_users_per_BS(b));
        end
        
        log_expression_obj = sum(entr(nb_users_per_BS)+substract_term);
        
        objective = lin_expression_obj + log_expression_obj;
        maximize(objective)
        
        subject to
        sum(theta) <= 1;
        
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
        
        user_association(u,:) = theta;
        
        for b = 1:nb_BSs
            if user_association(u,b) <= 1e-4
                user_association(u,b) = 0;
            elseif user_association(u,b) >= 0.9999
                user_association(u,b) = 1;
            end
        end
    end
    association_convergence = norm(user_association - previous_user_association);
    if(association_convergence<1e-4)
        break
    end
end
end

