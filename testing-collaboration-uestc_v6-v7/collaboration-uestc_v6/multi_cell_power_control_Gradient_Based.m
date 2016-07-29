function [eNodeBs,UEs,delta_P] = multi_cell_power_control_Gradient_Based(eNodeBs,UEs,g,eta,delta_t,need_next_iteration)
% 
% multi-cell power control  
%
global netconfig;
N_RB                 = netconfig.nb_RBs;
UE_per_eNodeB        = netconfig.nb_users_per_sector;
min_power_per_RB     = netconfig.min_power_per_RB;   
max_power_per_sector = netconfig.max_power_per_sector;   
power_prop_coeff     = netconfig.power_prop_coeff; 

number_of_bts        = length(eNodeBs);
temp_gradient        = zeros(number_of_bts,N_RB);             % temporary variable
temp_sum             = zeros(length(UEs),N_RB,number_of_bts); 
temp_one             = zeros(UE_per_eNodeB,N_RB); 
temp_part_sum        = zeros(1,N_RB); 
eNodeBs_gradient     = zeros(1,N_RB);
delta_P              = zeros(number_of_bts,N_RB); % record the difference value compared to last tti
%
for j_=1:number_of_bts
    for i_=1:length(UEs)
        for u_=1:number_of_bts
            if u_~=j_
                temp_sum(i_,:,j_) = temp_sum(i_,:,j_)+(eNodeBs(u_).P).*g(i_,:,u_); 
            end
       end
    end
end
%
for j_=1:number_of_bts  
    for u_=1:number_of_bts 
        if u_~=j_
            temp_one(:,:) = (g(1+(u_-1)*UE_per_eNodeB:u_*UE_per_eNodeB,:,j_)./(temp_sum(1+(u_-1)*UE_per_eNodeB:u_*UE_per_eNodeB,:,u_)+eNodeBs(u_).I_noise)); 
            temp_part_sum = temp_part_sum + sum(temp_one);
        end
    end
    temp_gradient(j_,:) = temp_part_sum + eta*power_prop_coeff*ones(1,N_RB) - ones(1,N_RB)./eNodeBs(j_).P;   
    temp_part_sum    = zeros(1,N_RB);
end
%
for j_=1:number_of_bts
    if need_next_iteration(j_)~=0
        condition_one = sum(eNodeBs(j_).P) > max_power_per_sector;  
        condition_two = eNodeBs(j_).P < min_power_per_RB; 
    
        if condition_one
            eNodeBs_gradient = ones(1,N_RB);
        elseif sum(condition_two)
            eNodeBs_gradient = -1*condition_two;
        end
    
        for n_=1:N_RB
            if (eNodeBs_gradient(n_)~=1)&&(eNodeBs_gradient(n_)~=-1)
                eNodeBs_gradient(n_) = temp_gradient(j_,n_);
            end
        end
    
        eNodeBs(j_).gradient = eNodeBs_gradient;

        update_P = eNodeBs(j_).P - delta_t.*eNodeBs_gradient; % update the power allocated on each RB
        delta_P(j_,:) = abs(update_P - eNodeBs(j_).P);
        eNodeBs(j_).P = update_P;
    end
end
% 
end
