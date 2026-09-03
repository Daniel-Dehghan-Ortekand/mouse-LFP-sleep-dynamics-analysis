
% =========================================================================
% SCRIPT: Spike-Triggered Average (STA) Analysis & LFP/Spike Visualization
% SUBJECT: Mouse12-120808
% =========================================================================
% DESCRIPTION:
% Computes and visualizes the Spike-Triggered Average (STA) of Local Field 
% Potential (LFP) signals time-locked to multi-unit spike trains during 
% Slow-Wave Sleep (SWS). It compares STAs derived from both raw and 
% filtered LFP data across multiple single units. Additionally, it 
% generates overlay plots of raw spikes, filtered LFP, and detected Slow 
% Oscillation (SO) events to verify signal alignment and quality.
%
% INPUTS:
%   - SWS_episode.mat: Raw multi-channel SWS LFP data.
%   - SpikesSWS.mat: Multi-unit spike train data during SWS.
%   - thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat: Filtered LFP.
%   - SOreferenceChannelDelayAndRatio.mat: SO reference channel data.
%   - SOdetectedForChooseOneChannelFromEachShank.mat: Detected SO events.
%
% OUTPUTS:
%   - Visualizations: 
%       1. Overlay of raw LFP, spikes, filtered LFP, and SO markers.
%       2. Individual and population-mean STAs (filtered vs. raw LFP).
%       3. Spike raster plots overlaid on the raw LFP trace.
%
% DEPENDENCIES:
%   - Custom function: spike_triggered_average(lfp, spikes)
% =========================================================================

clc 
clear 
close all 
changeCurrentFolder('D:\daniel\Mouse12-120808')
%%
load SWS_episode.mat
load SpikesSWS.mat spikes_sws
load thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat
load SOreferenceChannelDelayAndRatio.mat 
load SOdetectedForChooseOneChannelFromEachShank.mat

%%
fs=1250;
t= (1:length(SWS_episode(1,:)))/fs;
figure 
plot(t , zscore(SWS_episode(1,:)),'Color','green','LineWidth',2)
hold on 
for i=1:7
    plot (t ,spikes_sws(i,:)+4*i,'Color','yellow','LineWidth',2)
end
plot (t,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)-i,'Color','red')
plot (t,SOdetected.Y(1,:)-i,'Color','white',LineWidth=2  )
plot (t,SOdetected.ISBLIPE(1,:)-i,'Color','magenta',LineWidth=2)
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
xlabel('time(s)')

%%
spikes = zeros(7,length(spikes_sws(i,:)));
lfp = thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:);
for i=1:7
spikes(i,:) = spikes_sws(i,:);
end
 [sta, t] = spike_triggered_average(lfp, spikes);
 figure 
plot (t,sta)

%%
% Define the LFP data and spike data
lfpData = lfp; % Example LFP data (replace with your actual data)
spikeData = spikes_sws(1:7,:); % Example spike data (replace with your actual data)
windowSize = 400; % Window size for spike triggered average

% Compute spike triggered average
sta = zeros(1, windowSize);
for i = 1:size(spikeData, 1)
    for j = 1:size(spikeData, 2)
        if spikeData(i,j) == 1
            if j-windowSize >= 1
                sta = sta + lfpData(j-windowSize+1:j);
            else
                sta = sta + [zeros(1, windowSize-j), lfpData(1:j)];
            end
        end
    end
end
sta = sta / sum(sum(spikeData));

% Plot the spike triggered average
figure;
plot(linspace(-windowSize/2, windowSize/2, windowSize), sta);
xlabel('Time (ms)');
ylabel('Amplitude');
title('Spike Triggered Average');
%%
% spikessamp = find(spikeData==1);
% spikessamp = transpose(spikessamp);
figure
t1 = (-fs/2:fs/2)/fs;
windowSize = 0.5*fs;
spt = zeros(1,length(spikessamp(1)-windowSize:spikessamp(1)+windowSize));
avg = zeros(size(spikeData,1),length(spikessamp(1)-windowSize:spikessamp(1)+windowSize));
for k=1:size(spikeData,1)
spikessamp = find(spikeData(k,:)==1);
spikessamp(spikessamp < windowSize) = [];
spikessamp(spikessamp > length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks)-windowSize) = [];

    for i=1:size(spikessamp,2)
%         if spikessamp(i)-windowSize <=0
%         data(1,:) = [zeros(1, windowSize), thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,spikessamp(i):spikessamp(i)+windowSize)];
%         elseif spikessamp(i)+windowSize >= thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,end)
%         data(1,:) = [thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,spikessamp(i)-windowSize:spikessamp(i)), zeros(1, windowSize)];
%         else
        spt = spt + thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,spikessamp(i)-windowSize:spikessamp(i)+windowSize);
%         end 
    
    end
    avg(k,:) = spt/size(spikessamp,2);
    plot(t1,avg(k,:))
    hold on 
end
% avg = spt/size(spikessamp,2);
% plot(t1,avg)
xlabel('Time (ms)');
ylabel('Amplitude');
title('Spike Triggered Average');


figure
plot(t1, mean(avg,1))
%%
Colors = ['g','c','y','m','g','r','y'];
figure
t1 = (-fs/2:fs/2)/fs;
windowSize = 0.5*fs;
spt = zeros(1,length(spikessamp(1)-windowSize:spikessamp(1)+windowSize));
avg = zeros(size(spikeData,1),length(spikessamp(1)-windowSize:spikessamp(1)+windowSize));
labels = {};

for k=1:size(spikeData,1)
spikessamp = find(spikeData(k,:)==1);
spikessamp(spikessamp < windowSize) = [];
spikessamp(spikessamp > length(SWS_episode(1,:))-windowSize) = [];

    for i=1:size(spikessamp,2)
%         if spikessamp(i)-windowSize <=0
%         data(1,:) = [zeros(1, windowSize), thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,spikessamp(i):spikessamp(i)+windowSize)];
%         elseif spikessamp(i)+windowSize >= thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,end)
%         data(1,:) = [thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,spikessamp(i)-windowSize:spikessamp(i)), zeros(1, windowSize)];
%         else
        spt = spt + SWS_episode(1,spikessamp(i)-windowSize:spikessamp(i)+windowSize);
%         end 
    
    end
    avg(k,:) = spt/size(spikessamp,2);
    plot(t1,avg(k,:),Colors(k),LineWidth=2)
    set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
    labels{1, k} = ['Cell = ' num2str(k)];
    hold on 
end
% avg = spt/size(spikessamp,2);
% plot(t1,avg)
xlabel('Time (ms)');
ylabel('Amplitude');
title('Spike Triggered Average');
legend(labels,'TextColor', [1 1 1])

figure
plot(t1, mean(avg,1),Colors(1),LineWidth=2)
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 

%%
t= (1:length(SWS_episode(1,:)))/fs;
figure
hold on
for i=1:size(spikeData,1)
    plot(t,spikeData(i,:)+2*i)

end
plot(t,zscore(SWS_episode(1,:))-10)
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
