% =========================================================================
% SCRIPT: Visualize Raw LFP with Overlaid Spindle/SO Rasters and Zoomed Event Markers
% SUBJECT: Multi-channel SWS Recording
% =========================================================================
% DESCRIPTION:
% Loads continuous Slow-Wave Sleep (SWS) LFP data and generates two 
% complementary visualizations to verify event detection. 
% 1) A multi-channel raster plot showing the z-scored LFP for 64 channels 
%    over a 100-second window, with detected sleep spindles (black asterisks) 
%    and Slow Oscillations (red asterisks) overlaid at the baseline of each 
%    channel. 
% 2) A zoomed-in view of the raw LFP for two specific channels (1 and 12), 
%    explicitly marking the onset/offset of spindles and the timing of SOs 
%    directly on the continuous waveform.
%
% INPUTS:
%   - SWS_episode_new_90.mat: Raw multi-channel SWS LFP data.
%   - thal_spindles_ch[X].mat: Detected sleep spindle events per channel.
%   - thal_SO_ch[X].mat: Detected Slow Oscillation (SO) events per channel.
%
% OUTPUTS:
%   - Visualizations: 
%       1. 64-channel raster plot (0-100s) with event markers.
%       2. Zoomed-in continuous LFP plot for channels 1 and 12 with 
%          detailed event markers.
% =========================================================================

%% zero step
clc
clear
close all
ch_number=64;
fs=1250;
%load data
load('SWS_episode_new_90.mat')
%%  
time_range = [0 100];



figure
hold on 
SWS_episode_time = (1:length(SWS_episode))/1250;
time_ind = SWS_episode_time >= time_range(1) & SWS_episode_time <= time_range(2);

for i=1:ch_number
    plot (SWS_episode_time(time_ind), zscore(SWS_episode(i,time_ind))+7*i,'b')
    
    load(['thal_spindles_ch' num2str(i) '.mat'])
    sp_ind = thal_spindles(:,1) >= time_range(1) & thal_spindles(:,1) <= time_range(2);
    sp = thal_spindles(sp_ind,1);
    plot (sp, ones(1, length(sp))*7*i,'*k')
   
    load(['thal_SO_ch' num2str(i) '.mat'])
    so_ind = thal_SO(:,1) >= time_range(1) & thal_SO(:,1) <= time_range(2);
    so = thal_SO(so_ind,1);
    plot (so, ones(1, length(so))*7*i,'*r')
   
end 
%%
%load('SWS_episode_new_90.mat')
start_sample=1;
end_sample = 1000000;
fs=1250;
% new_SWS_episode = zeros (2 ,length (SWS_episode(1,:)));
% new_SWS_episode(1,:) = SWS_episode(2 ,:);
% new_SWS_episode(2,:) = SWS_episode (12,:);
   t1=(start_sample:end_sample)/fs;
SO_event=10;
spindle_event=10;
ch_num=[1,12];

%
figure
hold on 
for i = ch_num
    load(['thal_spindles_ch' num2str(i) '.mat'])
    load(['thal_SO_ch' num2str(i) '.mat'])
       SWS_episode_sample = zscore(SWS_episode(i,start_sample:end_sample));
plot (t1,SWS_episode_sample)
        for j=1:spindle_event

              plot(thal_spindles(j,1),SWS_episode_sample(round(thal_spindles(j,1)*fs)),'*r')
              plot(thal_spindles(j,3),SWS_episode_sample(round(thal_spindles(j,3)*fs)),'*m')

        end
        for j=1:SO_event
        plot(thal_SO(j,1),SWS_episode_sample(round(thal_SO(j,1)*fs)),'*g')
        plot(thal_SO(j,2),SWS_episode_sample(round(thal_SO(j,2)*fs)),'*k')
        end
end 
% SWS_episode_time = (1:length(new_SWS_episode))/1250;
% time_ind = SWS_episode_time >= time_range(1) & SWS_episode_time <= time_range(2);
% for i=1,12
%     plot (SWS_episode_time(time_ind), zscore(SWS_episode(i,time_ind))+7*i,'b')
%     
%     load(['thal_spindles_ch' num2str(i) '.mat'])
%     sp_ind = thal_spindles(:,1) >= time_range(1) & thal_spindles(:,1) <= time_range(2);
%     sp = thal_spindles(sp_ind,1);
%     plot (sp, ones(1, length(sp))*7*i,'*k')
%    
%     load(['thal_SO_ch' num2str(i) '.mat'])
%     so_ind = thal_SO(:,1) >= time_range(1) & thal_SO(:,1) <= time_range(2);
%     so = thal_SO(so_ind,1);
%     plot (so, ones(1, length(so))*7*i,'*r')
% end 
