function sys_eq = ua_nash_equations(theta,peak_rate)
% How to use
% x0 = ones(30,63)*0.1;
% f = @(theta) nash_equations(theta,peak_rate);
% qrt = fsolve(f,x0)

global netconfig;
nb_users = netconfig.nb_users;
nb_BSs = netconfig.nb_BSs;

sys_eq = zeros(1,nb_users*(nb_BSs+1));

iter = 1;
% for u = 1:nb_users
%     for b = 1:nb_BSs
%         if peak_rate(u,b) >= 1e-4
%             sys_eq(iter) = log(peak_rate(u,b)/sum(theta(:,b),1))-(theta(u,b)/sum(theta(:,b),1));
%             y_tmp = 0;
%             for b_prime = 1:nb_BSs
%                 if b_prime ~= b && peak_rate(u,b_prime) >= 1e-4
%                     y_tmp = y_tmp + log(peak_rate(u,b_prime)/sum(theta(:,b_prime),1))-(theta(u,b_prime)/sum(theta(:,b_prime),1));
%                 end
%             end
%             sys_eq(iter) = sys_eq(iter) - y_tmp;
%         end
%         iter = iter + 1;
%     end
% end

for u = 1:nb_users
    for b = 1:nb_BSs
        if peak_rate(u,b) >= 1e-4 && sum(theta(:,b),1) >= 1e-3
            sys_eq(iter) = log(peak_rate(u,b)/sum(theta(:,b),1))-(theta(u,b)/sum(theta(:,b),1));
        elseif peak_rate(u,b) <= 1e-4
            sys_eq(iter) = theta(u,b);
        end
        iter = iter + 1;
    end
end

for u = 1:nb_users
    sys_eq(iter) = sum(theta(u,:),2) - 1; 
    iter = iter + 1;
end
end