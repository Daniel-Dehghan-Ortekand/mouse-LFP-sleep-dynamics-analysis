
% =========================================================================
% SCRIPT: Convert Spike Times to Binary Spike Trains During SWS Episodes
% SUBJECT: Mouse12-120807
% =========================================================================
% DESCRIPTION:
% Converts continuous spike time data (stored as a cell array) into a 
% binary spike train matrix restricted exclusively to Slow-Wave Sleep 
% (SWS) episodes. The script first determines the maximum spike count 
% across all cells to build a uniform matrix, then maps each spike time 
% to its nearest sample index in the full LFP recording. A logical mask 
% is applied to retain only the spikes occurring within predefined SWS 
% time windows, producing a binary matrix suitable for time-locked 
% analyses (e.g., Peri-Stimulus Time Histograms, firing rate calculations).
%
% INPUTS:
%   - Mouse12-120807.spikes.cellinfo.mat: Cell array of spike times for 
%     each recorded unit.
%   - SwsTime: A predefined matrix of start and stop times (in seconds) 
%     defining the SWS episodes of interest.
%   - thal_allchanel_Mouse12_120807.mat: Full continuous LFP recording 
%     (loaded via matfile for memory efficiency).
%
% OUTPUTS:
%   - SpikesSWS120807.mat: A binary matrix (ChCell x SWS_samples) where 
%     1 indicates a spike occurrence during an SWS episode.
%
% DEPENDENCIES:
%   - Custom/File Exchange function: nearestpoint (to map spike times to 
%     the nearest LFP sample index).
% =========================================================================

clc
clear all
Mouse12-120807.spikes.cellinfo.mat
CellNum = size(spikes.times ,2);
%choose the longest length for Cell array 
MaxLen = 0;
for j=1:CellNum
    if length(spikes.times{1,j})>MaxLen
        MaxLen = length((spikes.times{1,j}));
    end
end  

% exclude spikes times from cell array to a matrix
SpikesTimesAllCells = zeros(MaxLen,CellNum);
for i=1:CellNum
 SpikesTimesAllCells(1:length(spikes.times{:,i}),i) = cell2mat(spikes.times(:,i));
end 

%save data 
save    SpikesTimesAllCells120807.mat SpikesTimesAllCells]]></w:t></w:r></w:p><w:p><w:pPr><w:sectPr/></w:pPr></w:p><w:p><w:pPr><w:pStyle w:val="code"/></w:pPr><w:r><w:t><![CDATA[load    SpikesTimesAllCells120807.mat
%SWS times Episode 
SwsTime = [1639.3	1929.6
1986.9	2502
2602.6	3106.5
3539.9	4488.8
4613.5	4862
4908.3	5576.3
8877.7	9230.1
9249.4	9477.3
9518.3	9849.4
9954.1	10371
10394	10582
10632	10791
10893	11505
11505	11574
11714	12368
12487	12829
12934	13094
13109	13284
13305	13410
13501	13648
13688	13903
14076	14545
14574	14766
14803	14918
14969	15231
];

fs = 1250;]]></w:t></w:r></w:p><w:p><w:pPr><w:sectPr/></w:pPr></w:p><w:p><w:pPr><w:pStyle w:val="heading"/><w:jc w:val="left"/></w:pPr><w:r><w:t>main code</w:t></w:r></w:p><w:p><w:pPr><w:pStyle w:val="code"/></w:pPr><w:r><w:t><![CDATA[ChCell = size(SpikesTimesAllCells ,2);
SwsEpisodeNum = size(SwsTime,1);
% load thal_allchanel_Mouse12_120807.mat
mf = matfile("thal_allchanel_Mouse12_120807.mat");
all_size = size(mf,"thal_allchanel_Mouse12_120807_new", 1);
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

end
save SpikesSWS120807.mat spikes_sws
