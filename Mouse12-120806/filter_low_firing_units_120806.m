% =========================================================================
% SCRIPT: Filter Low-Firing Units from Spike Train Data
% SUBJECT: Mouse12-120806
% =========================================================================
% DESCRIPTION:
% Loads the binary spike train matrix for Slow-Wave Sleep (SWS) and 
% calculates the overall firing rate for each recorded unit. It identifies 
% and removes units with a firing rate below 0.5 Hz (silent or very 
% low-firing cells) to ensure only active neurons are included in 
% subsequent time-locked and population analyses.
%
% INPUTS:
%   - SpikesSWS120806.mat: Binary spike train matrix (Units x Time) 
%     during SWS episodes.
%
% OUTPUTS:
%   - Overwrites the `spikes_sws` variable in the workspace with the 
%     filtered matrix, retaining only units with a firing rate >= 0.5 Hz.
% =========================================================================

load SpikesSWS120806.mat
fs=1250;
temp = [];
for i=1:size(spikes_sws,1)
    sp = find(spikes_sws(i,:)==1);
    FR = length(sp)/(length(spikes_sws(i,:))/fs);
    if FR<0.5
        temp = [temp i];
    end
end
spikes_sws(temp,:)=[];
