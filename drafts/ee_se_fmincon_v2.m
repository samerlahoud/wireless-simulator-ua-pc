% Number of users
I=10;

% Number of BSs
J=2;

% Number of RBs
K=5;

% Noise power
N_0=10^(-4);

% Path gain
G=ones(I,J,K)+2.*rand(I,J,K);

syms tx_power p;
for i=1:J*K
    tx_power(i)=sprintf('p(%d)',i);
end

% j,k=> 1..k 1..k => (j-1)*K+k
spectral_eff=0;
for i=1:I
    for j=1:J
        for k=1:K
            pi_p = 0;
            for j_p=1:J
                if j_p == j
                    continue
                else
                    pi_p = pi_p + exp(tx_power((j_p-1)*K+k))*G(i,j_p,k);
                end
            end
            spectral_eff = spectral_eff - log(exp(tx_power((j-1)*K+k))*G(i,j,k)/(N_0+pi_p));
        end
    end
end
spectral_eff=inline(char(spectral_eff),'p');

option=optimset('Display','on','Algorithm','interior-point');
% Consider a starting point where the power ratio equals 1 for all cells
% The lower bound is equal to 0.0001 to avoid numerical instabilities
[rb_optimal_power] = fmincon(spectral_eff,5.*ones(1,J*K),[],[],[],[],ones(1,J*K),5.*ones(1,J*K),[],option);
%disp(rb_optimal_power)
matFilename = sprintf('./results.mat');
save(matFilename,'rb_optimal_power');
