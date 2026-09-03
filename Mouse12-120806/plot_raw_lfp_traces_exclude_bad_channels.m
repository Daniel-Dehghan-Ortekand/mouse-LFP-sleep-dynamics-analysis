% =========================================================================
% SCRIPT: Visualize Continuous Raw LFP Traces (Excluding Bad Channels)
% SUBJECT: Multi-channel SWS Recording
% =========================================================================
% DESCRIPTION:
% Loads continuous Slow-Wave Sleep (SWS) LFP data, excludes predefined 
% bad channels (18, 19, 20), and plots the z-scored raw LFP traces for 
% the remaining 61 channels. A vertical offset is applied to each channel 
% to allow for clear visual comparison of the raw waveforms across the 
% entire probe array.
%
% INPUTS:
%   - SWS_episode_new_90.mat: Raw multi-channel SWS LFP data.
%
% OUTPUTS:
%   - Visualizations: Continuous z-scored raw LFP traces for 61 channels 
%     with vertical offsets.
% =========================================================================

clc 
clear 
close all
load SWS_episode_new_90.mat
%%

k= [18 19 20];
SWS_episode = SWS_episode(1:64,:);
data = SWS_episode;
for i=k
    SWS_episode(i,:) =[] ;
end 
ch_number = 61;
fs=1250;

t=( 1:length(SWS_episode(i,:)))/fs;
% t = (1:1000)/fs;
figure
hold on 
for i=1:ch_number
    plot(t,zscore(SWS_episode(i,:))+(7*i))
end

