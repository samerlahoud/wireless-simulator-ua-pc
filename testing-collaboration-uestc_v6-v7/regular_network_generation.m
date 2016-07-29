function [BS, user, linear_pathloss_fading_matrix] = regular_network_generation
rng('shuffle');

global netconfig;
nb_users        =   netconfig.total_nb_users;
nb_RBs          =   netconfig.nb_RBs; 
inter_BS_dist   =   netconfig.inter_BS_dist;

area_type='urban';
Tx_Antenna_Gain=15; % in dBi
Rx_Antenna_Gain=0; % dBi "LTE, the UMTS long term evolution: from theory to practice by Stefania Sesia, Issam Toufik, Matthew Baker pg 517 (22.4.1)"

total_BS_abs=[inter_BS_dist,2*inter_BS_dist,inter_BS_dist/2,3*inter_BS_dist/2,5*inter_BS_dist/2,inter_BS_dist,2*inter_BS_dist, ...
    inter_BS_dist/2,3*inter_BS_dist/2,5*inter_BS_dist/2,0,3*inter_BS_dist,-inter_BS_dist/2,7*inter_BS_dist/2,0,3*inter_BS_dist,inter_BS_dist/2,3*inter_BS_dist/2,5*inter_BS_dist/2];
total_BS_ord=[inter_BS_dist,inter_BS_dist,2*inter_BS_dist,2*inter_BS_dist,2*inter_BS_dist,3*inter_BS_dist,3*inter_BS_dist,...
    0,0,0,inter_BS_dist,inter_BS_dist,2*inter_BS_dist,2*inter_BS_dist,3*inter_BS_dist,3*inter_BS_dist,4*inter_BS_dist,4*inter_BS_dist,4*inter_BS_dist];

studied_BS_idx=[1,2,3,4,5,6,7];

total_nb_BSs=numel(total_BS_abs);
studied_nb_BSs=numel(studied_BS_idx);
netconfig.nb_sectors           = studied_nb_BSs;
netconfig.nb_users_per_sector  = zeros(1,studied_nb_BSs);

vor_abs_matrix=zeros(studied_nb_BSs,7);
vor_ord_matrix=zeros(studied_nb_BSs,7);
[v,c] = voronoin([total_BS_abs(:) total_BS_ord(:)]);
for a=1:studied_nb_BSs
    if isfinite(sum(v(c{a},1)+v(c{a},2)))
        vor_abs=v(c{a},1);
        vor_ord=v(c{a},2);
        vor_abs_matrix(a,:)=[vor_abs;vor_abs(1)];
        vor_ord_matrix(a,:)=[vor_ord;vor_ord(1)];
        plot(vor_abs_matrix(a,:),vor_ord_matrix(a,:));
        hold on;
    end
end

inpolygon(500,1000,vor_abs_matrix(1,:),vor_ord_matrix(1,:))

user_map_boundaries=[round(min(total_BS_abs))-inter_BS_dist/2,round(max(total_BS_abs))+inter_BS_dist/2; ...
                      round(min(total_BS_ord))-inter_BS_dist/2,round(max(total_BS_ord))+inter_BS_dist/2];
                      
user_abs=user_map_boundaries(1,1)+(user_map_boundaries(1,2)-user_map_boundaries(1,1))*rand(nb_users,1);
user_ord=user_map_boundaries(2,1)+(user_map_boundaries(2,2)-user_map_boundaries(2,1))*rand(nb_users,1);
% mean_abs=(user_map_boundaries(1,2)-user_map_boundaries(1,1))/2;
% std_abs=(user_map_boundaries(1,2)-user_map_boundaries(1,1))/4;
% mean_ord=(user_map_boundaries(2,2)-user_map_boundaries(2,1))/2;
% std_ord=(user_map_boundaries(2,2)-user_map_boundaries(2,1))/4;
% 
% user_abs=mean_abs+std_abs*randn(nb_users,1);
% user_ord=mean_ord+std_ord*randn(nb_users,1);

distance_matrix=zeros(nb_users,total_nb_BSs);
pathloss_matrix=zeros(nb_users,studied_nb_BSs);
for u=1:nb_users
  for b=1:total_nb_BSs
      %%%Comment if MATLAB
      %distance_matrix(u,b)=distancePoints([user_abs(u) user_ord(u)],[BS_abs(b) BS_ord(b)]);
      distance_matrix(u,b)=pdist([[user_abs(u) user_ord(u)];[total_BS_abs(b) total_BS_ord(b)]],'euclidean');
      %pathloss_matrix(u,b)=Cost231extendedHataPassLossModel(distance_matrix(u,b),area_type)-Tx_Antenna_Gain-Rx_Antenna_Gain;
  end
end

for b=1:studied_nb_BSs 
    BS(b) = struct('attached_users',[]);
end

for u=1:nb_users
    [BS_distance,BS_idx]=min(distance_matrix(u,:));
    if(find(studied_BS_idx==BS_idx))
        BS(BS_idx).attached_users=[BS(BS_idx).attached_users, u];
    end
end

for b=1:studied_nb_BSs 
    netconfig.nb_users_per_sector(b)=numel(BS(b).attached_users);
end

user=[];

RB_pathloss_matrix=zeros(nb_users,studied_nb_BSs,nb_RBs);
for r=1:nb_RBs
    RB_pathloss_matrix(:,:,r) = pathloss_matrix .* (0.9 + (0.2).* rand(size(pathloss_matrix)));
end

linear_pathloss_fading_matrix = 1./(10.^(0.1.*RB_pathloss_matrix));

% %Fancy plotting
f=figure(2);
voronoi(total_BS_abs, total_BS_ord,'k');
hold on
plot(total_BS_abs(studied_BS_idx),total_BS_ord(studied_BS_idx),'r^','MarkerFaceColor','b');
for b=1:studied_nb_BSs
    for u=1:nb_users
        if(find(BS(b).attached_users==u))
            plot([user_abs(u),total_BS_abs(b)],[user_ord(u),total_BS_ord(b)],'b:');
            plot(user_abs(u), user_ord(u), 'x');
        end
    end
end
%print -deps -color test.eps
hold off