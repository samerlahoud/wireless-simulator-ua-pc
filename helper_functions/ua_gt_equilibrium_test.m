function [isNE] = ua_gt_equilibrium_test(peak_rate, user_association)

% Get global configuration parameters
global netconfig;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;

objective = zeros(1,nb_users);
isNE=true;

for u = 1:nb_users
    [user_rate, objective(u)] = ua_user_objective_computation(u, peak_rate, user_association);
end

for u=1:nb_users
    test_user_association = user_association;
    user_perturbation = user_association(u,:);
    [sorted_values,sorted_indexes]=sort(user_perturbation);
    
    % Maximum user association is not equal to one
    if sorted_values(end) >= 1-1e-4
        continue;
    else
        user_perturbation(sorted_indexes(end)) = user_perturbation(sorted_indexes(end))+ ...
            min(0.1,user_perturbation(sorted_indexes(end-1)));
        user_perturbation(sorted_indexes(end-1)) = user_perturbation(sorted_indexes(end-1))- ...
            min(0.1,user_perturbation(sorted_indexes(end-1)));
    end
    test_user_association(u,:) = user_perturbation;
    [user_rate, perturb_objective] = ua_user_objective_computation(u, peak_rate, test_user_association);
    if perturb_objective > objective(u)
        disp('not an equilibrium');
        u
        isNE=false;
        break;
    end
end

for u=1:nb_users
    test_user_association = user_association;
    user_perturbation = user_association(u,:);
    [sorted_values,sorted_indexes]=sort(user_perturbation);
    
    if sorted_values(end) >= 1-1e-4
        association_reduction = 0.1;
    else
        association_reduction = min(0.1,user_perturbation(sorted_indexes(end-1)));
    end
    user_perturbation(sorted_indexes(end)) = user_perturbation(sorted_indexes(end))- ...
        association_reduction;
    user_perturbation(sorted_indexes(end-1)) = user_perturbation(sorted_indexes(end-1))+ ...
        association_reduction;
    
    test_user_association(u,:) = user_perturbation;
    [user_rate, perturb_objective] = ua_user_objective_computation(u, peak_rate, test_user_association);
    if perturb_objective > objective(u)
        disp('not an equilibrium');
        u
        isNE=false;
        break;
    end
end

end

