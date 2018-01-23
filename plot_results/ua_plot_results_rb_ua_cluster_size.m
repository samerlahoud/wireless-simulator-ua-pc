function ua_plot_results_rb_ua_cluster_size
global netconfig;
nb_iterations = netconfig.nb_iterations;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;
nb_femto_BSs = netconfig.nb_femto_BSs;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;
nb_RBs = netconfig.nb_RBs;

output_dir = './output/user-association-output/';
figure_file_name = sprintf('-%dusers',nb_users);

reuse_min_pathloss_vector = [1e10, 1e11, 1e12, 1e13];
cum_femto_size = [];
cum_femto_demand = []; 

for i = 1:nb_iterations 
    for j = 1:length(reuse_min_pathloss_vector)
        %load(sprintf('./output/user-association-output/3femto-%ddB/radio-conditions-100users-%drun.mat',10*log10(reuse_min_pathloss_vector(j)), i));
        load(sprintf('./output/user-association-output/rb-ua-100users-uniform-0.25-%ddB/radio-conditions-100users-%drun.mat',10*log10(reuse_min_pathloss_vector(j)), i));
        temp_femto_size(j,:) = [sum(BS_to_BS_pathloss(nb_macro_BSs+1:nb_macro_femto_BSs,nb_macro_BSs+1:nb_macro_femto_BSs)<=reuse_min_pathloss_vector(j))];
        temp_femto_demand(j,:) = femto_demand';
    end
    cum_femto_size = [cum_femto_size, temp_femto_size];
    cum_femto_demand = [cum_femto_demand, temp_femto_demand];
end
f=figure;
boxplot(cum_femto_size','notch', 'off', 'Label', {'100dB', '110dB', '120dB', '130dB'});
ylabel('Femto cluster size');
xlabel('Pathloss threshold');
print(f,'-depsc', sprintf('%s/rb-ua-femto-size%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-femto-size%s.fig', output_dir, figure_file_name));

f=figure;
boxplot(cum_femto_demand','notch', 'off', 'Label', {'100dB', '110dB', '120dB', '130dB'});
ylabel('Femto demand');
xlabel('Pathloss threshold');
print(f,'-depsc', sprintf('%s/rb-ua-femto-demand%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-femto-demand%s.fig', output_dir, figure_file_name));
end