% =========================================================================
% SCRIPT: Phase-Amplitude Coupling (PAC) Analysis of Slow Oscillations by Amplitude Class
% SUBJECT: Mouse12-120806
% =========================================================================
% DESCRIPTION:
% Computes and visualizes Phase-Amplitude Coupling (PAC) between the phase 
% of Slow Oscillations (SOs, 0.5-4 Hz) and the amplitude of the spindle 
% band (7-15 Hz) on a representative thalamic channel. It categorizes SO 
% events into three groups based on their secondary-to-primary peak ratio: 
% "All" events, "Big" ratio events (> 0.5), and "Short" ratio events 
% (<= 0.5). For each group, it calculates the Synchronization Index (SI) 
% using the custom PAC class, and generates plots for the mean Time-Frequency 
% Representation (TFR), the phase angle distribution (polar histogram), 
% and the coupling strength magnitude. Finally, it exports the phase angles 
% and coupling strengths for all three groups.
%
% INPUTS:
%   - SWS_episode.mat: Raw continuous LFP data for the reference channel.
%   - SOdetectedForChooseOneChannelFromEachShank.mat: Detected SO peak times.
%   - SOreferenceChannelDelayAndRatio.mat: Precomputed peak amplitude ratios.
%
% OUTPUTS:
%   - Visualizations: Mean TFR (imagesc), phase angle distribution 
%     (circ_plot), and coupling strength histograms for All, Big, and 
%     Short SO groups.
%   - PAC_features120806.mat: Structure containing the phase angles and 
%     coupling strengths (abs(SI)) for all three event groups.
%
% DEPENDENCIES:
%   - Custom class: PAC (Phase-Amplitude Coupling).
%   - Custom function: circ_plot (for polar histograms).
% =========================================================================
clc 
clear
close all

%% 
% load thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat
load SWS_episode.mat
load SOdetectedForChooseOneChannelFromEachShank.mat
load SOreferenceChannelDelayAndRatio.mat
fs = 1250;

%%
 
% [y,IsBlip] = SOMolle(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:));

%% for all events 
pac_all = PAC(1, [-2.5 -2], false, true);

data = SWS_episode(1,:);
event_sample = find(SOdetected.ISBLIPE(1, :) == 1);

pac_all.Run(data, [7 15], data, [0.5 4], event_sample, fs);

% plot(pac_all)

figure
imagesc(pac_all.Time, pac_all.Freq, pac_all.MeanTFR);
set(gca,'YDir', 'normal');
hold on;
plot(pac_all.Time, pac_all.MeanData/max(pac_all.MeanData)*2+11, 'k', 'LineWidth', 2);
title('PAC for all events','Color','k')
xlabel('Time (s)');
ylabel('Freq');
set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0], 'defaultAxesZColor', [0 0 0]);

figure
circ_plot(phase(pac_all.SI), 'hist', [], 20,true,true,'linewidth',2,'color','r')
set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title('angle for all events ','Color','k')

figure
histogram(abs(pac_all.SI),'FaceColor','b')
title('strength for all events ','Color','k')
set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [0 0 0 ]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0], 'defaultAxesZColor', [0 0 0]);

%% events with biger ratio
pac_big = PAC(1, [-2.5 -2], false, true);

data = SWS_episode(1,:);
indexBig = find(SOreferenceChannelDelayAndRatio.ratio(1, :) > 0.5);
event_sample_big = event_sample(indexBig);

pac_big.Run(data, [7 15], data, [0.5 4], event_sample_big, fs);

figure
imagesc(pac_big.Time, pac_big.Freq, pac_big.MeanTFR);
set(gca,'YDir', 'normal');
hold on;
plot(pac_big.Time, pac_big.MeanData/max(pac_big.MeanData)*2+11, 'k', 'LineWidth', 2);

xlabel('Time (s)');
ylabel('Freq');
set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0], 'defaultAxesZColor', [0 0 0]);
title('PAC for big events','Color','k')


figure
circ_plot(phase(pac_big.SI), 'hist', [], 20,true,true,'linewidth',2,'color','r')
% set(gca,'fontsize',16,'color',[1 1 1])
% set(groot, 'defaultFigureColor', [1 1 1]);
% set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title ('angle for big events ')

figure
histogram(abs(pac_big.SI),'FaceColor','r')
title('strength for big events ','color','k')

set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0], 'defaultAxesZColor', [0 0 0]);

%% events with shorter ratio
pac_short = PAC(1, [-2.5 -2], false, true);

data = SWS_episode(1,:);
indexShort= find(SOreferenceChannelDelayAndRatio.ratio(1, :) <= 0.5);
event_sample_short = event_sample(indexShort);

pac_short.Run(data, [7 15], data, [0.5 4], event_sample_short, fs);

figure
imagesc(pac_short.Time, pac_short.Freq, pac_short.MeanTFR);
set(gca,'YDir', 'normal');
hold on;
plot(pac_short.Time, pac_short.MeanData/max(pac_short.MeanData)*2+11, 'k', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Freq');
set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0], 'defaultAxesZColor', [0 0 0]);
title ('PAC for short ','Color','k')

figure
circ_plot(phase(pac_short.SI), 'hist', [], 20,true,true,'linewidth',2,'color','m')
% set(gca,'fontsize',16,'color',[1 1 1])
% set(groot, 'defaultFigureColor', [1 1 1]);
% set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title ('angle for short')

figure
histogram(abs(pac_short.SI),'FaceColor','m')
title('strength for big events ','Color','k')
set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0], 'defaultAxesZColor', [0 0 0]);

%%
PAC_features.angleShort = phase(pac_short.SI);
PAC_features.strengthShort = abs(pac_short.SI);
PAC_features.angleBig = phase(pac_big.SI);
PAC_features.strengthBig = abs(pac_big.SI);
PAC_features.angleAll = phase(pac_all.SI);
PAC_features.strengthALl = abs(pac_all.SI);
save PAC_features120806.mat PAC_features
