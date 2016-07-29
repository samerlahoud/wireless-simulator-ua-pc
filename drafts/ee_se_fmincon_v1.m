I=4;
J=2;
K=15;
W=15000;
N_0=10^(-4);
G=1;

theta = cell(I, J, K);
for i = 1:I
    for j = 1:J
        for k = 1:K
            theta{i,j,k} = sprintf('theta%d%d%d',i,j,k);
        end
    end
end
theta = sym(theta, 'real');

syms tx_power p;
for i=1:J*K
    tx_power(i)=sprintf('p(%d)',i);
end

% pi = cell(J+K);
% for j=1:J
%     for k=1:K
%         pi{j,k} = sprintf('pi%d%d',j,k);
%     end
% end
% pi = sym(pi, 'real');

% j,k=> 1..k 1..k => (j-1)*K+k

spectral_eff=0;
for i=1:I
    for j=1:J
        for k=1:K
            theta_p = 0;
            pi_p = 0;
            %             for i_p=1:I
            %                  if i_p == i
            %                      continue
            %                  else
            %                      theta_p = theta_p + theta(i,j,k);
            %                  end
            %              end
            for j_p=1:J
                if j_p == j
                    continue
                else
                    pi_p = pi_p + exp(tx_power((j_p-1)*K+k))*G;
                end
            end
            %             f = f+ W*(theta(i,j,k)/(1+theta_p))*log(1+(pi(j,k)*G)/(N_0+pi_p));
            spectral_eff = spectral_eff - log(exp(tx_power((j-1)*K+k))*G/(N_0+pi_p));
        end
    end
end
spectral_eff=inline(char(spectral_eff),'p');

option=optimset('display','off','largescale','on');
% Consider a starting point where the power ratio equals 1 for all cells
% The lower bound is equal to 0.0001 to avoid numerical instabilities
[rb_optimal_power] = fmincon(spectral_eff,ones(1,J*K),[],[],[],[],ones(1,J*K).*0.0001,5.*ones(1,J*K),[],option);


