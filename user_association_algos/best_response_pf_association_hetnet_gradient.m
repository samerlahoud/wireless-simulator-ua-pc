function [user_association, nb_rounds] = best_response_pf_association_hetnet_gradient(peak_rate)

global netconfig;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;

% Overloading convergence params
gradient_step = 0.001;          %netconfig.gradient_step;
gradient_convergence_eps = 1e-6;%netconfig.gradient_convergence_eps;
global_convergence_eps = 1e-4;

user_association = 0.01.*ones(nb_users,nb_BSs);
nb_rounds = 0;
cumulative_nb_steps = zeros(1,nb_users);

while(1)
    previous_user_association = user_association;
    for u=1:nb_users
        nb_steps = 5000;
        % for delta = 0.1 reduce every 100 steps
        % for delta = 0.01 reduce every 500 steps
        
        for s=0:nb_steps
            % Divide delta if needed to speed up the convergence
            %     if mod(s,500)==0
            %      gradient_step=gradient_step/2;
            %     end
            
            previous_per_user_association = user_association(u,:);
            
            for b = 1:nb_BSs
                if peak_rate(u,b) < 1e-3
                    user_association(u,b) = 0;
                    continue;
                end
                if peak_rate(u,b) > 1e-3 && sum(user_association(:,b)) >= 1e-4
                    user_association(u,b) = user_association(u,b) + ...
                        gradient_step*(log(peak_rate(u,b)/sum(user_association(:,b))) ...
                        - (user_association(u,b)/sum(user_association(:,b))));
                end
                % Projection on positive orthant
                if user_association(u,b) <= 0
                    user_association(u,b) = 0;
                end
            end
            % Projection on simplex max allocation
            if (sum(user_association(u,:)) > 1)
                sorted_user_association  = sort(user_association(u,:),'descend');
                N_tilde = size(sorted_user_association,2);
                sorted_user_association(end+1) = -Inf;
                while(N_tilde > 0)
                    if ((sorted_user_association(N_tilde) > sorted_user_association(N_tilde+1)) && ...
                            (sorted_user_association(N_tilde) > (sum(sorted_user_association(1:N_tilde))-1)/N_tilde))
                        mu = (sum(sorted_user_association(1:N_tilde))-1)/N_tilde;
                        user_association(u,:) = max(user_association(u,:) - mu, 0);
                        break;
                    else
                        N_tilde = N_tilde - 1;
                    end
                end
            end
        
            % Convergence test
            user_association_convergence = norm(user_association(u,:) - previous_per_user_association);
            %user_association_convergence = sum(abs(user_association(u,:) - previous_per_user_association))
            if(user_association_convergence < gradient_convergence_eps)
                %disp('convergence');
                cumulative_nb_steps(nb_rounds+1,u) = s;
                break;
            end
            %cumulative_user_association = [cumulative_user_association;user_association];
        end
    end
    association_convergence = norm(user_association - previous_user_association)
    nb_rounds = nb_rounds + 1;
    if(association_convergence < global_convergence_eps)
        % round after convergence for NE test
        for u=1:nb_users
            for b=1:nb_BSs
                if user_association(u,b) >= 0.99
                    user_association(u,:) = zeros(1,nb_BSs);
                    user_association(u,b) = 1;
                end
            end
        end
        break
    end
end
%save('cumulative_nb_steps');
end

