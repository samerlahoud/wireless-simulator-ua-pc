function [BS, user, linear_pathloss_fading_matrix] = real_network_generation
global netconfig
netconfig.debug_level          = 1;         % Debug options  0=no output ?? 1=basic output ?? 2=extended output
%netconfig.nb_users_per_sector  = 8;
%netconfig.nb_sectors           = 9;
netconfig.nb_RBs               = 15;
netconfig.total_nb_users       = 72;
netconfig.min_power_per_RB     = 0.1;
netconfig.max_power_per_sector = 20; 
netconfig.power_prop_coeff     = 4.7;
netconfig.power_indep_coeff    = 130;
netconfig.noise_density        = 10^(-20.4);
netconfig.RB_bandwidth         = 180e3;    % Frequency in Hz

rng('shuffle');

nb_users=netconfig.total_nb_users;
area_type='urban';
nb_RBs_per_BS=netconfig.nb_RBs;      %/%/%/%/%/%/%/%/%/%/%/%/%/%/%/%/  Reuse 3 and banwidth = 5Mhz then 25 RB in total 
Tx_Antenna_Gain=15; % in dBi
Rx_Antenna_Gain=0; % dBi "LTE, the UMTS long term evolution: from theory to practice by Stefania Sesia, Issam Toufik, Matthew Baker pg 517 (22.4.1)"


%load('./orange_4G_35400_antenna_coordinates.mat')
load('antenna_positions.mat')
% BS_abs=[];
% BS_ord=[];
% [v,c] = voronoin([antenna_long(:) antenna_lat(:)]);
% for a=1:numel(antenna_long)
%     if isfinite(sum(v(c{a},1)+v(c{a},2)))
%         BS_abs=[BS_abs;antenna_long(a)];
%         BS_ord=[BS_ord;antenna_lat(a)];
%         vor_abs=v(c{a},1);
%         vor_ord=v(c{a},2);
%         vor_abs=[vor_abs;vor_abs(1)];
%         vor_ord=[vor_ord;vor_ord(1)];
%         plot(vor_abs,vor_ord);
%         hold on;
%     end
% end
nb_BSs=numel(antenna_long);
netconfig.nb_sectors           = nb_BSs;
netconfig.nb_users_per_sector  = zeros(1,nb_BSs);
BS_abs=antenna_long;
BS_ord=antenna_lat;
    
user_map_boundaries=[round(min(BS_abs))-100,round(max(BS_abs))+100; ...
                      round(min(BS_ord))-100,round(max(BS_ord))+100];
                      
user_abs=user_map_boundaries(1,1)+(user_map_boundaries(1,2)-user_map_boundaries(1,1))*rand(nb_users,1);
user_ord=user_map_boundaries(2,1)+(user_map_boundaries(2,2)-user_map_boundaries(2,1))*rand(nb_users,1);
% mean_abs=(user_map_boundaries(1,2)-user_map_boundaries(1,1))/2;
% std_abs=(user_map_boundaries(1,2)-user_map_boundaries(1,1))/4;
% mean_ord=(user_map_boundaries(2,2)-user_map_boundaries(2,1))/2;
% std_ord=(user_map_boundaries(2,2)-user_map_boundaries(2,1))/4;
% 
% user_abs=mean_abs+std_abs*randn(nb_users,1);
% user_ord=mean_ord+std_ord*randn(nb_users,1);

distance_matrix=zeros(nb_users,nb_BSs);
pathloss_matrix=zeros(nb_users,nb_BSs);
for u=1:nb_users
  for b=1:nb_BSs
      %%%Comment if MATLAB
      %distance_matrix(u,b)=distancePoints([user_abs(u) user_ord(u)],[BS_abs(b) BS_ord(b)]);
      distance_matrix(u,b)=pdist([[user_abs(u) user_ord(u)];[BS_abs(b) BS_ord(b)]],'euclidean');
      pathloss_matrix(u,b)=Cost231extendedHataPassLossModel(distance_matrix(u,b),area_type)-Tx_Antenna_Gain-Rx_Antenna_Gain;
  end
end

for b=1:nb_BSs 
    BS(b) = struct('attached_users',[]);
end

for u=1:nb_users
    [BS_distance,BS_idx]=min(distance_matrix(u,:));
    BS(BS_idx).attached_users=[BS(BS_idx).attached_users, u];
end

for b=1:nb_BSs 
    netconfig.nb_users_per_sector(b)=numel(BS(b).attached_users);
end

user=[];

RB_pathloss_matrix=zeros(nb_users,nb_BSs,nb_RBs_per_BS);
for r=1:nb_RBs_per_BS
    RB_pathloss_matrix(:,:,r) = pathloss_matrix .* (0.9 + (0.2).* rand(size(pathloss_matrix)));
end

linear_pathloss_fading_matrix = 1./(10.^(0.1.*RB_pathloss_matrix));

% %Fancy plotting
f=figure(1);
voronoi(BS_abs, BS_ord,'k');
hold on
plot(BS_abs,BS_ord,'b^','MarkerFaceColor','b');
plot(user_abs, user_ord, 'x');
for u=1:nb_users
    [BS_distance,BS_idx]=min(distance_matrix(u,:));
    plot([user_abs(u),BS_abs(BS_idx)],[user_ord(u),BS_ord(BS_idx)],'b:');
end
%print -deps -color test.eps
hold off