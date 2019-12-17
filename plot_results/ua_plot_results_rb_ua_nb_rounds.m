function ua_plot_results_rb_ua_nb_rounds
global netconfig;
nb_iterations = netconfig.nb_iterations;
nb_users = netconfig.nb_users;
%nb_femto_BSs = netconfig.nb_femto_BSs;
%nb_RBs = netconfig.nb_RBs;

output_dir = './output/user-association-output';

cum_m1_nb_rounds=[];
cum_m1_ua_nb_rounds=[];

for i = 1:nb_iterations
    load(sprintf('%s/rb-ua-100users-uniform-0.15-110dB-rounds-computation/rb-ua-allocation-%dusers-%drun.mat', output_dir, nb_users, i));
    cum_m1_nb_rounds=[cum_m1_nb_rounds; m1_nb_rounds];
    cum_m1_ua_nb_rounds=[cum_m1_ua_nb_rounds; m1_ua_nb_rounds];  
end

% Plot results
figure_file_name = sprintf('-%dusers',nb_users);

f=figure;
boxplot([cum_m1_nb_rounds, cum_m1_ua_nb_rounds],...
    'notch', 'off', ...
    'Label', {'BR-SA', 'BR-UA'});
ylabel('Number of iterations');
set(gca,'XTickLabelRotation',45);
ax = gca;
ax.YGrid = 'on';
print(f,'-depsc', sprintf('%s/convergence/rb-ua-boxplot-rounds%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/convergence/rb-ua-boxplot-rounds%s.fig', output_dir, figure_file_name));