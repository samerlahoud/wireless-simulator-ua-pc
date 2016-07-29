% 
if ~(exist('results-compute-ee-8users-9sectors-15RBs-60W','var')==1)
    load('results-compute-ee-8users-9sectors-15RBs-60W.mat','netconfig','eta','ee_power_allocation_matrix');
end
N_RB = netconfig.nb_RBs;
bts  = 1;  

% energy_efficiency power
if ~(exist('results_trace_eNodeBs','var')==1)
    load('results_trace_eNodeBs.mat','trace','eNodeBs');
end
iteration = length(trace);
P_iteration  = zeros(iteration,N_RB);
ee_iteration = zeros(1,iteration);
ee_cvx_1 = ones(iteration,1);
ee_cvx_1 = ee_cvx_1.*eta;
for current_tti = 1:iteration
    ee_iteration(current_tti) = trace(current_tti).energy_efficiency;
    P_iteration(current_tti,:) = trace(current_tti).eNodeBs(bts).P;
end

ee_cvx = ones(1,iteration).*eta;
