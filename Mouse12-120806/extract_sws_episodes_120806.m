

% =========================================================================
% SCRIPT: Load Raw EEG and Segment Slow-Wave Sleep (SWS) Episodes
% SUBJECT: Mouse12-120806
% =========================================================================
% DESCRIPTION:
% Loads continuous 90-channel raw EEG data from a .mat file, transposes 
% it, and converts it to double precision. It then segments the recording 
% into discrete Slow-Wave Sleep (SWS) episodes using a predefined matrix 
% of start and stop times (in seconds). A logical temporal mask is applied 
% to extract only the relevant SWS data across all channels for downstream 
% analysis.
%
% INPUTS:
%   - thal_allchanel_Mouse12_120806_new_90.mat: Raw continuous multi-channel 
%     EEG recording.
%   - SwsTime: A predefined matrix of start and stop times (in seconds) 
%     defining the SWS episodes of interest.
%
% OUTPUTS:
%   - SWS_episode_new_90.mat: A matrix containing only the concatenated 
%     SWS episode data across all 90 channels.
% =========================================================================

%% Zero step
clc 
clear 
close all
load thal_allchanel_Mouse12_120806_new_90.mat
% load sws.mat
fs=1250;
ch_number=90;
thal_allchanel_Mouse12_120806=transpose(thal_allchanel_Mouse12_120806_new);
thal_allchanel_Mouse12_120806=double(thal_allchanel_Mouse12_120806);

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

SWSpacket_num = size(SwsTime,1);

 %% creat NREM EPISOD
% NREM_episode=[];
% for i=1:NREMpacket_num
%     start_sample=NREMstate(i,1)*fs;
%     stop_sample=NREMstate(i,2)*fs;
%     for j=1:ch_number
%         NREM_episode(j,:)=[NREM_episode(j,:) thal_allchanel_Mouse12_120806(j,start_sample:stop_sample)]
%     end 
% end
% save NREM_episode.mat  NREM_episode -v7.3
%% 
% NREM_episode=[];
% for i=1:ch_number
%     for j=1:NREMpacket_num
%         start_sample=NREMstate(j,1)*fs;
%         stop_sample=NREMstate(j,2)*fs;
%         NREM_episode(i,:)=[NREM_episode thal_allchanel_Mouse12_120806(i,start_sample:stop_sample)];
% 
%     end 
% end 

%% creat NREM EPISOD
SWS_ind = false(1, length(thal_allchanel_Mouse12_120806));
for i=1:SWSpacket_num
%     start_sample = round(sws(i,1)*fs);
%     stop_sample = round(sws(i,2)*fs);
    start_time = round(SwsTime(i,1)*fs);
    stop_time = round(SwsTime(i,2)*fs);
    SWS_ind(start_time:stop_time) = 1;
end
SWS_episode = thal_allchanel_Mouse12_120806(:,SWS_ind);

save SWS_episode_new_90.mat  SWS_episode -v7.3
