% =========================================================================
% SCRIPT: Analyze Neural Activity Time-Locked to Slow Oscillations (SWS)
% SUBJECT: Mouse12-120807
% =========================================================================
% DESCRIPTION:
% This script analyzes Local Field Potential (LFP) and spike train data 
% during Slow-Wave Sleep (SWS). It aligns neural activity to detected 
% Slow Oscillations (SOs) to compute the average SO waveform, generate 
% a spike raster plot, and calculate a smoothed peri-event firing rate.
%
% INPUTS:
%   - SpikesSWS.mat: Spike data during slow-wave sleep.
%   - SwsIncludeOneChannelOfEachChannels.mat: LFP data (variable: sws).
%   - SOdetectedForChooseOneChannelFromEachShank.mat: Detected SO events.
%
% OUTPUTS:
%   - A 3-panel figure displaying:
%       1. Mean raw LFP waveform around SOs.
%       2. Spike raster plot of all cells aligned to SOs.
%       3. Smoothed population firing rate (Hz) around SOs.
%
% DEPENDENCIES:
%   - Requires custom function: SpikeRaster(data, fs, timeLimits)
% =========================================================================

clc 
%close all
clear
changeCurrentFolder('D:\daniel\Mouse12-120807')
%%
load SpikesSWS.mat
load SwsIncludeOneChannelOfEachChannels.mat
load SOdetectedForChooseOneChannelFromEachShank.mat 

%%

fs = 1250;
winSize = 0.5;
smoothSize = round(0.05*fs);
winSample = (-round(winSize*fs):round(winSize*fs));
soSample = find(SOdetected.ISBLIPE  (1,:) == 1);
spikeData = spikes_sws(1:7,:);
soSample(soSample < round(winSize*fs) | soSample > length(sws)-round(winSize*fs)) = [];

dataFiltered = zeros(1, length(winSample));
% dataRaw = zeros(1, length(winSample));
data_raster = zeros(length(soSample), length(winSample));

for i=1:length(soSample)
    dataFiltered = dataFiltered + sws(1, soSample(i)+winSample)/length(soSample);
%     dataRaw = dataRaw + zscore(cortexLfp(1, soSample(i)+winSample))/length(soSample);
    data_raster(i,:) = spikeData(soSample(i)+winSample);
end

firingRate = mean(data_raster,1)*fs;
firingRate = conv(firingRate, gausswin(smoothSize)/smoothSize, "same");

t = winSample/fs;

figure
title ('Mouse12-120806 ','Color','white')
subplot(3, 1, 1)
plot(t, dataFiltered,'Color','g',LineWidth=2)
title (' mean raw data around SOs for Mouse12-120807 ','Color','white')
ylabel('Amp.')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
subplot(3, 1, 2)
SpikeRaster(data_raster, fs, [-winSize winSize]);
title (' raster plot of all cells for Mouse12-120807 ','Color','white')
ylabel('Trials')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
subplot(3, 1, 3)
area(t, firingRate,'FaceColor','yellow','EdgeColor','white')
title (' Firing rate for Mouse12-120807 ','Color','white')
ylabel('FR (spike/sec)')
xlabel('Time (s)')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
