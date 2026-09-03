% =========================================================================
% FUNCTION: ShortAndBigDurationComputation (Recommended: compute_so_duration_by_amplitude_class)
% =========================================================================
% DESCRIPTION:
% Computes the duration of Slow Oscillations (SOs) categorized into "Big" 
% and "Short" groups based on a secondary-to-primary peak amplitude ratio 
% threshold (0.5). It extracts 1-second LFP windows around the classified 
% SO peaks, pastes them into new continuous arrays, re-runs the SOMolle 
% detection algorithm on these arrays, and calculates the duration of the 
% newly detected SOs by measuring the distance between their start and end 
% indices.
%
% INPUTS:
%   - refsamp                   : Array of sample indices for all detected SO peaks.
%   - fs                        : Sampling frequency (Hz).
%   - ratio                     : Array of peak amplitude ratios for all SOs.
%   - ref                       : Index of the reference channel.
%   - thal_ch_norm_filtered_so  : Matrix of filtered LFP data (Channels x Time).
%
% OUTPUTS:
%   - durationBig               : Array of durations (in samples) for "Big" SOs.
%   - durationShort             : Array of durations (in samples) for "Short" SOs.
%
% DEPENDENCIES:
%   - Custom function: SOMolle (for SO detection).
% =========================================================================

function [durationBig, durationShort] = ShortAndBIgDurationComputation(refsamp,fs,ratio,ref,thal_ch_norm_filtered_so) 
sampBack = fs/2;
sampForward=fs/2;
BiggerThanthreshold = find(ratio > 0.5);
ShorterThanthreshold = find (ratio <= 0.5);
refsampBig= refsamp(BiggerThanthreshold);
refsampShort= refsamp(ShorterThanthreshold);
signalBig = zeros(1,length(thal_ch_norm_filtered_so(ref,:)));
signalshort = zeros(1,length(thal_ch_norm_filtered_so(ref,:)));
    %  for bigger than threshold
    
    for i=1:size(BiggerThanthreshold, 2)
        Sback = refsampBig(1,i)-sampBack;
        Sforward = refsampBig(1,i)+sampForward;
        sample = Sback:Sforward;
        signalBig(1,sample)= thal_ch_norm_filtered_so(ref, sample);
    end
        %for shorter than threshold
    for j=1:size(ShorterThanthreshold, 2)
        Sback = refsampShort(1,j)-sampBack;
        Sforward = refsampShort(1,j)+sampForward;
        sample = Sback:Sforward;
        signalshort(1,sample)= thal_ch_norm_filtered_so(ref, sample);
    end
    [ybig,~]  = SOMolle(signalBig(1,:));
    YBig = ybig(1,:);
%     ISBLIPEBig = IsBlipBig(1,:);
    
    
    diffBig = diff(YBig);
    start_indicesBig = find(diffBig==1);
    end_indicesBig = find(diffBig==-1);
    durationBig = end_indicesBig - start_indicesBig;
    % detection for shorter 
    
    [yshort,~]  = SOMolle(signalshort(1,:));
    Yshort = yshort;
%     ISBLIPEShort = IsBlipshort;
    
    diffShort = diff(Yshort);
    start_indicesShort = find(diffShort == 1);
    end_indicesShort = find(diffShort == -1);
    durationShort = end_indicesShort - start_indicesShort ;

end 
