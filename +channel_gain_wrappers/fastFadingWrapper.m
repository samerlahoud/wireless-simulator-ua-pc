classdef fastFadingWrapper < handle
% Wraps a trace of pregenerated fast fading coefficients
% (c) Josep Colom Ikuno, INTHFT, 2008

   properties
       ff_trace
       starting_point
       interfering_starting_points
   end

   methods
       % Class constructor. num_eNodeBs and num_sectors are used to add a
       % correct number of interferers (one per eNodeBs and sector)
       function obj = fastFadingWrapper(pregenerated_ff,starting_point,num_eNodeBs)
           switch starting_point
               case 'random'
                   start_point_t             = rand * pregenerated_ff.trace_length_s;
                   interferer_start_points_t = rand(1,num_eNodeBs) * pregenerated_ff.trace_length_s;
                   start_point_idx           = floor(start_point_t / pregenerated_ff.t_step) + 1;
                   start_points_idx_interf   = floor(interferer_start_points_t / pregenerated_ff.t_step) + 1;
               otherwise
                   error('Only a random starting point is now allowed');
           end
           obj.ff_trace = pregenerated_ff;
           obj.starting_point = start_point_idx;
           obj.interfering_starting_points = start_points_idx_interf;
       end
       
       function [zeta,chi,psi] = generate_fast_fading_signal(obj,t,tx_mode)
           % Index for the target and interfering channels
           [index_position_mod,~] = obj.get_index_positions(t,[]);
           
           switch tx_mode
               case 1
                   % SISO trace
                   zeta  = obj.ff_trace.traces{1}.trace.zeta(:,index_position_mod);
                   chi   = [];
                   psi   = obj.ff_trace.traces{1}.trace.psi(:,index_position_mod);
               case 2
                   % TxD trace
                   zeta  = obj.ff_trace.traces{2}.trace.zeta(:,:,index_position_mod);
                   chi   = obj.ff_trace.traces{2}.trace.chi(:,:,index_position_mod);
                   psi   = obj.ff_trace.traces{2}.trace.psi(:,:,index_position_mod);
               case {3,4}
                   % OLSM and CLSM trace
                   tmp_trace = obj.ff_trace.traces{tx_mode};
                   size_psi  = size(tmp_trace{end}.trace.psi);
                   max_rank  = length(tmp_trace);
                   zeta  = zeros([size_psi(1) size_psi(2) max_rank]);
                   chi   = zeros([size_psi(1) size_psi(2) max_rank]);
                   psi   = zeros([size_psi(1) size_psi(2) max_rank]);
                   for rank_idx = 1:max_rank % trace for each rank
                       current_trace = tmp_trace{rank_idx}.trace;
                       if ~isempty(current_trace.zeta)
                           zeta(1:rank_idx,:,rank_idx) = current_trace.zeta(:,:,index_position_mod);
                       else
                           zeta(1:rank_idx,:,rank_idx) = 1;
                       end
                       if ~isempty(current_trace.chi)
                           chi(1:rank_idx,:,rank_idx) = current_trace.chi(:,:,index_position_mod);
                       else
                           chi(1:rank_idx,:,rank_idx) = 0;
                       end
                       psi(1:rank_idx,:,rank_idx)     = current_trace.psi(:,:,index_position_mod);
                   end
               otherwise
                   error('tx_mode %d not yet implemented',tx_mode);
           end
       end
       
       function [theta] = generate_fast_fading_interference(obj,t,tx_mode,interfering_eNodeB_ids)
           % Index for the target and interfering channels
           [~,index_position_interf_mod] = obj.get_index_positions(t,interfering_eNodeB_ids);
           
           switch tx_mode
               case 1
                   % SISO trace
                   theta = obj.ff_trace.traces{1}.trace.theta(:,index_position_interf_mod).';
               case 2
                   % TxD trace
                   theta = obj.ff_trace.traces{2}.trace.theta(:,:,index_position_interf_mod);
               case {3,4}
                   % OLSM and CLSM trace
                   tmp_trace = obj.ff_trace.traces{tx_mode};
                   size_psi  = size(tmp_trace{end}.trace.psi);
                   max_rank  = length(tmp_trace);
                   theta = zeros([size_psi(1) size_psi(2) numel(index_position_interf_mod) max_rank]);
                   for rank_idx = 1:max_rank % trace for each rank
                       current_trace = tmp_trace{rank_idx}.trace;
                       theta(1:rank_idx,:,:,rank_idx) = current_trace.theta(:,:,index_position_interf_mod);
                   end
               otherwise
                   error('tx_mode %d not yet implemented',tx_mode);
           end
       end
       
       % Version for the run-time precoding. Returns the appropriate
       % channel matrix coefficients (H)
       function [H_0 H_i PMI_precalc] = generate_fast_fading_v2(obj,t,interfering_eNodeBs_idxs)
           % Index for the target and interfering channels
           [index_position_mod,index_position_interf_mod] = obj.get_index_positions(t,interfering_eNodeBs_idxs);
           
           % Set trace contents
           the_trace   = obj.ff_trace;
           H_0         = the_trace.H_0(:,:,:,index_position_mod);
           H_i         = the_trace.H_0(:,:,:,index_position_interf_mod);
           PMI_precalc = the_trace.PMI(:,:,index_position_mod);
       end
       
       function [index_position_mod, index_position_interf_mod] = get_index_positions(obj,t,interfering_eNodeB_ids)
           
           % Index for the target channel
           index_position            = floor(t/obj.ff_trace.t_step);
           index_position_plus_start = index_position + obj.starting_point;
           index_position_mod        = (mod(index_position_plus_start,obj.ff_trace.trace_length_samples))+1;
           
           % Get the indexes for the interfering channels
           if ~isempty(interfering_eNodeB_ids)
               index_position_plus_start_interf = index_position + obj.interfering_starting_points(interfering_eNodeB_ids);
               index_position_interf_mod        = (mod(index_position_plus_start_interf,obj.ff_trace.trace_length_samples))+1;
           else
               index_position_interf_mod        = [];
           end
       end
   end
end 
