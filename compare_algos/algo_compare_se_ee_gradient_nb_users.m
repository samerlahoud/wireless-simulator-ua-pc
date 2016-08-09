load_params;
global netconfig;
nb_sectors=netconfig.nb_sectors;
nb_users_per_sector=netconfig.nb_users_per_sector;
nb_RBs=netconfig.nb_RBs;
max_power_per_sector=netconfig.max_power_per_sector;
min_power_per_RB=netconfig.min_power_per_RB;

nb_users_range = [5:5:45];
nb_iterations = 10;

cum_ee_objective=zeros(nb_iterations,length(nb_users_range));
j=1;
for nb_users_iter = nb_users_range
    netconfig.nb_users_per_sector = nb_users_iter;
    for i = 1:nb_iterations
        [BS,user,pathloss_matrix]=generate_radio_conditions_v2;
        [ee_power_allocation_matrix,ee_sinr_matrix,~] = ...
            central_ee_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS);
        ee_objective=ee_objective_computation(ee_sinr_matrix, ee_power_allocation_matrix); 
        cum_ee_objective(i,j) = ee_objective
    end
    j=j+1;
end

save('/output/nb_users_evaluation.mat','cum_ee_objective');

% This includes results form 100 dist (normal interf) and 200 (high interf)
% load('./output/1sector-is-500-user-100/ee_variations_nb_users');
% f=figure;
% h=plot([5:5:25],mean(ee_norm_interf),'x-');
% set(h,'color','r')
% hold on;
% h=plot([5:5:25],mean(ee_high_interf),'o-');
% set(h,'color','b')
% xlabel('Number of users');
% ylabel('Energy efficiency');
% legend({'Normal interference', 'High interference'}, 'Location', 'NorthWest');
% print(f,'-depsc', sprintf('./output/central_ee_nb_users.eps'));
% savefig(sprintf('./output/central_ee_nb_users.fig'));
% matlab2tikz(sprintf('./output/central_ee_nb_users.tex'),'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '\figureheight', 'width','\figurewidth');

