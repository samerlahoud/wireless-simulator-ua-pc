function ua_plot_results_ua_algo_compare
global netconfig;
nb_iterations = netconfig.nb_iterations;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;
nb_femto_BSs = netconfig.nb_femto_BSs;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_RBs = netconfig.nb_RBs;

output_dir = './output/user-association-output/ua-100users-cluster';

cum_sinr_based_rate = [];
cum_sinr_based_obj = [];
cum_sinr_based_ua = [];
cum_range_ext_rate = [];
cum_range_ext_obj = [];
cum_range_ext_ua = [];
cum_small_cell_first_rate = [];
cum_small_cell_first_obj = [];
cum_small_cell_first_ua = [];
cum_optimal_pf_rate = [];
cum_optimal_pf_obj = [];
cum_optimal_pf_ua = [];
cum_br_pf_rate = [];
cum_br_pf_obj = [];
cum_br_pf_ua = [];
%cum_sinr = [];
cum_nb_macro_users_sinr_based = [];
cum_nb_small_cell_users_sinr_based = [];
cum_nb_macro_users_range_ext = [];
cum_nb_small_cell_users_range_ext = [];
cum_nb_macro_users_small_cell_first = [];
cum_nb_small_cell_users_small_cell_first = [];
cum_nb_macro_users_optimal_pf = [];
cum_nb_small_cell_users_optimal_pf = [];
cum_nb_macro_users_br_pf = [];
cum_nb_small_cell_users_br_pf = [];
cum_nb_dual_ms_users_optimal_pf = [];
cum_nb_dual_mm_users_optimal_pf = [];
cum_nb_dual_ss_users_optimal_pf = [];

cum_optimal_pf_sinr_rank = [];

for i = 1:nb_iterations
    load(sprintf('%s/user-association-%dusers-%drun.mat', output_dir, nb_users, i));
    cum_sinr_based_rate = [cum_sinr_based_rate; sinr_based_rate];
    cum_sinr_based_obj = [cum_sinr_based_obj; sinr_based_obj];
    cum_sinr_based_ua = [cum_sinr_based_ua; sinr_based_ua];
    cum_nb_macro_users_sinr_based = [cum_nb_macro_users_sinr_based; sum(sum(sinr_based_ua(:,1:nb_macro_BSs)))];
    cum_nb_small_cell_users_sinr_based = [cum_nb_small_cell_users_sinr_based; sum(sum(sinr_based_ua(:,nb_macro_BSs+1:nb_BSs)))];
    
    cum_range_ext_rate = [cum_range_ext_rate; range_ext_rate];
    cum_range_ext_obj = [cum_range_ext_obj; range_ext_obj];
    cum_range_ext_ua = [cum_range_ext_ua; range_ext_ua];
    cum_nb_macro_users_range_ext = [cum_nb_macro_users_range_ext; sum(sum(range_ext_ua(:,1:nb_macro_BSs)))];
    cum_nb_small_cell_users_range_ext = [cum_nb_small_cell_users_range_ext; sum(sum(range_ext_ua(:,nb_macro_BSs+1:nb_BSs)))];
    
    cum_small_cell_first_rate = [cum_small_cell_first_rate; small_cell_first_rate];
    cum_small_cell_first_obj = [cum_small_cell_first_obj; small_cell_first_obj];
    cum_small_cell_first_ua = [cum_small_cell_first_ua; small_cell_first_ua];
    cum_nb_macro_users_small_cell_first = [cum_nb_macro_users_small_cell_first; sum(sum(small_cell_first_ua(:,1:nb_macro_BSs)))];
    cum_nb_small_cell_users_small_cell_first = [cum_nb_small_cell_users_small_cell_first; sum(sum(small_cell_first_ua(:,nb_macro_BSs+1:nb_BSs)))];
    
    cum_br_pf_rate = [cum_br_pf_rate; br_pf_rate];
    cum_br_pf_obj = [cum_br_pf_obj; br_pf_obj];
    cum_br_pf_ua = [cum_br_pf_ua; br_pf_ua];
    cum_nb_macro_users_br_pf = [cum_nb_macro_users_br_pf; sum(sum(br_pf_ua(:,1:nb_macro_BSs)))];
    cum_nb_small_cell_users_br_pf = [cum_nb_small_cell_users_br_pf; sum(sum(br_pf_ua(:,nb_macro_BSs+1:nb_BSs)))];
    
    cum_optimal_pf_rate = [cum_optimal_pf_rate; optimal_pf_rate];
    cum_optimal_pf_obj = [cum_optimal_pf_obj; optimal_pf_obj];
    cum_optimal_pf_ua = [cum_optimal_pf_ua; optimal_pf_ua];
    nb_dual_ms_users_optimal_pf = 0;
    nb_dual_mm_users_optimal_pf = 0;
    nb_dual_ss_users_optimal_pf = 0;
    nb_macro_users_optimal_pf = 0;
    nb_small_cell_users_optimal_pf = 0;
    for u = 1:nb_users
        a_ = sum(optimal_pf_ua(u,1:nb_macro_BSs)>=1e-3);
        b_ = sum(optimal_pf_ua(u,nb_macro_BSs+1:nb_BSs)>=1e-3);
        if a_ >=1 && b_ >=1
            nb_dual_ms_users_optimal_pf = nb_dual_ms_users_optimal_pf+1;
        elseif a_ >=1
            nb_macro_users_optimal_pf = nb_macro_users_optimal_pf + 1;  
        elseif b_ >=1
            nb_small_cell_users_optimal_pf = nb_small_cell_users_optimal_pf + 1;
        end
        if a_ >=2
            nb_dual_mm_users_optimal_pf = nb_dual_mm_users_optimal_pf+1;
        end
        if b_ >=2
            nb_dual_ss_users_optimal_pf = nb_dual_ss_users_optimal_pf+1;
        end
    end
    cum_nb_macro_users_optimal_pf = [cum_nb_macro_users_optimal_pf; nb_macro_users_optimal_pf];
    cum_nb_small_cell_users_optimal_pf = [cum_nb_small_cell_users_optimal_pf; nb_small_cell_users_optimal_pf];
    cum_nb_dual_ms_users_optimal_pf = [cum_nb_dual_ms_users_optimal_pf; nb_dual_ms_users_optimal_pf];
    cum_nb_dual_ss_users_optimal_pf = [cum_nb_dual_ss_users_optimal_pf; nb_dual_ss_users_optimal_pf];
    cum_nb_dual_mm_users_optimal_pf = [cum_nb_dual_mm_users_optimal_pf; nb_dual_mm_users_optimal_pf];
    
    load(sprintf('%s/radio-conditions-%dusers-%drun.mat', output_dir, nb_users, i));
    for u = 1:nb_users
        %[~,ind] = sort(sinr(u,:),'descend');
        [~,ind] = sort(peak_rate(u,:),'descend');
    	rank_sinr(ind) = [1:nb_BSs];
        optimal_pf_ua_indic = (optimal_pf_ua(u,:)>=1e-3);
        rank_ua_indic = rank_sinr .* optimal_pf_ua_indic;
        cum_optimal_pf_sinr_rank = [cum_optimal_pf_sinr_rank rank_ua_indic(rank_ua_indic>=1)];
    end
end

% Plot results
figure_file_name = sprintf('-%dusers',nb_users);

f=figure;
boxplot([(cum_nb_small_cell_users_optimal_pf+cum_nb_dual_ms_users_optimal_pf)/nb_users, cum_nb_small_cell_users_sinr_based/nb_users, ...
    cum_nb_small_cell_users_range_ext/nb_users, cum_nb_small_cell_users_small_cell_first/nb_users, cum_nb_small_cell_users_br_pf/nb_users],...
    'notch', 'off', 'Label', {'Optimal', 'SINR-Based', 'Range-Ext', 'Femto-First', 'Best-Response'});
ylabel('Percentage of users associated to femtocells');
print(f,'-depsc', sprintf('%s/ua-femto-users%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/ua-femto-users%s.fig', output_dir, figure_file_name));


f=figure;
hist(cum_optimal_pf_sinr_rank);
%Workaround
% Get histogram patches
ph = get(gca,'children');
% Determine number of histogram patches
N_patches = length(ph);
for i = 1:N_patches
      % Get patch vertices
      vn = get(ph(i),'Vertices');
      % Adjust y location
      vn(:,2) = vn(:,2) + 1;
      % Reset data
      set(ph(i),'Vertices',vn)
end
% Change scale
set(gca,'yscale','log');
set(gca,'XTickLabel',['1  ';'2  ';'3  ';'4  ';'5  ';'6  ';'7  ';'8  '])
print(f,'-depsc', sprintf('%s/ua-optimal-sinr-rank%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/ua-optimal-sinr-rank%s.fig', output_dir, figure_file_name));

f=figure;
boxplot([cum_nb_dual_ms_users_optimal_pf/nb_users, cum_nb_dual_mm_users_optimal_pf /nb_users, ...
    cum_nb_dual_ss_users_optimal_pf /nb_users],...
    'notch', 'off', 'Label', {'Dual Macro Femto', 'Dual Macro', 'Dual Femto'});
ylabel('Percentage of dual connected users');
print(f,'-depsc', sprintf('%s/ua-dual-users%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/ua-dual-users%s.fig', output_dir, figure_file_name));

f=figure;
boxplot([cum_optimal_pf_obj, cum_sinr_based_obj, cum_range_ext_obj, cum_small_cell_first_obj, cum_br_pf_obj],...
    'notch', 'off', 'Label', {'Optimal', 'SINR-Based', 'Range-Ext', 'Femto-First', 'Best-Response'});
ylabel('Objective');
print(f,'-depsc', sprintf('%s/ua-boxplot-objective%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/ua-boxplot-objective%s.fig', output_dir, figure_file_name));

f=figure; 
%h=cdfplot(cum_optimal_pf_rate/(nb_RBs*1e6/5));
h=cdfplot(cum_optimal_pf_rate/1e6);
set(h,'color','c','LineWidth',2)
hold on;
%h=cdfplot(cum_sinr_based_rate/(nb_RBs*1e6/5));
h=cdfplot(cum_sinr_based_rate/1e6);
set(h,'color','r','LineWidth',2)
%h=cdfplot(cum_range_ext_rate/(nb_RBs*1e6/5));
h=cdfplot(cum_range_ext_rate/1e6);
set(h,'color','b','LineWidth',2)
%h=cdfplot(cum_small_cell_first_rate/(nb_RBs*1e6/5));
h=cdfplot(cum_small_cell_first_rate/1e6);
set(h,'color','g','LineWidth',2)
%h=cdfplot(cum_br_pf_rate/(nb_RBs*1e6/5));
h=cdfplot(cum_br_pf_rate/1e6);
set(h,'color','k','LineWidth',2)
title('Rate distribution');
ylabel('CDF');
xlabel('Rate (Mbits/s)');
set(gca,'XScale','log');
legend({'Optimal', 'SINR-Based', 'Range-Ext', 'Femto-First', 'Best-Response'}, 'Location', 'SouthEast');
hold off;
print(f,'-depsc', sprintf('%s/ua-cdf-rate%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/ua-cdf-rate%s.fig', output_dir, figure_file_name));