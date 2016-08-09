function ee_gee_plot_results_algo_compare
% Plots for general case
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
cum_gee_sinr_db_vector=[];
cum_gee_sinr_db_sorted_vector=[];
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
cum_gee_power_vector=[];
cum_gee_power_sorted_vector=[];
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
cum_gee_power_vector_per_user=[];
cum_pmin_power_vector_per_user=[];
cum_pmax_power_vector_per_user=[];
cum_ee_nointerf_power_vector_per_user=[];
cum_gt_power_vector_per_user=[];

cum_maxlog_objective=[];
cum_ee_objective=[];
cum_gee_objective=[];
cum_pmin_objective=[];
cum_pmax_objective=[];
cum_ee_nointerf_objective=[];
cum_gt_objective=[];

cum_maxlog_spectral_eff=[];
cum_ee_spectral_eff=[];
cum_gee_spectral_eff=[];
cum_pmin_spectral_eff=[];
cum_pmax_spectral_eff=[];
cum_ee_nointerf_spectral_eff=[];
cum_gt_spectral_eff=[];

cum_maxlog_bs_objective=[];
cum_ee_bs_objective=[];
cum_gee_bs_objective=[];
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
    load(sprintf('./output/1sector-is-500-user-100/10users/results-compare-se-ee-%dusers-%dsectors-%dRBs-%.1fW-%dW-%drun.mat', ...
        nb_users_per_sector,nb_sectors,nb_RBs,min_power_per_RB, max_power_per_sector,i));
    load(sprintf('./output/1sector-is-500-user-100/10users-gee-maxsnr/results-compare-gee-ee-%dusers-%dsectors-%dRBs-%.1fW-%dW-%drun.mat', ...
        nb_users_per_sector,nb_sectors,nb_RBs,min_power_per_RB, max_power_per_sector,i));
    
    maxlog_objective=ee_objective_computation(maxlog_sinr_matrix, maxlog_power_allocation_matrix);
    ee_objective=ee_objective_computation(ee_sinr_matrix, ee_power_allocation_matrix);
    gee_objective=gee_objective_computation(gee_sinr_matrix, gee_power_allocation_matrix);
    pmin_objective=ee_objective_computation(pmin_sinr_matrix, pmin_power_allocation_matrix);
    pmax_objective=ee_objective_computation(pmax_sinr_matrix, pmax_power_allocation_matrix);
    ee_nointerf_objective=ee_objective_computation(ee_nointerf_sinr_matrix, ee_nointerf_power_allocation_matrix);
    gt_objective=ee_objective_computation(gt_sinr_matrix, gt_power_allocation_matrix);
    
    maxlog_spectral_eff=se_objective_computation(maxlog_sinr_matrix);
    ee_spectral_eff=se_objective_computation(ee_sinr_matrix);
    gee_spectral_eff=sum(sum(sum(log(gee_sinr_matrix(gee_sinr_matrix>0)))));
    pmin_spectral_eff=se_objective_computation(pmin_sinr_matrix);
    pmax_spectral_eff=se_objective_computation(pmax_sinr_matrix);
    ee_nointerf_spectral_eff=se_objective_computation(ee_nointerf_sinr_matrix);
    gt_spectral_eff=se_objective_computation(gt_sinr_matrix);
    
%     maxlog_bs_objective=ee_bs_objective_computation(BS,maxlog_sinr_matrix, maxlog_power_allocation_matrix);
%     ee_bs_objective=ee_bs_objective_computation(BS,ee_sinr_matrix, ee_power_allocation_matrix);
%     pmin_bs_objective=ee_bs_objective_computation(BS,pmin_sinr_matrix, pmin_power_allocation_matrix);
%     pmax_bs_objective=ee_bs_objective_computation(BS,pmax_sinr_matrix, pmax_power_allocation_matrix);
%     ee_nointerf_bs_objective=ee_bs_objective_computation(BS,ee_nointerf_sinr_matrix, ee_nointerf_power_allocation_matrix);
%     gt_bs_objective=ee_bs_objective_computation(BS,gt_sinr_matrix, gt_power_allocation_matrix);
    
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
    gee_sinr_db_vector = 10*log10(reshape(gee_sinr_matrix,[],1));
    gee_sinr_db_vector = gee_sinr_db_vector(gee_sinr_db_vector>-Inf);
    gee_sinr_db_sorted_vector = sort(gee_sinr_db_vector(gee_sinr_db_vector>-Inf));
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
    gee_power_vector = reshape(gee_power_allocation_matrix, [], 1);
    gee_power_sorted_vector = sort(gee_power_vector);
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
    cum_gee_objective=[cum_gee_objective; gee_objective];
    cum_pmin_objective=[cum_pmin_objective; pmin_objective];
    cum_pmax_objective=[cum_pmax_objective; pmax_objective];
    cum_ee_nointerf_objective=[cum_ee_nointerf_objective; ee_nointerf_objective];
    cum_gt_objective=[cum_gt_objective; gt_objective];
    
    cum_maxlog_spectral_eff=[cum_maxlog_spectral_eff; maxlog_spectral_eff];
    cum_ee_spectral_eff=[cum_ee_spectral_eff; ee_spectral_eff];
    cum_gee_spectral_eff=[cum_gee_spectral_eff; gee_spectral_eff];
    cum_pmin_spectral_eff=[cum_pmin_spectral_eff; pmin_spectral_eff];
    cum_pmax_spectral_eff=[cum_pmax_spectral_eff; pmax_spectral_eff];
    cum_ee_nointerf_spectral_eff=[cum_ee_nointerf_spectral_eff; ee_nointerf_spectral_eff];
    cum_gt_spectral_eff=[cum_gt_spectral_eff; gt_spectral_eff];
%     
%     cum_maxlog_bs_objective=[cum_maxlog_bs_objective; maxlog_bs_objective];
%     cum_ee_bs_objective=[cum_ee_bs_objective; ee_bs_objective];
%     cum_pmin_bs_objective=[cum_pmin_bs_objective; pmin_bs_objective];
%     cum_pmax_bs_objective=[cum_pmax_bs_objective; pmax_bs_objective];
%     cum_ee_nointerf_bs_objective=[cum_ee_nointerf_bs_objective; ee_nointerf_bs_objective];
%     cum_gt_bs_objective=[cum_gt_bs_objective; gt_bs_objective];
    
    cum_maxlog_sinr_db_vector=[cum_maxlog_sinr_db_vector; maxlog_sinr_db_vector];
    cum_maxlog_sinr_db_sorted_vector=[cum_maxlog_sinr_db_sorted_vector; maxlog_sinr_db_sorted_vector];
    cum_ee_sinr_db_vector=[cum_ee_sinr_db_vector; ee_sinr_db_vector];
    cum_ee_sinr_db_sorted_vector=[cum_ee_sinr_db_sorted_vector; ee_sinr_db_sorted_vector];
    cum_gee_sinr_db_vector=[cum_gee_sinr_db_vector; gee_sinr_db_vector];
    cum_gee_sinr_db_sorted_vector=[cum_gee_sinr_db_sorted_vector; gee_sinr_db_sorted_vector];
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
    cum_gee_power_vector=[cum_gee_power_vector; gee_power_vector];
    cum_gee_power_sorted_vector=[cum_gee_power_sorted_vector; gee_power_sorted_vector];
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
%     
%     cum_ee_steps=[cum_ee_steps; ee_time_structure.steps];
%     cum_ee_rounds=[cum_ee_rounds; ee_time_structure.rounds];
%     cum_ee_time=[cum_ee_time; ee_time_structure.time];
%     cum_gt_steps=[cum_gt_steps; gt_time_structure.steps];
%     cum_gt_rounds=[cum_gt_rounds; gt_time_structure.rounds];
%     cum_gt_time=[cum_gt_time; gt_time_structure.time];
    
    cum_pathloss_db_vector=[cum_pathloss_db_vector; pathloss_db_vector];
end

% Plot results
figure_file_name = sprintf('-%dusers-%dsectors-%dRBs-%dW',netconfig.nb_users_per_sector,...
    netconfig.nb_sectors,netconfig.nb_RBs,netconfig.max_power_per_sector);

% f=figure;
% boxplot([cum_ee_objective, cum_gt_objective],...
%     'notch', 'off', 'Label', {'Central-EE', 'Distributed-EE'});
% set(gca,'xtick',1:2, 'xticklabel',{'Central-EE', 'Distributed-EE'})
% ylabel('Energy Efficiency');
% cleanfigure;
% print(f,'-depsc', sprintf('./output/central-dist-boxplot-objective%s.eps', figure_file_name));
% savefig(sprintf('./output/central-dist-boxplot-objective%s.fig', figure_file_name));
% matlab2tikz(sprintf('./output/central-dist-boxplot-objective%s.tex', figure_file_name),'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '\figureheight', 'width','\figurewidth');
    
% f=figure;
% boxplot([cum_ee_objective, cum_gt_objective, cum_maxlog_objective, cum_pmin_objective, cum_pmax_objective, cum_ee_nointerf_objective],...
%     'notch', 'off', 'Label', {'Central-EE', 'Distributed-EE', 'Central-SE', 'Min-Power', 'Max-Power',  'NoInterference-EE'});
% ylabel('Energy Efficiency');
% print(f,'-depsc', sprintf('./output/heur-boxplot-objective%s.eps', figure_file_name));
% savefig(sprintf('./output/heur-boxplot-objective%s.fig', figure_file_name));

f=figure;
boxplot([cum_ee_objective, cum_gt_objective, cum_gee_objective, cum_maxlog_objective, cum_pmax_objective, cum_ee_nointerf_objective],...
    'notch', 'off');
set(gca,'xtick',1:6, 'xticklabel',{'Central-EE', 'Distributed-EE', 'Iterative-EE', 'Central-SE', 'Max-Power', 'NoInterference-EE'})
ylabel('Energy Efficiency');
cleanfigure;
print(f,'-depsc', sprintf('./output/heur-boxplot-objective%s.eps', figure_file_name));
savefig(sprintf('./output/heur-boxplot-objective%s.fig', figure_file_name));
matlab2tikz(sprintf('./output/heur-boxplot-objective%s.tex', figure_file_name),'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');

f=figure;
boxplot([cum_ee_spectral_eff, cum_gt_spectral_eff, cum_gee_spectral_eff, cum_maxlog_spectral_eff, cum_pmax_spectral_eff, ...
    cum_ee_nointerf_spectral_eff],'notch', 'off');
set(gca,'xtick',1:6, 'xticklabel',{'Central-EE', 'Distributed-EE', 'Iterative-EE', 'Central-SE', 'Max-Power', 'NoInterference-EE'})
ylabel('Spectral Efficiency');
cleanfigure;
print(f,'-depsc', sprintf('./output/heur-boxplot-spectral_eff%s.eps', figure_file_name));
savefig(sprintf('./output/heur-boxplot-spectral_eff%s.fig', figure_file_name));
matlab2tikz(sprintf('./output/heur-boxplot-spectral_eff%s.tex', figure_file_name),'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');
    
% f=figure;
% boxplot([cum_ee_objective, cum_gt_objective, cum_maxlog_objective, cum_pmax_objective, cum_ee_nointerf_objective],...
%     'notch', 'off');
% set(gca,'xtick',1:5, 'xticklabel',{'Central-EE', 'Distributed-EE', 'Central-SE', 'Max-Power',  'NoInterference-EE'})
% ylabel('Energy Efficiency');
% cleanfigure;
% print(f,'-depsc', sprintf('./output/heur-nomin-boxplot-objective%s.eps', figure_file_name));
% savefig(sprintf('./output/heur-nomin-boxplot-objective%s.fig', figure_file_name));
% matlab2tikz(sprintf('./output/heur-nomin-boxplot-objective%s.tex', figure_file_name),'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '\figureheight', 'width','\figurewidth');

% sinr_db_min=min([cum_maxlog_sinr_db_sorted_vector' cum_ee_sinr_db_sorted_vector' cum_gee_sinr_db_sorted_vector' cum_pmin_sinr_db_sorted_vector' ...
%     cum_pmax_sinr_db_sorted_vector' cum_ee_nointerf_sinr_db_sorted_vector' cum_gt_sinr_db_sorted_vector']);
% sinr_db_max=max([cum_maxlog_sinr_db_sorted_vector' cum_ee_sinr_db_sorted_vector' cum_gee_sinr_db_sorted_vector' cum_pmin_sinr_db_sorted_vector' ...
%     cum_pmax_sinr_db_sorted_vector' cum_ee_nointerf_sinr_db_sorted_vector' cum_gt_sinr_db_sorted_vector']);
% binranges = sinr_db_min - mod(sinr_db_min,10):10:sinr_db_max + mod(-sinr_db_max,10);
% [bincounts] = histc([cum_ee_sinr_db_sorted_vector, cum_gt_sinr_db_sorted_vector, cum_gee_sinr_db_sorted_vector, cum_maxlog_sinr_db_sorted_vector, ...
%     cum_pmin_sinr_db_sorted_vector, cum_pmax_sinr_db_sorted_vector, cum_ee_nointerf_sinr_db_sorted_vector],binranges);
% % All bins are equal size
% total_bins=sum(bincounts);
% 
% f=figure;
% %hist([maxlog_sinr_db_vector, maxmin_sinr_db_vector, distributed_gt_maxlog_sinr_db_vector]);
% bar(binranges,bincounts./total_bins(1)*100,'histc')
% h = findobj(gca, 'Type','patch');
% % set(h(6), 'FaceColor','r')
% % set(h(5), 'FaceColor','g')
% % set(h(4), 'FaceColor','b', 'EdgeColor','k')
% % set(h(3), 'FaceColor','g', 'EdgeColor','k')
% % set(h(2), 'FaceColor','y', 'EdgeColor','k')
% % set(h(1), 'FaceColor','m', 'EdgeColor','k')
% legend({'Central-EE', 'Distributed-EE', 'GEE', 'Central-SE', 'Min-Power', 'Max-Power',  'NoInterference-EE'}, 'Location', 'NorthWest');
% %title('SINR distribution');
% ylabel('Percentage of occurrence');
% xlabel('SINR (dB)');
% print(f,'-depsc', sprintf('./output/heur-sinr-hist%s.eps', figure_file_name));
% savefig(sprintf('./output/heur-sinr-hist%s.fig', figure_file_name));

% sinr_db_min=min([cum_ee_sinr_db_sorted_vector' cum_gt_sinr_db_sorted_vector']);
% sinr_db_max=max([cum_ee_sinr_db_sorted_vector' cum_gt_sinr_db_sorted_vector']);
% binranges = sinr_db_min - mod(sinr_db_min,10):10:sinr_db_max + mod(-sinr_db_max,10);
% [bincounts] = histc([cum_ee_sinr_db_sorted_vector, cum_gt_sinr_db_sorted_vector],binranges);
% % All bins are equal size
% total_bins=sum(bincounts);
% 
% f=figure;
% bar(binranges,bincounts./total_bins(1)*100,'histc')
% h = findobj(gca, 'Type','patch');
% set(h(2), 'FaceColor','r')
% set(h(1), 'FaceColor','b')
% legend({'Central-EE', 'Distributed-EE'}, 'Location', 'NorthWest');
% %title('SINR distribution');
% ylabel('Percentage of occurrence');
% xlabel('SINR (dB)');
% print(f,'-depsc', sprintf('./output/central-dist-sinr-hist%s.eps', figure_file_name));
% savefig(sprintf('./output/central-dist-sinr-hist%s.fig', figure_file_name));

f=figure; 
h=cdfplot(cum_ee_sinr_db_sorted_vector);
set(h,'color','r','LineWidth',2)
hold on;
h=cdfplot(cum_maxlog_sinr_db_sorted_vector);
set(h,'color','b','LineWidth',2)
h=cdfplot(cum_gee_sinr_db_sorted_vector);
set(h,'color','g','LineWidth',2)
h=cdfplot(cum_pmax_sinr_db_sorted_vector);
set(h,'color','y','LineWidth',2)
h=cdfplot(cum_ee_nointerf_sinr_db_sorted_vector);
set(h,'color','m','LineWidth',2)
title('SINR distribution');
ylabel('CDF');
xlabel('SINR (dB)');
legend({'Central-EE', 'Central-SE', 'Iterative-EE', 'Max-Power',  'NoInterference-EE'}, 'Location', 'NorthWest');
hold off;
print(f,'-depsc', sprintf('./output/heur-sinr-cdf%s.eps', figure_file_name));
savefig(sprintf('./output/heur-sinr-cdf%s.fig', figure_file_name));

% f=figure; 
% h=cdfplot(cum_ee_sinr_db_sorted_vector);
% set(h,'color','r','LineWidth',2)
% hold on;
% h=cdfplot(cum_maxlog_sinr_db_sorted_vector);
% set(h,'color','b','LineWidth',2)
% h=cdfplot(cum_pmin_sinr_db_sorted_vector);
% set(h,'color','g','LineWidth',2)
% h=cdfplot(cum_pmax_sinr_db_sorted_vector);
% set(h,'color','y','LineWidth',2)
% h=cdfplot(cum_ee_nointerf_sinr_db_sorted_vector);
% set(h,'color','m','LineWidth',2)
% title('SINR distribution');
% ylabel('CDF');
% xlabel('SINR (dB)');
% set(gca,'XScale','log');
% legend({'Central-EE', 'Central-SE', 'Min-Power', 'Max-Power',  'NoInterference-EE'}, 'Location', 'NorthWest');
% hold off;
% print(f,'-depsc', sprintf('./output/heur-sinr-log-cdf%s.eps', figure_file_name));
% savefig(sprintf('./output/heur-sinr-log-cdf%s.fig', figure_file_name));

% f=figure; 
% h=cdfplot(cum_ee_sinr_db_sorted_vector);
% set(h,'color','r','LineWidth',2)
% hold on;
% h=cdfplot(cum_gt_sinr_db_sorted_vector);
% set(h,'color','b','LineWidth',2)
% title('SINR distribution');
% ylabel('CDF');
% xlabel('SINR (dB)');
% legend({'Central-EE', 'Distributed-EE'}, 'Location', 'NorthWest');
% hold off;
% print(f,'-depsc', sprintf('./output/central-dist-sinr-cdf%s.eps', figure_file_name));
% savefig(sprintf('./output/central-dist-sinr-cdf%s.fig', figure_file_name));

% power_min=min([cum_maxlog_power_sorted_vector' cum_ee_power_sorted_vector' cum_pmin_power_sorted_vector' ...
%     cum_pmax_power_sorted_vector' cum_ee_nointerf_power_sorted_vector']);
% power_max=max([cum_maxlog_power_sorted_vector' cum_ee_power_sorted_vector' cum_pmin_power_sorted_vector' ...
%     cum_pmax_power_sorted_vector' cum_ee_nointerf_power_sorted_vector']);
% binranges = power_min - mod(power_min,0.1):0.1:power_max + mod(-power_max,0.1);
% [bincounts] = histc([cum_maxlog_power_sorted_vector, cum_ee_power_sorted_vector, cum_pmin_power_sorted_vector, ...
%     cum_pmax_power_sorted_vector, cum_ee_nointerf_power_sorted_vector],binranges);
% total_bins=sum(bincounts);
% f=figure;
% bar(binranges,bincounts./total_bins(1)*100,'histc')
% %hist([maxlog_power_db_vector, maxmin_power_db_vector, distributed_gt_maxlog_power_db_vector]);
% h = findobj(gca, 'Type','patch');
% set(h(5), 'FaceColor','r', 'EdgeColor','k')
% set(h(4), 'FaceColor','b', 'EdgeColor','k')
% set(h(3), 'FaceColor','g', 'EdgeColor','k')
% set(h(2), 'FaceColor','y', 'EdgeColor','k')
% set(h(1), 'FaceColor','m', 'EdgeColor','k')
% legend({'Central-EE', 'Central-SE', 'Min-Power', 'Max-Power',  'NoInterference-EE'}, 'Location', 'NorthEast');
% %title('Power distribution');
% ylabel('Percentage of occurrence');
% xlabel('Power (W)');
% print(f,'-depsc', sprintf('./output/heur-power-hist%s.eps', figure_file_name));
% savefig(sprintf('./output/heur-power-hist%s.fig', figure_file_name));
% 
% power_min=min([cum_ee_power_sorted_vector' cum_gt_power_sorted_vector']);
% power_max=max([cum_ee_power_sorted_vector' cum_gt_power_sorted_vector']);
% binranges = power_min - mod(power_min,0.1):0.1:power_max + mod(-power_max,0.1);
% [bincounts] = histc([cum_ee_power_sorted_vector, cum_gt_power_sorted_vector],binranges);
% total_bins=sum(bincounts);
% f=figure;
% bar(binranges,bincounts./total_bins(1)*100,'histc')
% %hist([maxlog_power_db_vector, maxmin_power_db_vector, distributed_gt_maxlog_power_db_vector]);
% h = findobj(gca, 'Type','patch');
% set(h(2), 'FaceColor','r', 'EdgeColor','k')
% set(h(1), 'FaceColor','b', 'EdgeColor','k')
% legend({'Central-EE', 'Distributed-EE'}, 'Location', 'NorthEast');
% %title('Power distribution');
% ylabel('Percentage of occurrence');
% xlabel('Power (W)');
% print(f,'-depsc', sprintf('./output/central-dist-power-hist%s.eps', figure_file_name));
% savefig(sprintf('./output/central-dist-power-hist%s.fig', figure_file_name));

f=figure; 
h=cdfplot(cum_ee_power_sorted_vector);
set(h,'color','r','LineWidth',2)
hold on;
h=cdfplot(cum_gt_power_sorted_vector);
set(h,'color','b','LineWidth',2)
h=cdfplot(cum_gee_power_sorted_vector);
set(h,'color','g','LineWidth',2)
title('Power distribution');
ylabel('CDF');
xlabel('Power (W)');
legend({'Central-EE', 'Distributed-EE', 'Iterative-EE'}, 'Location', 'SouthEast');
print(f,'-depsc', sprintf('./output/central-dist-power-cdf%s.eps', figure_file_name));
savefig(sprintf('./output/central-dist-power-cdf%s.fig', figure_file_name));

% f=figure(6); 
% ax(1) = subplot(2,1,1);
% h=scatter(cum_maxlog_power_vector_per_user, cum_maxlog_sinr_db_vector);
% set(h,'Marker','o','MarkerEdgeColor','b');
% ylabel('SINR (dB)');
% xlabel('Power (W)');
% title('Max-log SE');
% ax(2) = subplot(2,1,2);
% h=scatter(cum_ee_power_vector_per_user, cum_ee_sinr_db_vector);
% set(h,'Marker','+','MarkerEdgeColor','r');
% ylabel('SINR (dB)');
% xlabel('Power (W)');
% title('Max-log EE');
% linkaxes(ax,'x');
% print(f,'-depsc', sprintf('./output/sinr-power-scatter%s.eps', figure_file_name));
% savefig(sprintf('./output/sinr-power-scatter%s.fig', figure_file_name));

% f=figure(7); 
% h=scatter3(cum_pathloss_db_vector, cum_maxlog_power_vector_per_user, cum_maxlog_sinr_db_vector);
% set(h,'Marker','o','MarkerEdgeColor','b')
% hold on;
% h=scatter3(cum_pathloss_db_vector, cum_ee_power_vector_per_user, cum_ee_sinr_db_vector);
% set(h,'Marker','+','MarkerEdgeColor','r')
% title('SINR vs Power ratio vs Pathloss');
% zlabel('SINR (dB)');
% ylabel('Power (W)');
% xlabel('Pathloss (dB)');
% legend({'Centralized SE', 'Centralized EE'}, 'Location', 'NorthWest');
% hold off;
% print(f,'-depsc', sprintf('./output/sinr-power-pathloss-scatter%s.eps', figure_file_name));
% savefig(sprintf('./output/sinr-power-pathloss-scatter%s.fig', figure_file_name));

%cum_maxlog_power_vector_per_user_filtered=cum_maxlog_power_vector_per_user(cum_maxlog_sinr_db_vector > -Inf);
%cum_maxlog_sinr_db_vector_filtered=cum_maxlog_sinr_db_vector(cum_maxlog_sinr_db_vector > -Inf);
%cum_ee_power_vector_per_user_filtered=cum_ee_power_vector_per_user(cum_ee_sinr_db_vector > -Inf);
%cum_ee_sinr_db_vector_filtered=cum_ee_sinr_db_vector(cum_ee_sinr_db_vector > -Inf);

% f=figure(8);
% h=cloudPlot(cum_maxlog_power_vector_per_user_filtered,cum_maxlog_sinr_db_vector_filtered,[],[],[50 50]);
% title('SINR vs Power ratio - Max-Log SE');
% ylabel('SINR (dB)');
% xlabel('Power (W)');
% colormap jet;
% colorbar('location','eastoutside');
% print(f,'-depsc', sprintf('./output/sinr-power-cloud-maxlog%s.eps', figure_file_name));
% savefig(sprintf('./output/sinr-power-cloud-maxlogt%s.fig', figure_file_name));
% 
% f=figure(9);
% h=cloudPlot(cum_ee_power_vector_per_user_filtered,cum_ee_sinr_db_vector_filtered,[],[],[50 50]);
% title('SINR vs Power ratio - Max-Log EE');
% ylabel('SINR (dB)');
% xlabel('Power (W)');
% colormap jet;
% colorbar('location','eastoutside');
% print(f,'-depsc', sprintf('./output/sinr-power-cloud-ee%s.eps', figure_file_name));
% savefig(sprintf('./output/sinr-power-cloud-ee%s.fig', figure_file_name));

%%%
% x = cum_maxlog_power_vector_per_user_filtered;
% y = cum_maxlog_sinr_db_vector_filtered;
% n = 25; % Number of bins
% xi = linspace(min(x(:)), max(x(:)), n);
% yi = linspace(min(y(:)), max(y(:)), n);
% xr = interp1(xi, 0.5:numel(xi)-0.5, x, 'nearest');
% yr = interp1(yi, 0.5:numel(yi)-0.5, y, 'nearest');
% Z = accumarray([yr xr] + 0.5, 1, [n n]);
%  
% f=figure(10);
% h=surf(xi, yi, Z);
% xlabel('Power (W)');
% ylabel('SINR (dB)');
% zlabel('count');
% colormap jet;
% colorbar('location','eastoutside');
% print(f,'-depsc', sprintf('./output/sinr-power-3d-maxlog-se%s.eps', figure_file_name));
% savefig(sprintf('./output/sinr-power-3d-maxlog-se%s.fig', figure_file_name));
% 
% x = cum_ee_power_vector_per_user_filtered;
% y = cum_ee_sinr_db_vector_filtered;
% n = 25; % Number of bins
% xi = linspace(min(x(:)), max(x(:)), n);
% yi = linspace(min(y(:)), max(y(:)), n);
% xr = interp1(xi, 0.5:numel(xi)-0.5, x, 'nearest');
% yr = interp1(yi, 0.5:numel(yi)-0.5, y, 'nearest');
% Z = accumarray([yr xr] + 0.5, 1, [n n]);
%  
% f=figure(11);
% h=surf(xi, yi, Z);
% xlabel('Power (W)');
% ylabel('SINR (dB)');
% zlabel('count');
% colormap jet;
% colorbar('location','eastoutside');
% print(f,'-depsc', sprintf('./output/sinr-power-3d-ee%s.eps', figure_file_name));
% savefig(sprintf('./output/sinr-power-3d-maxlog-ee%s.fig', figure_file_name));

% f=figure;
% boxplot([cum_ee_sinr_db_vector cum_maxlog_sinr_db_vector cum_pmin_sinr_db_vector ...
%     cum_pmax_sinr_db_vector cum_ee_nointerf_sinr_db_vector], 'notch', 'off');
% set(gca,'xtick',1:5, 'xticklabel',{'Central-EE', 'Central-SE', 'Min-Power', 'Max-Power',  'NoInterference-EE'})
% ylabel('SINR (dB)');
% cleanfigure;
% print(f,'-depsc', sprintf('./output/heur-boxplot-sinr%s.eps', figure_file_name));
% savefig(sprintf('./output/heur-boxplot-sinr%s.fig', figure_file_name));
% matlab2tikz(sprintf('./output/heur-boxplot-sinr%s%s.tex', figure_file_name),'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '\figureheight', 'width','\figurewidth');

% f=figure;
% boxplot([cum_ee_sinr_db_vector cum_gt_sinr_db_vector, cum_gee_sinr_db_vector], 'notch', 'off');
% set(gca,'xtick',1:3, 'xticklabel',{'Central-EE', 'Distributed-EE', 'GEE'})
% ylabel('SINR (dB)');
% cleanfigure;
% print(f,'-depsc', sprintf('./output/central-dist-boxplot-sinr%s.eps', figure_file_name));
% savefig(sprintf('./output/central-dist-boxplot-sinr%s.fig', figure_file_name));
% matlab2tikz(sprintf('./output/central-dist-boxplot-sinr%s.tex', figure_file_name),'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '\figureheight', 'width','\figurewidth');

% f=figure;
% boxplot([cum_ee_power_vector_per_user cum_maxlog_power_vector_per_user cum_pmin_power_vector_per_user...
%     cum_pmax_power_vector_per_user cum_ee_nointerf_power_vector_per_user], 'notch', 'off', ...
%     'Label', {'Central-EE', 'Central-SE', 'Min-Power', 'Max-Power',  'NoInterference-EE'});
% ylabel('Power (W)');
% print(f,'-depsc', sprintf('./output/heur-boxplot-power%s.eps', figure_file_name));
% savefig(sprintf('./output/heur-boxplot-power%s.fig', figure_file_name));

f=figure;
boxplot([cum_ee_power_vector cum_gt_power_vector cum_gee_power_vector ...
    cum_maxlog_power_vector cum_pmax_power_vector cum_ee_nointerf_power_vector], 'notch', 'off');
set(gca,'xtick',1:6, 'xticklabel',{'Central-EE', 'Distributed-EE', 'Iterative-EE', 'Central-SE', 'Max-Power',  'NoInterference-EE'})
ylabel('Power (W)');
cleanfigure;
print(f,'-depsc', sprintf('./output/heur-boxplot-power%s.eps', figure_file_name));
savefig(sprintf('./output/heur-boxplot-power%s.fig', figure_file_name));
matlab2tikz(sprintf('./output/heur-boxplot-power%s.tex', figure_file_name),'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');

% f=figure;
% boxplot([cum_ee_power_vector cum_gt_power_vector cum_gee_power_vector], 'notch', 'off', ...
%     'Label', {'Central-EE', 'Distributed-EE', 'GEE'});
% set(gca,'xtick',1:3, 'xticklabel',{'Central-EE', 'Distributed-EE', 'GEE'})
% ylabel('Power (W)');
% cleanfigure;
% print(f,'-depsc', sprintf('./output/central-dist-boxplot-power%s.eps', figure_file_name));
% savefig(sprintf('./output/central-dist-boxplot-power%s.fig', figure_file_name));
% matlab2tikz(sprintf('./output/central-dist-boxplot-power%s.tex', figure_file_name),'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '\figureheight', 'width','\figurewidth');

%%% Performance plots
% 
% f=figure;
% boxplot([cum_ee_time, cum_gt_time],...
%     'notch', 'off');
% set(gca,'xtick',1:2, 'xticklabel',{'Central-EE', 'Distributed-EE'})
% ylabel('Computation time (s)');
% cleanfigure;
% print(f,'-depsc', sprintf('./output/central-dist-computation-time%s.eps', figure_file_name));
% savefig(sprintf('./output/central-dist-computation-time%s.fig', figure_file_name));
% matlab2tikz(sprintf('./output/central-dist-computation-time%s.tex', figure_file_name),'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '\figureheight', 'width','\figurewidth');
% 
% f=figure;
% boxplot([cum_ee_steps, cum_gt_steps],...
%     'notch', 'off');
% set(gca,'xtick',1:2, 'xticklabel',{'Central-EE', 'Distributed-EE'})
% ylabel('Sugradient steps');
% cleanfigure;
% print(f,'-depsc', sprintf('./output/central-dist-subgrad-steps%s.eps', figure_file_name));
% savefig(sprintf('./output/central-dist-subgrad-steps%s.fig', figure_file_name));
% matlab2tikz(sprintf('./output/central-dist-subgrad-steps%s.tex', figure_file_name),'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '\figureheight', 'width','\figurewidth');
% 
% f=figure;
% boxplot([cum_ee_rounds, cum_gt_rounds],...
%     'notch', 'off');
% set(gca,'xtick',1:2, 'xticklabel',{'Central-EE', 'Distributed-EE'})
% ylabel('Computation rounds');
% cleanfigure;
% print(f,'-depsc', sprintf('./output/central-dist-computation-rounds%s.eps', figure_file_name));
% savefig(sprintf('./output/central-dist-computation-rounds%s.fig', figure_file_name));
% matlab2tikz(sprintf('./output/central-dist-computation-rounds%s.tex', figure_file_name),'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '\figureheight', 'width','\figurewidth');
% 
% f=figure;
% boxplot([cum_gt_rounds],...
%     'notch', 'off');
% set(gca,'xtick',1:1, 'xticklabel',{'Distributed-EE'})
% ylabel('Best response rounds');
% cleanfigure;
% print(f,'-depsc', sprintf('./output/dist-computation-rounds%s.eps', figure_file_name));
% savefig(sprintf('./output/dist-computation-rounds%s.fig', figure_file_name));
% matlab2tikz(sprintf('./output/dist-computation-rounds%s.tex', figure_file_name),'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '\figureheight', 'width','\figurewidth');

% f=figure(14);
% ax(1) = subplot(2,1,1);
% h=scatter(cum_maxlog_power_vector_per_user_filtered, cum_maxlog_sinr_db_vector_filtered);
% title('SINR vs Power ratio - Max-Log SE');
% ylabel('SINR (dB)');
% xlabel('Power (W)');
% 
% ax(2) = subplot(2,1,2);
% h=scatter(cum_ee_power_vector_per_user_filtered,cum_ee_sinr_db_vector_filtered);
% title('SINR vs Power ratio - Max-Log EE');
% ylabel('SINR (dB)');
% xlabel('Power (W)');
% linkaxes(ax,'x');
% 
% print(f,'-depsc', sprintf('./output/sinr-power-scatter%s.eps', figure_file_name));
% savefig(sprintf('./output/sinr-power-scatter%s.fig', figure_file_name));

f=figure;
%ax(1) = subplot(1,2,1);
h=bagplot([cum_ee_power_vector_per_user cum_ee_sinr_db_vector], ...
    'databag', '0', 'datafence', '0');
title('SINR vs Power ratio - Central-EE');
ylabel('SINR (dB)');
xlabel('Power (W)');
xlim([0 0.5])
print(f,'-depsc', sprintf('./output/sinr-power-bag-ee%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-power-bag-ee%s.fig', figure_file_name));
matlab2tikz(sprintf('./output/sinr-power-bag-ee%s.tex', figure_file_name),'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');

f=figure;
%ax(2) = subplot(1,2,2);
h=bagplot([cum_gt_power_vector_per_user cum_gt_sinr_db_vector], ...
    'databag', '0', 'datafence', '0');
title('SINR vs Power ratio - Distributed-EE');
ylabel('SINR (dB)');
xlabel('Power (W)');
xlim([0 1.5])
print(f,'-depsc', sprintf('./output/sinr-power-bag-gt-ee%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-power-bag-gt-ee%s.fig', figure_file_name));
matlab2tikz(sprintf('./output/sinr-power-bag-gt-ee%s.tex', figure_file_name),'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');

f=figure;
%ax(2) = subplot(1,2,2);
h=bagplot([cum_gee_power_vector cum_gee_sinr_db_vector], ...
    'databag', '0', 'datafence', '0');
title('SINR vs Power ratio - Iterative-EE');
ylabel('SINR (dB)');
xlabel('Power (W)');
xlim([0 0.5])
print(f,'-depsc', sprintf('./output/sinr-power-bag-gee-ee%s.eps', figure_file_name));
savefig(sprintf('./output/sinr-power-bag-gee-ee%s.fig', figure_file_name));
matlab2tikz(sprintf('./output/sinr-power-bag-gee-ee%s.tex', figure_file_name),'showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');
    
% f=figure;
% %ax(2) = subplot(1,2,2);
% h=bagplot([cum_maxlog_power_vector_per_user cum_maxlog_sinr_db_vector], ...
%     'databag', '0', 'datafence', '0');
% title('SINR vs Power ratio - Central-SE');
% ylabel('SINR (dB)');
% xlabel('Power (W)');
% xlim([0 1.5])
% print(f,'-depsc', sprintf('./output/sinr-power-bag-se%s.eps', figure_file_name));
% savefig(sprintf('./output/sinr-power-bag-se%s.fig', figure_file_name));
% matlab2tikz(sprintf('./output/sinr-power-bag-se%s.tex', figure_file_name),'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '\figureheight', 'width','\figurewidth');
% 
% f=figure;
% %ax(2) = subplot(1,2,2);
% h=bagplot([cum_ee_nointerf_power_vector_per_user cum_ee_nointerf_sinr_db_vector], ...
%     'databag', '0', 'datafence', '0');
% title('SINR vs Power ratio - NoInterference-EE');
% ylabel('SINR (dB)');
% xlabel('Power (W)');
% xlim([0 1.5])
% print(f,'-depsc', sprintf('./output/sinr-power-bag-ee-nointerf%s.eps', figure_file_name));
% savefig(sprintf('./output/sinr-power-bag-ee-nointerf%s.fig', figure_file_name));
% matlab2tikz(sprintf('./output/sinr-power-bag-ee-nointerf%s.tex', figure_file_name),'showInfo', false, ...
%         'parseStrings',false,'standalone', false, ...
%         'height', '\figureheight', 'width','\figurewidth');
    
% f=figure(16);
% subplot(2,4,1)
% h=scatter(cum_pathloss_db_vector, cum_maxlog_power_vector_per_user);
% title('Max-Log SE');
% ylabel('Power (W)');
% xlabel('Pathloss (dB)');
% 
% subplot(2,4,2)
% h=scatter(cum_pathloss_db_vector, cum_maxlog_sinr_db_vector);
% title('Max-Log SE');
% ylabel('SINR (dB)');
% xlabel('Pathloss (dB)');
% 
% subplot(2,4,3)
% h=cloudPlot(cum_pathloss_db_vector, cum_maxlog_power_vector_per_user,[],[],[50 50]);
% colormap jet;
% colorbar('location','eastoutside');
% title('Max-Log SE');
% ylabel('Power (W)');
% xlabel('Pathloss (dB)');
% 
% subplot(2,4,4)
% h=cloudPlot(cum_pathloss_db_vector, cum_maxlog_sinr_db_vector,[],[],[50 50]);
% colormap jet;
% colorbar('location','eastoutside');
% title('Max-Log SE');
% ylabel('SINR (dB)');
% xlabel('Pathloss (dB)');
% 
% subplot(2,4,5)
% h=scatter(cum_pathloss_db_vector, cum_ee_power_vector_per_user);
% title('Max-Log EE');
% ylabel('Power (W)');
% xlabel('Pathloss (dB)');
% 
% subplot(2,4,6)
% h=scatter(cum_pathloss_db_vector, cum_ee_sinr_db_vector);
% title('Max-Log EE');
% ylabel('SINR (dB)');
% xlabel('Pathloss (dB)');
% 
% subplot(2,4,7)
% h=cloudPlot(cum_pathloss_db_vector, cum_ee_power_vector_per_user,[],[],[50 50]);
% colormap jet;
% colorbar('location','eastoutside');
% title('Max-Log EE');
% ylabel('Power (W)');
% xlabel('Pathloss (dB)');
% 
% subplot(2,4,8)
% h=cloudPlot(cum_pathloss_db_vector, cum_ee_sinr_db_vector,[],[],[50 50]);
% colormap jet;
% colorbar('location','eastoutside');
% title('Max-Log EE');
% ylabel('SINR (dB)');
% xlabel('Pathloss (dB)');
% 
% print(f,'-depsc', sprintf('./output/sinr-power-pathloss-scatter%s.eps', figure_file_name));
% savefig(sprintf('./output/sinr-power-pathloss-scatter%s.fig', figure_file_name));
