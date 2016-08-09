load('./output/1sector-is-500-user-100/10users/central_ee_maxlog_power_iteration.mat');
global netconfig;
total_nb_users=netconfig.total_nb_users;
nb_sectors=netconfig.nb_sectors;
nb_users_per_sector=netconfig.nb_users_per_sector;
nb_RBs=netconfig.nb_RBs;
max_power_per_sector=netconfig.max_power_per_sector;
min_power_per_RB=netconfig.min_power_per_RB;
f=figure;
hold on
for sector_index=1:nb_sectors
    for RB_index=1:nb_RBs
        RB_power_evolution=[];
        for iteration_index=0:sum(cum_nb_steps)
            RB_power_evolution = [RB_power_evolution, ...
                cumulative_power_allocation_matrix(sector_index+iteration_index*nb_sectors,RB_index)];
        end
        plot([0:sum(cum_nb_steps)],RB_power_evolution)
    end
end
hold off
cum_nb_steps=cumsum(cum_nb_steps);
gridxy(cum_nb_steps(1:end-1), 'Linestyle',':')
xlabel('Subgradient iterations');
ylabel('Power (W)');
print(f,'-depsc', sprintf('./output/ee_power_iteration.eps'));
savefig(sprintf('./output/ee_power_iteration.fig'));
matlab2tikz(sprintf('./output/ee_power_iteration.tex'),'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');

load('./output/1sector-is-500-user-100/10users/distributed_gt_ee_maxlog_power_iteration.mat');
[plot_round,x]=size(cumulative_power_allocation_matrix);
plot_round = plot_round/nb_sectors;
f=figure;
hold on
for sector_index=1:nb_sectors
    for RB_index=1:nb_RBs
        RB_power_evolution=[];
        for iteration_index=0:plot_round-1
            RB_power_evolution = [RB_power_evolution, ...
                cumulative_power_allocation_matrix(sector_index+iteration_index*nb_sectors,RB_index)];
        end
        plot([0:plot_round-1],RB_power_evolution)
    end
end
hold off
gridxy([nb_sectors:nb_sectors:plot_round], 'Linestyle',':')
xlabel('Best Response rounds');
ylabel('Power (W)');
print(f,'-depsc', sprintf('./output/gt_power_iteration.eps'));
savefig(sprintf('./output/gt_power_iteration.fig'));
matlab2tikz(sprintf('./output/gt_power_iteration.tex'),'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');

%% Starting script
%load_params
%[BS,user,pathloss_matrix]=generate_radio_conditions_v2;
%[power_allocation_matrix, sinr_matrix, time_structure] = distributed_gt_ee_maxlog_sinr_power_allocation_gradient(pathloss_matrix, BS)
%%

f=figure;
hold on
for sector_index=1:nb_sectors
    objective_evolution=[];
    for iteration_index=0:plot_round-1
        sinr_matrix = sinr_computation(pathloss_matrix, BS, ...
            cumulative_power_allocation_matrix(1+iteration_index*nb_sectors:(iteration_index+1)*nb_sectors,:));
        objective = ee_bs_objective_computation(BS, sinr_matrix, power_allocation_matrix);
        objective_evolution = [objective_evolution,objective(sector_index)];
    end
    plot([0:plot_round-1],objective_evolution);
end
hold off
gridxy([nb_sectors:nb_sectors:plot_round], 'Linestyle',':')
xlabel('Best Response rounds');
ylabel('Energy efficiency');
print(f,'-depsc', sprintf('./output/gt_objective_iteration.eps'));
savefig(sprintf('./output/gt_objective_iteration.fig'));
matlab2tikz(sprintf('./output/gt_objective_iteration.tex'),'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');

         