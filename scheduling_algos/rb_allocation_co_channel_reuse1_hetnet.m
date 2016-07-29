function [RB_allocation] = rb_allocation_co_channel_reuse1_hetnet()
% Reuse 1 is applied on macro-cells and femtos for all spectrum

global netconfig;
nb_BSs = netconfig.nb_BSs;
nb_RBs = netconfig.nb_RBs;

RB_allocation = ones(nb_BSs,nb_RBs);
end