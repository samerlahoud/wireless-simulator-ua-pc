classdef resourceBlockGrid < handle
% Represents the recource block grid that the scheduler must allocate every
% TTI. Frequency length will depend on the frequency bandwidth. Time length
% will always be 1 ms.
% The grids are organized in the following way:
%
% |<----frequency---->
%  ____ ____ ____ ____  ___
% |____|____|____|____|  |  time (2 subframes)
% |____|____|____|____| _|_
%
% Where the frequency width obviously depends on the allocated bandwidth
% and the time-dimension width is always 2. Access the grid in the
% following way (example for the user allocation):
%
% user_allocation(time_index,frequency_index);
%
% (c) Josep Colom Ikuno, INTHFT, 2008

   properties
       % whose slot is each
       user_allocation
       % how much power to allocate to each slot, in Watts
       power_allocation
       % equivalent, but for the signaling
       power_allocation_signaling
       % number of RB (freq domain)
       n_RB
       % number of symbols per Resource Block (RB), which is 12 subcarriers and 0.5 ms
       sym_per_RB_nosync
       sym_per_RB_sync
       % total size of the RB grid in bits
       size_bits

       PMI     % The PMI used here (RB-based). Set to NaN if no precoding needs to be specified. -1 means a specific precoding is set in the UE signaling
   end

   methods
       
       % Class constructor and initialisation. Initialise CQIs to 0
       function obj = resourceBlockGrid(n_RB,sym_per_RB_nosync,sym_per_RB_sync)
           max_codewords = 2;
           
           % "Dynamic" information
           obj.user_allocation  = zeros(n_RB,1,'uint16'); % We will assume that the streams cannot be scheduled to different UEs.
           obj.power_allocation = zeros(n_RB,1); % TTI-based power allocation. No slot-based power allocation
           obj.power_allocation_signaling = zeros(n_RB,1); % Simplification: equal for each RB
           obj.size_bits         = zeros(1,max_codewords);
           obj.PMI               = nan(n_RB,1,'single'); % so that I can use NaNs and the such also
           
           % "Static" information
           obj.n_RB              = n_RB;
           obj.sym_per_RB_nosync = sym_per_RB_nosync;
           obj.sym_per_RB_sync   = sym_per_RB_sync;
       end
       
       % Sets the power allocation to a default value. Useful for setting a homogeneous power allocation
       function set_homogeneous_power_allocation(obj,power_in_watts_data,power_in_watts_signaling)
           power_per_RB_data                 = power_in_watts_data / obj.n_RB;
           power_per_RB_signaling            = power_in_watts_signaling / obj.n_RB;
           obj.power_allocation(:)           = power_per_RB_data;
           obj.power_allocation_signaling(:) = power_per_RB_signaling;
       end
       
       % Returns how many RBs are non-zero-assigned (i.e. scheduled)
       function N_RB_used = scheduled_RBs(obj)
           N_RB_used = sum(obj.user_allocation~=0);
       end
       
       % Prints some info about this object
       function print(obj)
           fprintf('n_RB=%d\n',obj.n_RB);
       end
       
       % Returns a copy of this object containing the same information
       function cloned_RB_grid = clone(obj)
           % Create cloned object (fill in the "Static" information)
           cloned_RB_grid = network_elements.resourceBlockGrid(obj.n_RB,obj.sym_per_RB_nosync,obj.sym_per_RB_sync);
           
           % Fill in the "Dynamic" information
           cloned_RB_grid.user_allocation  = obj.user_allocation;
           cloned_RB_grid.power_allocation = obj.power_allocation;
           cloned_RB_grid.power_allocation_signaling = obj.power_allocation_signaling;
           cloned_RB_grid.size_bits        = obj.size_bits;
           cloned_RB_grid.PMI              = obj.PMI;
       end
   end
end 
