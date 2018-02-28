function ua_plot_results_rb_reuse_pathloss_cdf_rate
global netconfig;
nb_iterations = netconfig.nb_iterations;
nb_users = netconfig.nb_users;
%nb_femto_BSs = netconfig.nb_femto_BSs;
%nb_RBs = netconfig.nb_RBs;

output_dir = './output/user-association-output';
figure_file_name = sprintf('-%dusers',nb_users);

cum_m11_rate = [];
cum_m13_rate = [];
cum_m11_obj = [];
cum_m11_ua = [];
cum_m11_macro_traffic = [];
cum_m11_femto_traffic = [];
cum_m11_mmwave_traffic = [];
cum_m11_jain_index = [];
cum_m21_rate = [];
cum_m21_obj = [];
cum_m21_ua = [];
cum_m21_macro_traffic = [];
cum_m21_femto_traffic = [];
cum_m21_mmwave_traffic = [];
cum_m21_jain_index = [];
cum_m31_rate = [];
cum_m31_obj = [];
cum_m31_ua = [];
cum_m31_macro_traffic = [];
cum_m31_femto_traffic = [];
cum_m31_mmwave_traffic = [];
cum_m31_jain_index = [];
cum_m41_rate = [];
cum_m41_obj = [];
cum_m41_ua = [];
cum_m41_macro_traffic = [];
cum_m41_femto_traffic = [];
cum_m41_mmwave_traffic = [];
cum_m41_jain_index = [];
cum_m51_rate = [];
cum_m51_obj = [];
cum_m51_ua = [];
cum_m51_macro_traffic = [];
cum_m51_femto_traffic = [];
cum_m51_mmwave_traffic = [];
cum_m51_jain_index = [];
cum_m61_rate = [];
cum_m61_obj = [];
cum_m61_ua = [];
cum_m61_macro_traffic = [];
cum_m61_femto_traffic = [];
cum_m61_mmwave_traffic = [];
cum_m61_jain_index = [];

cum_m12_rate = [];
cum_m12_obj = [];
cum_m12_ua = [];
cum_m12_macro_traffic = [];
cum_m12_femto_traffic = [];
cum_m12_mmwave_traffic = [];
cum_m12_jain_index = [];
cum_m22_rate = [];
cum_m22_obj = [];
cum_m22_ua = [];
cum_m22_macro_traffic = [];
cum_m22_femto_traffic = [];
cum_m22_mmwave_traffic = [];
cum_m22_jain_index = [];
cum_m32_rate = [];
cum_m32_obj = [];
cum_m32_ua = [];
cum_m32_macro_traffic = [];
cum_m32_femto_traffic = [];
cum_m32_mmwave_traffic = [];
cum_m32_jain_index = [];
cum_m42_rate = [];
cum_m42_obj = [];
cum_m42_ua = [];
cum_m42_macro_traffic = [];
cum_m42_femto_traffic = [];
cum_m42_mmwave_traffic = [];
cum_m42_jain_index = [];
cum_m52_rate = [];
cum_m52_obj = [];
cum_m52_ua = [];
cum_m52_macro_traffic = [];
cum_m52_femto_traffic = [];
cum_m52_mmwave_traffic = [];
cum_m52_jain_index = [];
cum_m62_rate = [];
cum_m62_obj = [];
cum_m62_ua = [];
cum_m62_macro_traffic = [];
cum_m62_femto_traffic = [];
cum_m62_mmwave_traffic = [];
cum_m62_jain_index = [];

for i = 1:nb_iterations
    load(sprintf('%s/rb-ua-100users-uniform-0.15-120dB/radio-conditions-%dusers-%drun.mat', output_dir, nb_users, i));
    load(sprintf('%s/rb-ua-100users-uniform-0.15-120dB/rb-ua-allocation-%dusers-%drun.mat', output_dir, nb_users, i));
    
    nb_BSs = netconfig.nb_BSs;
    nb_macro_BSs = netconfig.nb_macro_BSs;
    nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;
    femto_user_rate = [];
        
    for u = 1:nb_users
        user_rate = 0;
        for b = nb_macro_BSs+1:nb_macro_femto_BSs
            if sum(m1_ua(:,b)) >= 1e-4
                user_rate = user_rate + m1_ua(u,b)*m1_peak_rate(u,b)/sum(m1_ua(:,b));
            end
        end
        if user_rate > 0
            femto_user_rate = [femto_user_rate; user_rate];
        end
    end
    cum_m11_rate = [cum_m11_rate; femto_user_rate];
    
end

for i = 1:nb_iterations
    load(sprintf('%s/rb-ua-100users-uniform-0.15-110dB/radio-conditions-%dusers-%drun.mat', output_dir, nb_users, i));
    load(sprintf('%s/rb-ua-100users-uniform-0.15-110dB/rb-ua-allocation-%dusers-%drun.mat', output_dir, nb_users, i));
    
    nb_BSs = netconfig.nb_BSs;
    nb_macro_BSs = netconfig.nb_macro_BSs;
    nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;
    femto_user_rate = [];
        
    for u = 1:nb_users
        user_rate = 0;
        for b = nb_macro_BSs+1:nb_macro_femto_BSs
            if sum(m1_ua(:,b)) >= 1e-4
                user_rate = user_rate + m1_ua(u,b)*m1_peak_rate(u,b)/sum(m1_ua(:,b));
            end
        end
        if user_rate > 0
            femto_user_rate = [femto_user_rate; user_rate];
        end
    end
    
    cum_m12_rate = [cum_m12_rate; femto_user_rate];
end

for i = 1:nb_iterations
    load(sprintf('%s/rb-ua-100users-uniform-0.15-100dB/radio-conditions-%dusers-%drun.mat', output_dir, nb_users, i));
    load(sprintf('%s/rb-ua-100users-uniform-0.15-100dB/rb-ua-allocation-%dusers-%drun.mat', output_dir, nb_users, i));
    
    nb_BSs = netconfig.nb_BSs;
    nb_macro_BSs = netconfig.nb_macro_BSs;
    nb_macro_femto_BSs = netconfig.nb_macro_femto_BSs;
    femto_user_rate = [];
        
    for u = 1:nb_users
        user_rate = 0;
        for b = nb_macro_BSs+1:nb_macro_femto_BSs
            if sum(m1_ua(:,b)) >= 1e-4
                user_rate = user_rate + m1_ua(u,b)*m1_peak_rate(u,b)/sum(m1_ua(:,b));
            end
        end
        if user_rate > 0
            femto_user_rate = [femto_user_rate; user_rate];
        end
    end
    
    cum_m13_rate = [cum_m13_rate; femto_user_rate];
end


f=figure; 
h=cdfplot(cum_m11_rate/1e6);
set(h,'color','c','LineWidth',2)
hold on;
h=cdfplot(cum_m12_rate/1e6);
set(h,'color','r','LineWidth',2)
h=cdfplot(cum_m13_rate/1e6);
set(h,'color','b','LineWidth',2)
title('Rate distribution');
ylabel('CDF');
xlabel('Rate (Mbits/s)');
set(gca,'XScale','log');
legend({'BR+BR+120', 'BR+BR+110', 'BR+BR-100'}, 'Location', 'NorthWest');
hold off;
print(f,'-depsc', sprintf('%s/rb-ua-cdf-rate%s.eps', output_dir, figure_file_name));
savefig(sprintf('%s/rb-ua-cdf-rate%s.fig', output_dir, figure_file_name));