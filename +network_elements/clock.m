classdef clock < handle
% This object represents a network-wide clock that all network elements
% share.
% (c) Josep Colom Ikuno, INTHFT, 2008

   properties
       current_TTI  % Current TTI (an integer)
       TTI_time     % How long does a TTI last (in seconds)
       time         % Actual time (seconds)
   end

   methods
       % Class constructor
       %   - Input
       function obj = clock(TTI_time)
           obj.current_TTI = 0;
           obj.time        = 0;
           obj.TTI_time    = TTI_time;
       end
       
       % Advances network TTI by one
       function advance_1_TTI(obj)
           obj.current_TTI = obj.current_TTI + 1;
           obj.time = obj.time + obj.TTI_time;
       end
   end
end 
