classdef eNodebSignaling <handle
% Represents the signaling from the eNodeB to each UE.
%
% (c) Josep Colom Ikuno, INTHFT, 2008

   properties
       TB_CQI           % CQI used for the transmission of each codeword
       TB_size          % size of the current TB, in bits
       N_used_bits = 0;
       packet_parts = [];
       num_assigned_RBs % Number of assigned RBs 
       assigned_RB_map  % Indicates the RBs of this specific UE
       assigned_power   % Indicates the total power assigned to this UE this TTI
       
       tx_mode          % Transmission mode used (SISO, tx diversity, spatial multiplexing)
       nLayers          % Number of layers for this transmission
       nCodewords       % How many codewords are being sent
       
       rv_idx           % Redundancy version index (HARQ) for each codeword
       genie_TB_SINR    % Estimated TB SINR as calculated by the eNodeB
       
       % Other signaling, such as cross-layer, could be placed here
       adaptive_RI      % Carrier information necessary for the adaptive RI algorithm
       non_CB_precoding % When the PMI in the RB grid object is set to -1, the precoding is understood to be not
                        % from a codebook. It should then be stored (and read) from here
   end

   methods
       function [...
               TB_CQI,...
               user_RBs,...
               assigned_RBs,...
               assigned_power,...
               tx_mode,...
               nLayers,...
               nCodewords,...
               rv_idxs,...
               TB_size,...
               N_used_bits,...
               packet_parts...
               ] = get_TB_params(obj)
           
           TB_CQI         = obj.TB_CQI;
           user_RBs       = obj.assigned_RB_map;
           assigned_RBs   = obj.num_assigned_RBs;
           assigned_power = obj.assigned_power;
           tx_mode        = obj.tx_mode;
           nLayers        = obj.nLayers;
           nCodewords     = obj.nCodewords;
           rv_idxs        = obj.rv_idx;
           TB_size        = obj.TB_size;
           
           % Needed for non-full-buffer simulations
           N_used_bits    = obj.N_used_bits;
           packet_parts   = obj.packet_parts;
       end
   end
end 
