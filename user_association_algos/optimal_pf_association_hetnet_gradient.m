function [user_association] = optimal_pf_association_hetnet_gradient(peak_rate)

global netconfig;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;
gradient_step = netconfig.gradient_step;
gradient_convergence_eps = netconfig.gradient_convergence_eps;

% Initial value can be arbitrary
user_association = ones(nb_users,nb_BSs)*0.1;

% Cumulate power but this is not necessary
cumulative_user_association = user_association;

nb_steps = 5000;
% for delta = 0.1 reduce every 100 steps
% for delta = 0.01 reduce every 500 steps

for s=0:nb_steps
    % Divide delta if needed to speed up the convergence
%     if mod(s,500)==0
%      gradient_step=gradient_step/2;
%     end
    
    previous_user_association = user_association;
    
    for u = 1:nb_users
        for b = 1:nb_BSs
            if peak_rate(u,b) < 1e-3
                user_association(u,b) = 0;
                continue;
            end
            if peak_rate(u,b) > 1e-3 && sum(user_association(:,b)) >= 1e-4
                user_association(u,b) = user_association(u,b) + ...
                    gradient_step*(log(peak_rate(u,b)/sum(user_association(:,b)))-1);
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
    end
    % Convergence test
    association_convergence = norm(user_association - previous_user_association);
    if(association_convergence < gradient_convergence_eps)
        %disp('convergence');
        break;
    end
    cumulative_user_association = [cumulative_user_association;user_association];
end

%Plot association evolution
% hold on
% for u = [1,50, 150, 200, 250, 300]
%     for b = 1:nb_BSs
%         user_association_evolution=[];
%         for iteration_index=0:s-1
%             user_association_evolution = [user_association_evolution, ...
%                 cumulative_user_association(u+iteration_index*nb_users,b)];
%         end
%         plot([0:s-1],user_association_evolution)
%     end
% end
% hold off
    
