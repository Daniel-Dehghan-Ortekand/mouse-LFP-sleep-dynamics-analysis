% =========================================================================
% SCRIPT: Spike Phase-Locking Analysis to Slow Oscillations (SOs)
% SUBJECT: Mouse12-120806
% =========================================================================
% DESCRIPTION:
% Computes and visualizes the phase-locking of multi-unit spikes to the 
% instantaneous phase of Slow Oscillations (SOs, 0.5-4 Hz) on a 
% representative thalamic channel. It calculates the phase at each spike 
% time using the Hilbert transform and generates polar histograms for all 
% spikes across multiple cells. Additionally, it isolates "Big" SO events 
% (defined by a secondary-to-primary peak amplitude ratio > 0.5) and 
% computes the phase-locking specifically for spikes occurring within a 
% 1-second window centered on these high-amplitude events.
%
% INPUTS:
%   - thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat: Filtered 
%     LFP data (0.5-4 Hz) for the reference channel.
%   - SpikesSWS.mat: Binary spike train data during SWS.
%   - SOreferenceChannelDelayAndRatio.mat: Precomputed peak amplitude ratios.
%   - SOdetectedForChooseOneChannelFromEachShank.mat: Detected SO peak times.
%
% OUTPUTS:
%   - Visualizations: Polar histograms (using circ_plot) showing the 
%     distribution of LFP phases at spike times for all events, and 
%     separately for "Big" SO events, for each recorded cell.
%
% DEPENDENCIES:
%   - Custom function: circ_plot (for polar histograms).
%   - MATLAB Signal Processing Toolbox: hilbert.
% =========================================================================

clc 
clear
% close all
changeCurrentFolder('D:\daniel\Mouse12-120806')

%% 
load thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat
load SpikesSWS.mat 
load SOreferenceChannelDelayAndRatio.mat
load SOdetectedForChooseOneChannelFromEachShank.mat

%% phase locking for all LFP
phLFP = angle(hilbert(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)));
cellnum = 7;
for i=1:cellnum
spikeSamp = transpose(find(spikes_sws(i,:) == 1));
alpha = phLFP(spikeSamp);
figure
circ_plot(alpha, 'hist', [], 20,true,true,'linewidth',2,'color','r')
title (['phase coupling for  cell = ' num2str(i)] ,'Color','k')
set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
end 
%% phase locking for big events 
cellnum = 7;
fs=1250;
win = fs/2;
BigEventNum = find(SOreferenceChannelDelayAndRatio.ratio > 0.5);
SO = transpose(find(SOdetected.ISBLIPE == 1));
BigEventSAmp = SO(BigEventNum);

for i=1:cellnum
    for j=1:size(BigEventNum(1,2))

    spikeSamp = transpose(find(spikes_sws(i,BigEventSAmp(1,j)-fs/2:BigEventSAmp(1,j)+fs/2) == 1));
    if spikeSamp ~= 0
    alphaBig(j,:) = phLFP(spikeSamp);
    else 
        continue
    end
    end  
    alpha=alphaBig(j,:);
    figure
    circ_plot(alpha(i,:), 'hist', [], 20,true,true,'linewidth',2,'color','r')
    title (['phase coupling base on Big events for  cell = ' num2str(i)] ,'Color','k')
    set(gca,'fontsize',16,'color',[1 1 1])
    set(groot, 'defaultFigureColor', [1 1 1]);
    set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
end
%%

