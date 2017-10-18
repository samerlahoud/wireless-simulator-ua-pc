function [RB_allocation] = rb_allocation_reuse1_random_hetnet(femto_demand)
% Reuse 1 is applied on macro-cells 
% Random demand allocation on femtos

global netconfig;
nb_BSs = netconfig.nb_BSs;
nb_RBs = netconfig.nb_RBs;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_femto_BSs = netconfig.nb_femto_BSs;

nb_femto_RBs = netconfig.nb_femto_RBs;
nb_macro_RBs = nb_RBs - nb_femto_RBs;

macro_RB_allocation = ones(nb_macro_BSs, nb_macro_RBs);
femto_RB_allocation = zeros(nb_femto_BSs, nb_femto_RBs);

for f=1:nb_femto_BSs
    rand_RBs = randperm(nb_femto_RBs);
    femto_RB_allocation(f,rand_RBs(1:femto_demand(f))) = 1;
end

RB_allocation = [macro_RB_allocation,zeros(nb_macro_BSs,nb_femto_RBs);zeros(nb_femto_BSs,nb_macro_RBs),femto_RB_allocation];
end