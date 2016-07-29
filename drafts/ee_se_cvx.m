% Maximize spectral efficiency in a downlink LTE multi-cell network
% Centralized approach

% problem constants
I = 5;                 % number of users
K = 5;                  % number of resource blocks
J = 5;                  % number of Base stations
N0 = 10^(-13);        % AWGN noise density (W/Hz)
P_min = zeros(J,K);      % minimum power at the transmitter
P_max = 5*ones(J,K);     % maximum power at the transmitter

% path gain matrix: line=j, column=k
G = [1.0  0.1  0.2  0.1  0.3
     0.1  1.0  0.1  0.1  0.4
     0.2  0.1  2.0  0.2  0.2
     0.1  0.1  0.2  1.0  0.1
     0.2  0.4  0.2  0.1  1.0];

% variables are power levels
cvx_begin
  variable pow(J,K)
  expression interf(J,K)
  expression objective
  
  for k=1:K
      for j=1:J
          interf_mask = eye(J,J);
          interf_mask(j,j) = 0;
          interf(j,k) = exp(pow(:,k))'*interf_mask*G(:,k);
      end
  end
  for k=1:K
      for j=1:J
          objective = objective + log((exp(pow(j,k))'*G(j,k))/(N0 + interf(j,k)));
      end
  end
  maximize(objective)
  
  subject to
    % constraints are power limits
    P_min <= exp(pow) <= P_max; 
cvx_end

fprintf(1,'\nThe minimum total transmitter power is %3.2f.\n',cvx_optval);
disp('Optimal power levels are: '), exp(pow)
