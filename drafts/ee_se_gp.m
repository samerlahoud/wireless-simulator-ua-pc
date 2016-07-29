% Maximize spectral efficiency in a downlink multi-cell network
% Centralized approach

% problem constants
K = 5;                      % number of resource blocks
J = 7;                      % number of Base stations
I = 20;                     % number of users
N0 = 10^(-13);              % AWGN noise density (W/Hz)
P_min = 0.1*ones(J,K);      % minimum power at the transmitter
P_max = 10*ones(J,K);       % maximum power at the transmitter

% User indexes per BS
I_bs = cell(J);
I_bs{1} = [1 2 3 4 5 6 7 8];
I_bs{2} = [9 10];
I_bs{3} = [11 12 13];
I_bs{4} = [14 15];
I_bs{5} = [16 17];
I_bs{6} = [18 19];
I_bs{7} = [20];

% path gain matrix
G = ones(I,J,K)*10^(-2);

% Geometric programming formulation of the problem
cvx_begin gp
% variables are power levels
  variable pow(J,K)
  expression intf(J,K)
  expression objective
  for j=1:J
      for i=I_bs{j}
          for k=1:K
              intf_mask = eye(J,J);
              intf_mask(j,j) = 0;
              intf(i,j,k) = pow(:,k)'*intf_mask*G(i,:,k)';
          end
      end
  end
  for j=1:J
      for i=I_bs{j}
          for k=1:K
              objective = objective + log((pow(j,k)*G(i,j,k))/(N0 + intf(i,j,k)));
          end
      end
  end
  maximize(objective)
  
  subject to
  % constraints are power limits
  P_min <= pow <= P_max;
 sum(pow) <= 30;
  for j=1:J
      for i=I_bs{j}
          for k=1:K
              (pow(j,k)*G(i,j,k))/(N0 + intf(i,j,k)) >= 0.1;
          end
      end
  end
cvx_end

fprintf(1,'\nThe minimum total transmitter power is %3.2f.\n',cvx_optval);
disp('Optimal power levels are: '), pow
