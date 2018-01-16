function [femto_demand] = ua_demand_computation(rx_power, BS_to_BS_pathloss, reuse_min_pathloss)

% If pathloss is higher than reuse_pathloss (130dB for ex), 
%femtos are considered sufficiently far to reuse the spectrum

% Get global configuration parameters
global netconfig;
nb_users = netconfig.nb_users;
nb_RBs = netconfig.nb_RBs;
nb_BSs = netconfig.nb_BSs;
nb_femto_BSs = netconfig.nb_femto_BSs;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_mmwave_BSs = netconfig.nb_mmwave_BSs;
nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;


femto_demand = zeros(nb_femto_BSs,1);
femto_to_femto_pathloss = BS_to_BS_pathloss(nb_macro_BSs+1:nb_macro_femto_BSs,...
    nb_macro_BSs+1:nb_macro_femto_BSs);

% %%
% % Define BS transmit power per RB
% % Beware that there is no RB in mmwave
% tx_RB_power = [macro_tx_power*ones(1,nb_macro_BSs)./nb_RBs, ...
%             femto_tx_power*ones(1,nb_femto_BSs)./nb_RBs, ...
%             mmwave_tx_power*ones(1,nb_mmwave_BSs)];
% 
% % Received power and SINR matrices
% rx_RB_power = zeros(nb_users,nb_BSs);
% 
% % Check for penetration loss
% for u = 1:nb_users
%     for b = 1:nb_macro_femto_BSs
%         rx_RB_power(u,b) = (tx_RB_power(b)*tx_antenna_gain*rx_antenna_gain)/pathloss(u,b);
%     end
%     for b = nb_macro_femto_BSs+1:nb_BSs
%         rx_RB_power(u,b) = (tx_RB_power(b)*mmwave_tx_antenna_gain*mmwave_rx_antenna_gain)/pathloss(u,b);
%     end
% end
% %%

user_association = zeros(nb_users,nb_BSs);
for u = 1:nb_users
    [~,BS_idx] = max(rx_power(u,:));
    user_association(u,BS_idx) = 1;
end

total_nb_macro_users = sum(sum(user_association(:,1:nb_macro_BSs)));
total_nb_femto_users = sum(sum(user_association(:,nb_macro_BSs+1:nb_macro_femto_BSs)));
%total_nb_mmwave_users = sum(user_association(:,nb_macro_femto_BSs+1:nb_BSs));

nb_femto_RBs = ceil(nb_RBs*(total_nb_femto_users/(total_nb_macro_users+total_nb_femto_users)));
nb_macro_RBs = nb_RBs - nb_femto_RBs;

netconfig.nb_macro_RBs = nb_macro_RBs;
netconfig.nb_femto_RBs = nb_femto_RBs;

% user_femto_association = zeros(nb_users,nb_femto_BSs);
% for u = 1:nb_users
%     [~,femto_idx] = min(user_femto_rx_power(u,:));
%     user_femto_association(u,femto_idx) = 1;
% end

nb_users_per_femto = sum(user_association(:,nb_macro_BSs+1:nb_macro_femto_BSs))';
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