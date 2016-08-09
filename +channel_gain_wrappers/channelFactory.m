classdef channelFactory < handle
    % contains a couple of routines needed for both PDP- and Winner-based chanel models.
    % (c) Josep Colom Ikuno, INTHFT, 2011
    
    properties
        bandwidth
        subcarrierSpacing = 15e3;  % By default
        tSubframe         = 1e-3;  % Subframe time
        resourceBlock     = 180e3; % Fixed badwidth of resource block in Hz, page 33
        Nsc                        % number of subcarriers in one resource block, fixed length of resource block in Hz, page 33
        Nrb                        % number of resource blocks, transmission BW is 90% of the total BW unless for 1.4 MHz
        Ntot                       % Total number of subcarriers not NULL
        Nfft                       % number of FFT points
        Tb                         % useful Symbol Time
        fs                         % Sampling frequency
        FFT_sampling_interval = 6; % Sampling interval in the frequency domain when getting RB FFT traces
    end
    
    methods (Abstract)
        generate_FF_trace(obj,N_subframes);
    end
    
    methods
        function obj = channelFactory(bandwidth)
            obj.bandwidth = bandwidth;
            obj.Nsc       = obj.resourceBlock/obj.subcarrierSpacing;
            
            if(obj.bandwidth == 1.4e6)
                obj.Nrb = 6;
            else
                obj.Nrb = (obj.bandwidth*0.9) / obj.resourceBlock;
            end
            obj.Ntot = obj.Nsc*obj.Nrb;
            if(obj.bandwidth == 15e6 && obj.subcarrierSpacing == 15e3)
                obj.Nfft = 1536;
            elseif(obj.bandwidth == 15e6 && obj.subcarrierSpacing == 7.5e3)
                obj.Nfft = 1536*2;
            else
                obj.Nfft =  2^ceil(log2(obj.Ntot));
            end
            obj.Tb = 1/obj.subcarrierSpacing;
            obj.fs = obj.subcarrierSpacing*obj.Nfft;
        end
        
        function H_fft_RB = get_RB_trace(obj,channel)
            % Returns back a frequency channel trace jumping each FFT_sampling_interval subcarriers
            H_fft_large = fft(channel,obj.Nfft,4);
            % Eliminate guardband
            H_fft       = H_fft_large(:,:,:,[obj.Nfft-obj.Ntot/2+1:obj.Nfft 2:obj.Ntot/2+1]);
            % Do not return the channel for all subcarriers, but just a subset of it
            H_fft_RB    = H_fft(:,:,:,1:obj.FFT_sampling_interval:end);
        end
    end
end

