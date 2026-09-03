% =========================================================================
% SCRIPT: Load Raw EEG and Segment Slow-Wave Sleep (SWS) Episodes
% SUBJECT: Mouse12-120807
% =========================================================================
% DESCRIPTION:
% Loads continuous 90-channel raw EEG data from a binary file, converts 
% it to a double-precision matrix, and segments the recording into 
% discrete Slow-Wave Sleep (SWS) episodes. It uses a predefined matrix 
% of start and stop times to create a logical temporal mask, extracting 
% only the relevant SWS data for downstream analysis while discarding 
% wake/other sleep stages.
%
% INPUTS:
%   - Mouse12-120807.eeg: Raw binary EEG recording file.
%   - SwsTime: A predefined matrix of start and stop times (in seconds) 
%     defining the SWS episodes of interest.
%
% OUTPUTS:
%   - thal_allchanel_Mouse12_120807.mat: The full loaded raw EEG data.
%   - SWS_episode120807.mat: A matrix containing only the concatenated 
%     SWS episode data across all 90 channels.
%   - Sws_Time_120807.mat: The timeline matrix used for segmentation.
%
% DEPENDENCIES:
%   - Custom function: bz_LoadBinary (for reading the raw .eeg file).
% =========================================================================

clear 
clc
close all
changeCurrentFolder('D:\daniel\Mouse12-120807')
%% read the .EEG file and save all channel

thal_allchanel_Mouse12_120807_new = bz_LoadBinary('Mouse12-120807.eeg','nChannels',90,'frequency',1250);
fs=1250;
save thal_allchanel_Mouse12_120807.mat -v7.3
OriginalData = thal_allchanel_Mouse12_120807_new;
%% creat NREM EPISOD

% load thal_allchanel_Mouse12_120806_new_90.mat
ch_number=90;
OriginalData=transpose(OriginalData);
OriginalData=double(OriginalData);

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

SWSpacket_num = size(SwsTime,1);


SWS_ind = false(1, length(OriginalData));
for i=1:SWSpacket_num
%     start_sample = round(sws(i,1)*fs);
%     stop_sample = round(sws(i,2)*fs);
    start_time = round(SwsTime(i,1)*fs);
    stop_time = round(SwsTime(i,2)*fs);
    SWS_ind(start_time:stop_time) = 1;
end
SWS_episode = OriginalData(:,SWS_ind);

save SWS_episode120807.mat  SWS_episode -v7.3
save Sws_Time_120807  SwsTime
