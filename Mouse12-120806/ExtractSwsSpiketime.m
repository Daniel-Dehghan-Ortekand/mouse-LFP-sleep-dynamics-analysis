% =========================================================================
% SCRIPT: Convert Spike Times to Binary Spike Trains During SWS Episodes
% SUBJECT: Mouse12-120806
% =========================================================================
% DESCRIPTION:
% Converts continuous spike time data (stored as a matrix) into a binary 
% spike train matrix restricted exclusively to Slow-Wave Sleep (SWS) 
% episodes. The script maps each spike time to its nearest sample index 
% in the full LFP recording using the nearestpoint function. A logical 
% mask is then applied to retain only the spikes occurring within 
% predefined SWS time windows, producing a binary matrix suitable for 
% time-locked analyses (e.g., Peri-Stimulus Time Histograms, firing rate 
% calculations, and phase-locking analysis).
%
% INPUTS:
%   - SpikesTimesAllCells.mat: Matrix of continuous spike times for each 
%     recorded unit (Units x Spikes).
%   - SwsTime: A predefined matrix of start and stop times (in seconds) 
%     defining the SWS episodes of interest.
%   - thal_allchanel_Mouse12_120806_new_90.mat: Full continuous LFP 
%     recording (loaded via matfile for memory efficiency).
%
% OUTPUTS:
%   - SpikesSWS.mat: A binary matrix (ChCell x SWS_samples) where 1 
%     indicates a spike occurrence during an SWS episode.
%
% DEPENDENCIES:
%   - Custom/File Exchange function: nearestpoint (to map spike times to 
%     the nearest LFP sample index).
% =========================================================================

clc
clear 
close all

% load Mouse12-120806.spikes.cellinfo.mat
load    SpikesTimesAllCells.mat
%SWS times Episode 
SwsTime = [823.3	1015.1
1327.6	1559.7
3415.9	3899.3
4018.1	4650.6
4833.1	5379.7
5513.2	5527.3
5527.3	6038.1
6133.3	6688.2
9880.2	11424
11911	12632
12672	12818
12839	12927
13042	13791
13971	14761
14783	14900];


fs = 1250;
%%mai
ChCell = size(SpikesTimesAllCells ,2);
SwsEpisodeNum = size(SwsTime,1);

mf = matfile("thal_allchanel_Mouse12_120806_new_90.mat");
all_size = size(mf, "thal_allchanel_Mouse12_120806_new", 1);
all_time = (0:all_size-1)/fs;

SWS_ind = false(1, all_size);
for i=1:SwsEpisodeNum
    start_sample = round(SwsTime(i,1)*fs);
    stop_sample = round(SwsTime(i,2)*fs);
    SWS_ind(start_sample:stop_sample) = 1;
end

spikes_sws = false(ChCell, sum(SWS_ind));
for i=1:ChCell
    ind = nearestpoint(SpikesTimesAllCells(:,i), all_time);
    s = false(1, all_size);
    s(ind) = 1;

    spikes_sws(i, :) = s(SWS_ind);


save SpikesSWS.mat spikes_sws
