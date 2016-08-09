% In this file, only plots for high and low interference cases are presented

global netconfig;
total_nb_users=netconfig.total_nb_users;
nb_sectors=netconfig.nb_sectors;
nb_users_per_sector=netconfig.nb_users_per_sector;
nb_RBs=netconfig.nb_RBs;
max_power_per_sector=netconfig.max_power_per_sector;
min_power_per_RB=netconfig.min_power_per_RB;

cum_maxlog_sinr_db_vector=[];
cum_maxlog_sinr_db_sorted_vector=[];
cum_ee_sinr_db_vector=[];
cum_ee_sinr_db_sorted_vector=[];
cum_pmin_sinr_db_vector=[];
cum_pmin_sinr_db_sorted_vector=[];
cum_pmax_sinr_db_vector=[];
cum_pmax_sinr_db_sorted_vector=[];
cum_ee_nointerf_sinr_db_vector=[];
cum_ee_nointerf_sinr_db_sorted_vector=[];
cum_gt_sinr_db_vector=[];
cum_gt_sinr_db_sorted_vector=[];

cum_maxlog_power_vector=[];
cum_maxlog_power_sorted_vector=[];
cum_ee_power_vector=[];
cum_ee_power_sorted_vector=[];
cum_pmin_power_vector=[];
cum_pmin_power_sorted_vector=[];
cum_pmax_power_vector=[];
cum_pmax_power_sorted_vector=[];
cum_ee_nointerf_power_vector=[];
cum_ee_nointerf_power_sorted_vector=[];
cum_gt_power_vector=[];
cum_gt_power_sorted_vector=[];

cum_maxlog_power_vector_per_user=[];
cum_ee_power_vector_per_user=[];
cum_pmin_power_vector_per_user=[];
cum_pmax_power_vector_per_user=[];
cum_ee_nointerf_power_vector_per_user=[];
cum_gt_power_vector_per_user=[];

cum_maxlog_objective=[];
cum_ee_objective=[];
cum_pmin_objective=[];
cum_pmax_objective=[];
cum_ee_nointerf_objective=[];
cum_gt_objective=[];

cum_maxlog_bs_objective=[];
cum_ee_bs_objective=[];
cum_pmin_bs_objective=[];
cum_pmax_bs_objective=[];
cum_ee_nointerf_bs_objective=[];
cum_gt_bs_objective=[];

cum_ee_steps=[];
cum_ee_rounds=[];
cum_ee_time=[];
cum_gt_steps=[];
cum_gt_rounds=[];
cum_gt_time=[];

cum_pathloss_db_vector=[];

% Load results
for i=1:netconfig.nb_iterations
    load(sprintf('./output/1sector-is-500-user-50/results-compare-se-ee-%dusers-%dsectors-%dRBs-%.1fW-%dW-%drun.mat', ...
        nb_users_per_sector,nb_sectors,nb_RBs,min_power_per_RB, max_power_per_sector,i));
    
    maxlog_objective=ee_objective_computation(maxlog_sinr_matrix, maxlog_power_allocation_matrix);
    ee_objective=ee_objective_computation(ee_sinr_matrix, ee_power_allocation_matrix);
    pmin_objective=ee_objective_computation(pmin_sinr_matrix, pmin_power_allocation_matrix);
    pmax_objective=ee_objective_computation(pmax_sinr_matrix, pmax_power_allocation_matrix);
    ee_nointerf_objective=ee_objective_computation(ee_nointerf_sinr_matrix, ee_nointerf_power_allocation_matrix);
    gt_objective=ee_objective_computation(gt_sinr_matrix, gt_power_allocation_matrix);
    
    maxlog_bs_objective=ee_bs_objective_computation(BS,maxlog_sinr_matrix, maxlog_power_allocation_matrix);
    ee_bs_objective=ee_bs_objective_computation(BS,ee_sinr_matrix, ee_power_allocation_matrix);
    pmin_bs_objective=ee_bs_objective_computation(BS,pmin_sinr_matrix, pmin_power_allocation_matrix);
    pmax_bs_objective=ee_bs_objective_computation(BS,pmax_sinr_matrix, pmax_power_allocation_matrix);
    ee_nointerf_bs_objective=ee_bs_objective_computation(BS,ee_nointerf_sinr_matrix, ee_nointerf_power_allocation_matrix);
    gt_bs_objective=ee_bs_objective_computation(BS,gt_sinr_matrix, gt_power_allocation_matrix);
    
    %%%
    % Result formatting
    % SINR vectors take the non zero elements in the SINR matrix.
    % Recall that zero elements in the SINR matrix result from the cell
    % selection problem: a user that is not attached to a sector has a null
    % SINR for all RBs in this sector (log is -Inf)
    maxlog_sinr_db_vector = 10*log10(reshape(maxlog_sinr_matrix,[],1));
    maxlog_sinr_db_vector = maxlog_sinr_db_vector(maxlog_sinr_db_vector>-Inf);
    maxlog_sinr_db_sorted_vector = sort(maxlog_sinr_db_vector(maxlog_sinr_db_vector>-Inf));
    ee_sinr_db_vector = 10*log10(reshape(ee_sinr_matrix,[],1));
    ee_sinr_db_vector = ee_sinr_db_vector(ee_sinr_db_vector>-Inf);
    ee_sinr_db_sorted_vector = sort(ee_sinr_db_vector(ee_sinr_db_vector>-Inf));
    gt_sinr_db_vector = 10*log10(reshape(gt_sinr_matrix,[],1));
    gt_sinr_db_vector = gt_sinr_db_vector(gt_sinr_db_vector>-Inf);
    gt_sinr_db_sorted_vector = sort(gt_sinr_db_vector(gt_sinr_db_vector>-Inf));
    
    pmin_sinr_db_vector = 10*log10(reshape(pmin_sinr_matrix,[],1));
    pmin_sinr_db_vector = pmin_sinr_db_vector(pmin_sinr_db_vector>-Inf);
    pmin_sinr_db_sorted_vector = sort(pmin_sinr_db_vector(pmin_sinr_db_vector>-Inf));
    pmax_sinr_db_vector = 10*log10(reshape(pmax_sinr_matrix,[],1));
    pmax_sinr_db_vector = pmax_sinr_db_vector(pmax_sinr_db_vector>-Inf);
    pmax_sinr_db_sorted_vector = sort(pmax_sinr_db_vector(pmax_sinr_db_vector>-Inf));
    ee_nointerf_sinr_db_vector = 10*log10(reshape(ee_nointerf_sinr_matrix,[],1));
    ee_nointerf_sinr_db_vector = ee_nointerf_sinr_db_vector(ee_nointerf_sinr_db_vector>-Inf);
    ee_nointerf_sinr_db_sorted_vector = sort(ee_nointerf_sinr_db_vector(ee_nointerf_sinr_db_vector>-Inf));
    
    % Power is divided by the max power per sector => no need for dividing for
    % readablity
    %maxlog_power_db_vector = 10*log10(reshape(maxlog_power_allocation_matrix, [], 1)./max_power_per_sector);
    %maxlog_power_db_sorted_vector = sort(maxlog_power_db_vector);
    %ee_power_db_vector = 10*log10(reshape(ee_power_allocation_matrix, [], 1)./max_power_per_sector);
    %ee_power_db_sorted_vector = sort(ee_power_db_vector);
    maxlog_power_vector = reshape(maxlog_power_allocation_matrix, [], 1);
    maxlog_power_sorted_vector = sort(maxlog_power_vector);
    ee_power_vector = reshape(ee_power_allocation_matrix, [], 1);
    ee_power_sorted_vector = sort(ee_power_vector);
    pmin_power_vector = reshape(pmin_power_allocation_matrix, [], 1);
    pmin_power_sorted_vector = sort(pmin_power_vector);
    pmax_power_vector = reshape(pmax_power_allocation_matrix, [], 1);
    pmax_power_sorted_vector = sort(pmax_power_vector);
    ee_nointerf_power_vector = reshape(ee_nointerf_power_allocation_matrix, [], 1);
    ee_nointerf_power_sorted_vector = sort(ee_nointerf_power_vector);
    gt_power_vector = reshape(gt_power_allocation_matrix, [], 1);
    gt_power_sorted_vector = sort(gt_power_vector);
    
    % Reproduce power allocation per user
    maxlog_power_allocation_matrix_per_user=zeros(total_nb_users,nb_sectors,nb_RBs);
    ee_power_allocation_matrix_per_user=zeros(total_nb_users,nb_sectors,nb_RBs);
    pmin_power_allocation_matrix_per_user=zeros(total_nb_users,nb_sectors,nb_RBs);
    pmax_power_allocation_matrix_per_user=zeros(total_nb_users,nb_sectors,nb_RBs);
    ee_nointerf_power_allocation_matrix_per_user=zeros(total_nb_users,nb_sectors,nb_RBs);
    gt_power_allocation_matrix_per_user=zeros(total_nb_users,nb_sectors,nb_RBs);
    for j=1:nb_sectors
        for i=BS(j).attached_users
            maxlog_power_allocation_matrix_per_user(i,j,:)=maxlog_power_allocation_matrix(j,:);
            ee_power_allocation_matrix_per_user(i,j,:)=ee_power_allocation_matrix(j,:);
            pmin_power_allocation_matrix_per_user(i,j,:)=pmin_power_allocation_matrix(j,:);
            pmax_power_allocation_matrix_per_user(i,j,:)=pmax_power_allocation_matrix(j,:);
            ee_nointerf_power_allocation_matrix_per_user(i,j,:)=ee_nointerf_power_allocation_matrix(j,:);
            gt_power_allocation_matrix_per_user(i,j,:)=gt_power_allocation_matrix(j,:);
        end
    end
    
    %maxlog_power_db_vector_per_user = 10*log10(reshape(maxlog_power_allocation_matrix_per_user, [], 1)./max_power_per_sector);
    %ee_power_db_vector_per_user = 10*log10(reshape(ee_power_allocation_matrix_per_user, [], 1)./max_power_per_sector);
    maxlog_power_vector_per_user = reshape(maxlog_power_allocation_matrix_per_user, [], 1);
    maxlog_power_vector_per_user = maxlog_power_vector_per_user(maxlog_power_vector_per_user>0);
    ee_power_vector_per_user = reshape(ee_power_allocation_matrix_per_user, [], 1);
    ee_power_vector_per_user = ee_power_vector_per_user(ee_power_vector_per_user>0);
    pmin_power_vector_per_user = reshape(pmin_power_allocation_matrix_per_user, [], 1);
    pmin_power_vector_per_user = pmin_power_vector_per_user(pmin_power_vector_per_user>0);
    pmax_power_vector_per_user = reshape(pmax_power_allocation_matrix_per_user, [], 1);
    pmax_power_vector_per_user = pmax_power_vector_per_user(pmax_power_vector_per_user>0);
    ee_nointerf_power_vector_per_user = reshape(ee_nointerf_power_allocation_matrix_per_user, [], 1);
    ee_nointerf_power_vector_per_user = ee_nointerf_power_vector_per_user(ee_nointerf_power_vector_per_user>0);
    gt_power_vector_per_user = reshape(gt_power_allocation_matrix_per_user, [], 1);
    gt_power_vector_per_user = gt_power_vector_per_user(gt_power_vector_per_user>0);
    
    pathloss_db_vector = 10*log10(reshape(pathloss_matrix,[], 1));
    %%%  
    
    cum_maxlog_objective=[cum_maxlog_objective; maxlog_objective];
    cum_ee_objective=[cum_ee_objective; ee_objective];
    cum_pmin_objective=[cum_pmin_objective; pmin_objective];
    cum_pmax_objective=[cum_pmax_objective; pmax_objective];
    cum_ee_nointerf_objective=[cum_ee_nointerf_objective; ee_nointerf_objective];
    cum_gt_objective=[cum_gt_objective; gt_objective];
    
    cum_maxlog_bs_objective=[cum_maxlog_bs_objective; maxlog_bs_objective];
    cum_ee_bs_objective=[cum_ee_bs_objective; ee_bs_objective];
    cum_pmin_bs_objective=[cum_pmin_bs_objective; pmin_bs_objective];
    cum_pmax_bs_objective=[cum_pmax_bs_objective; pmax_bs_objective];
    cum_ee_nointerf_bs_objective=[cum_ee_nointerf_bs_objective; ee_nointerf_bs_objective];
    cum_gt_bs_objective=[cum_gt_bs_objective; gt_bs_objective];
    
    cum_maxlog_sinr_db_vector=[cum_maxlog_sinr_db_vector; maxlog_sinr_db_vector];
    cum_maxlog_sinr_db_sorted_vector=[cum_maxlog_sinr_db_sorted_vector; maxlog_sinr_db_sorted_vector];
    cum_ee_sinr_db_vector=[cum_ee_sinr_db_vector; ee_sinr_db_vector];
    cum_ee_sinr_db_sorted_vector=[cum_ee_sinr_db_sorted_vector; ee_sinr_db_sorted_vector];
    cum_pmin_sinr_db_vector=[cum_pmin_sinr_db_vector; pmin_sinr_db_vector];
    cum_pmin_sinr_db_sorted_vector=[cum_pmin_sinr_db_sorted_vector; pmin_sinr_db_sorted_vector];
    cum_pmax_sinr_db_vector=[cum_pmax_sinr_db_vector; pmax_sinr_db_vector];
    cum_pmax_sinr_db_sorted_vector=[cum_pmax_sinr_db_sorted_vector; pmax_sinr_db_sorted_vector];
    cum_ee_nointerf_sinr_db_vector=[cum_ee_nointerf_sinr_db_vector; ee_nointerf_sinr_db_vector];
    cum_ee_nointerf_sinr_db_sorted_vector=[cum_ee_nointerf_sinr_db_sorted_vector; ee_nointerf_sinr_db_sorted_vector];
    cum_gt_sinr_db_vector=[cum_gt_sinr_db_vector; gt_sinr_db_vector];
    cum_gt_sinr_db_sorted_vector=[cum_gt_sinr_db_sorted_vector; gt_sinr_db_sorted_vector];
    
    cum_maxlog_power_vector=[cum_maxlog_power_vector; maxlog_power_vector];
    cum_maxlog_power_sorted_vector=[cum_maxlog_power_sorted_vector; maxlog_power_sorted_vector];
    cum_ee_power_vector=[cum_ee_power_vector; ee_power_vector];
    cum_ee_power_sorted_vector=[cum_ee_power_sorted_vector; ee_power_sorted_vector];
    cum_pmin_power_vector=[cum_pmin_power_vector; pmin_power_vector];
    cum_pmin_power_sorted_vector=[cum_pmin_power_sorted_vector; pmin_power_sorted_vector];
    cum_pmax_power_vector=[cum_pmax_power_vector; pmax_power_vector];
    cum_pmax_power_sorted_vector=[cum_pmax_power_sorted_vector; pmax_power_sorted_vector];
    cum_ee_nointerf_power_vector=[cum_ee_nointerf_power_vector; ee_nointerf_power_vector];
    cum_ee_nointerf_power_sorted_vector=[cum_ee_nointerf_power_sorted_vector; ee_nointerf_power_sorted_vector];
    cum_gt_power_vector=[cum_gt_power_vector; gt_power_vector];
    cum_gt_power_sorted_vector=[cum_gt_power_sorted_vector; gt_power_sorted_vector];
    
    cum_maxlog_power_vector_per_user=[cum_maxlog_power_vector_per_user; maxlog_power_vector_per_user];
    cum_ee_power_vector_per_user=[cum_ee_power_vector_per_user; ee_power_vector_per_user];
    cum_pmin_power_vector_per_user=[cum_pmin_power_vector_per_user; pmin_power_vector_per_user];
    cum_pmax_power_vector_per_user=[cum_pmax_power_vector_per_user; pmax_power_vector_per_user];
    cum_ee_nointerf_power_vector_per_user=[cum_ee_nointerf_power_vector_per_user; ee_nointerf_power_vector_per_user];
    cum_gt_power_vector_per_user=[cum_gt_power_vector_per_user; gt_power_vector_per_user];
    
%     cum_ee_steps=[cum_ee_steps; ee_time_structure.steps];
%     cum_ee_rounds=[cum_ee_rounds; ee_time_structure.rounds];
%     cum_ee_time=[cum_ee_time; ee_time_structure.time];
%     cum_gt_steps=[cum_gt_steps; gt_time_structure.steps];
%     cum_gt_rounds=[cum_gt_rounds; gt_time_structure.rounds];
%     cum_gt_time=[cum_gt_time; gt_time_structure.time];
%     
    cum_pathloss_db_vector=[cum_pathloss_db_vector; pathloss_db_vector];
end

% Plot results
figure_file_name = sprintf('-%dusers-%dsectors-%dRBs-%dW-high',netconfig.nb_users_per_sector,...
    netconfig.nb_sectors,netconfig.nb_RBs,netconfig.max_power_per_sector);

f=figure;
boxplot([cum_ee_objective, cum_gt_objective],...
    'notch', 'off', 'Label', {'Central-EE', 'Distributed-EE'});
set(gca,'xtick',1:2, 'xticklabel',{'Central-EE', 'Distributed-EE'})
ylabel('Energy Efficiency');
%cleanfigure;
print(f,'-depsc', sprintf('./output/central-dist-boxplot-objective%s.eps', figure_file_name));
savefig(sprintf('./output/central-dist-boxplot-objective%s.fig', figure_file_name));
matlab2tikz(sprintf('./output/central-dist-boxplot-objective%s.tex', figure_file_name),'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');

f=figure;
boxplot([cum_ee_objective, cum_gt_objective, cum_maxlog_objective, cum_pmax_objective, cum_ee_nointerf_objective],...
    'notch', 'off');
set(gca,'xtick',1:5, 'xticklabel',{'Central-EE', 'Distributed-EE', 'Central-SE', 'Max-Power',  'EE-NoInterference'})
ylabel('Energy Efficiency');
%cleanfigure;
print(f,'-depsc', sprintf('./output/heur-nomin-boxplot-objective%s.eps', figure_file_name));
savefig(sprintf('./output/heur-nomin-boxplot-objective%s.fig', figure_file_name));
matlab2tikz(sprintf('./output/heur-nomin-boxplot-objective%s.tex', figure_file_name),'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');
    
f=figure;
boxplot([cum_ee_power_vector_per_user cum_gt_power_vector_per_user cum_maxlog_power_vector_per_user ...
    cum_pmax_power_vector_per_user cum_ee_nointerf_power_vector_per_user], 'notch', 'off');
set(gca,'xtick',1:5, 'xticklabel',{'Central-EE', 'Distributed-EE', 'Central-SE', 'Max-Power',  'EE-NoInterference'})
ylabel('Power (W)');
%cleanfigure;
print(f,'-depsc', sprintf('./output/heur-boxplot-power%s.eps', figure_file_name));
savefig(sprintf('./output/heur-boxplot-power%s.fig', figure_file_name));
matlab2tikz(sprintf('./output/heur-boxplot-power%s.tex', figure_file_name),'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');

f=figure;
boxplot([cum_ee_power_vector_per_user cum_gt_power_vector_per_user], 'notch', 'off', ...
    'Label', {'Central-EE', 'Distributed-EE'});
set(gca,'xtick',1:2, 'xticklabel',{'Central-EE', 'Distributed-EE'})
ylabel('Power (W)');
%cleanfigure;
print(f,'-depsc', sprintf('./output/central-dist-boxplot-power%s.eps', figure_file_name));
savefig(sprintf('./output/central-dist-boxplot-power%s.fig', figure_file_name));
matlab2tikz(sprintf('./output/central-dist-boxplot-power%s.tex', figure_file_name),'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');