function [RB_allocation, nb_rounds] = rb_allocation_reuse1_best_response_hetnet(BS_to_BS_pathloss, femto_demand)
% Reuse 1 is applied on macro-cells for separate spectrum
% BR algorithm determines RB allocation for femtos

global netconfig;
nb_BSs = netconfig.nb_BSs;
nb_RBs = netconfig.nb_RBs;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_femto_BSs = netconfig.nb_femto_BSs;
RB_bandwidth = netconfig.RB_bandwidth;
noise_density = netconfig.noise_density;
femto_tx_power = netconfig.femto_tx_power;
nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;
nb_femto_RBs = netconfig.nb_femto_RBs;
nb_macro_RBs = netconfig.nb_macro_RBs;
scaling_constant = 1e16; % Numerical instability in CVX was 1e15 with 42 femtos

femto_to_femto_pathloss = BS_to_BS_pathloss(nb_macro_BSs+1:nb_macro_femto_BSs,nb_macro_BSs+1:nb_macro_femto_BSs);

macro_RB_allocation = zeros(nb_macro_BSs, nb_macro_RBs);
femto_RB_allocation = zeros(nb_femto_BSs, nb_femto_RBs);
objective_vector = ones(nb_femto_BSs,1);

% Reuse 1 is applied on macro-cells for separate spectrum
for b = 1:nb_macro_BSs
    for k = 1:nb_macro_RBs
        macro_RB_allocation(b,k)=1;
    end
end

nb_rounds = 0;
allocation_convergence = 0;
objective_convergence = 0;

while(1)
    previous_objective_vector = objective_vector;
    previous_objective_convergence = objective_convergence;
    previous_allocation_convergence = allocation_convergence;
    previous_femto_RB_allocation = femto_RB_allocation;
    for j=1:nb_femto_BSs
        cvx_begin;
        cvx_quiet true;
        cvx_solver mosek;
        
        variable per_femto_RB_allocation(nb_femto_RBs) binary;
        expression objective
        
        for k=1:nb_femto_RBs
%             objective = objective + (per_femto_RB_allocation(k)) .* ...
%                 ((1./femto_to_femto_pathloss(j,:)) * femto_RB_allocation(:,k) - (1./femto_to_femto_pathloss(j,j)) * femto_RB_allocation(j,k) + ...
%                 (noise_density * RB_bandwidth)/(femto_tx_power/nb_femto_RBs));
            objective = objective + (per_femto_RB_allocation(k)) .* scaling_constant .* ...
                ((1./femto_to_femto_pathloss(j,:)) * femto_RB_allocation(:,k) - (1./femto_to_femto_pathloss(j,j)) * femto_RB_allocation(j,k) + ...
                (noise_density * RB_bandwidth)/(femto_tx_power/nb_femto_RBs));
        end
            
        minimize(objective);
        
        subject to
        sum(per_femto_RB_allocation) == femto_demand(j);
        cvx_end;
        femto_RB_allocation(j,:) = per_femto_RB_allocation;
        objective_vector(j) = objective;
    end
    allocation_convergence = sum(sum(abs(femto_RB_allocation - previous_femto_RB_allocation)));
    objective_convergence = sum(abs(((objective_vector-previous_objective_vector)>0)./(objective_vector)>0));
    
%     figure; 
%     data = femto_RB_allocation;
%     pcolor(data);
%     colormap(gray(2));
%     axis ij;
%     axis square;

    display(allocation_convergence);
    display(objective_convergence);
    nb_rounds = nb_rounds + 1;
    % This is very conservative, waiting to converge to the same allocation and a stable objective
    %if(previous_objective_convergence == objective_convergence) && (previous_allocation_convergence == allocation_convergence)
    if (nb_rounds > 30) || (objective_convergence == 0) || (previous_objective_convergence == objective_convergence) && (previous_allocation_convergence == allocation_convergence)
        break
    end
end
RB_allocation = [macro_RB_allocation,zeros(nb_macro_BSs,nb_femto_RBs);zeros(nb_femto_BSs,nb_macro_RBs),femto_RB_allocation];
end