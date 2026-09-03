% =========================================================================
% SCRIPT: Visualize Raw LFP with Overlaid Spindle and Slow Oscillation Rasters
% SUBJECT: Multi-channel SWS Recording (61 Channels)
% =========================================================================
% DESCRIPTION:
% Loads continuous Slow-Wave Sleep (SWS) LFP data, excludes predefined 
% bad channels (42, 43, 44), and plots the z-scored raw LFP traces for 
% the remaining 61 channels. It then focuses on a specific 100-second 
% time window (0 to 100s) and overlays detected sleep spindles (black 
% asterisks) and Slow Oscillations (red asterisks) as raster plots on 
% their respective channels to visually verify detection accuracy and 
% temporal alignment.
%
% INPUTS:
%   - SWS_episode_new_90.mat: Raw multi-channel SWS LFP data.
%   - thal_spindles_ch[X].mat: Detected sleep spindle events per channel.
%   - thal_SO_ch[X].mat: Detected Slow Oscillation (SO) events per channel.
%
% OUTPUTS:
%   - Visualizations: 
%       1. Continuous z-scored raw LFP traces for 61 channels.
%       2. Zoomed-in view (0-100s) of the LFP traces with overlaid 
%          spindle and SO raster markers.
% =========================================================================

clc 
clear 
close all
load SWS_episode_new_90.mat
%%

k= [42 43 44];
SWS_episode = SWS_episode(1:64,:);
data = SWS_episode;
for i=k
    SWS_episode(i,:) =[] ;
end 
ch_number = 61;
fs=1250;

t=( 1:length(SWS_episode(i,:)))/fs;
% t = (1:1000)/fs;
hold on 
for i=1:ch_number
    plot(t,zscore(SWS_episode(i,:))+(7*i))
end

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
