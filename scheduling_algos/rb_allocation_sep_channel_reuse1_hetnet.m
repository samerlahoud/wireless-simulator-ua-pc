function [RB_allocation] = rb_allocation_sep_channel_reuse1_hetnet()
% Reuse 1 is applied on macro-cells 
% Reuse 1 is applied on femtos on separate spectrum

global netconfig;
nb_BSs = netconfig.nb_BSs;
nb_RBs = netconfig.nb_RBs;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_femto_BSs = netconfig.nb_femto_BSs;

% Separate channel does not use any information on user distribution
% RB dsitrubution is equal between femto and macro
nb_femto_RBs = nb_RBs/2;
nb_macro_RBs = nb_RBs/2;

macro_RB_allocation = ones(nb_macro_BSs, nb_macro_RBs);
femto_RB_allocation = ones(nb_femto_BSs, nb_femto_RBs);

RB_allocation = [macro_RB_allocation,zeros(nb_macro_BSs,nb_femto_RBs);zeros(nb_femto_BSs,nb_macro_RBs),femto_RB_allocation];
end