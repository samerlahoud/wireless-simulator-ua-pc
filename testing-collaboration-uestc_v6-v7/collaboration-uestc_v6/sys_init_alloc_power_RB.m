function [eNodeBs,UEs]=sys_init_alloc_power_RB(eNodeBs,UEs,pathloss_matrix)
% 
% 功率初始化
%
global netconfig;
N_RB                 = netconfig.nb_RBs;
RB_bandwidth         = netconfig.RB_bandwidth;
noise_density        = netconfig.noise_density;
UE_per_eNodeB        = netconfig.nb_users_per_sector;
min_power_per_RB     = netconfig.min_power_per_RB;   
max_power_per_sector = netconfig.max_power_per_sector;
number_of_bts   = length(eNodeBs);
%% 衰落矩阵的维数转换
%
g = dim_transform(pathloss_matrix); % 用于后面程序的方便运行，最后整理程序的时候要统一起来
%
%% 宏基站分配RB
% 将基站的RB分配完
for b_ = 1:number_of_bts
    g_temp = g(1 + UE_per_eNodeB*(b_-1):UE_per_eNodeB*b_,:,b_); % 对于某一特定基站，取出其对应的衰落值(基站用户，RB)
    while nnz(g_temp) ~= 0
        for u_ = 1:UE_per_eNodeB
            [~,n_ix] = max(g_temp(u_,:));  % 取该用户对应衰落值最大的RB的序号
            UEs(u_+UE_per_eNodeB*(b_-1)) = alloc_RB(UEs(u_+UE_per_eNodeB*(b_-1)),n_ix); % Allocate RB to UE
            eNodeBs(b_).RB(n_ix) = u_+UE_per_eNodeB*(b_-1); % 资源块用户分配矩阵
            g_temp(:,n_ix) = 0; % 按照衰落值从大到小的顺序来分配RB，将已分配的RB对应的衰落值清零
        end
    end
end

%% 初始化功率
% 初始化功率分配(在所有N_RB个RB中平均分配总功率，即每个RB上的功率相同)
for n_=1:N_RB
    for b_=1:number_of_bts
        if eNodeBs(b_).RB(n_)~=0
%             average_power = max_power_per_sector/N_RB;
%             eNodeBs(b_).P(n_) = average_power;  % v6中，初始功率设置为最小功率
% 
            eNodeBs(b_).P(n_) = min_power_per_RB;  % v6中，初始功率设置为最小功率
        else
            eNodeBs(b_).P(n_)=0;
        end
    end
end
%
%% 初始化干扰
for b_=1:number_of_bts
    eNodeBs(b_).I_noise = noise_density * RB_bandwidth;
end
%
end