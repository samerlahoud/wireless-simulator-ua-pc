%% result_analysis
load_results;

x = 1:iteration;
plot(x,ee_cvx,'-ko',x,ee_iteration,'-k*');
grid on
legend('ee cvx optimal value','ee iteration value',0)
title('compared with cvx optimal value')
xlabel('initial power value of descend orders of magnitude')
ylabel('system energy efficiency')
