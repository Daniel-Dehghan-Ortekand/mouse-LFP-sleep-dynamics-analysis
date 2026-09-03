
% =========================================================================
% SCRIPT: Population and Single-Cell Firing Rate Analysis of SOs by Amplitude Class
% SUBJECT: Mouse12-120806
% =========================================================================
% DESCRIPTION:
% Analyzes population and single-cell firing rates time-locked to Slow 
% Oscillations (SOs) during Slow-Wave Sleep (SWS). It separates SOs into 
% two groups based on a peak amplitude ratio threshold (>0.5 for "Bigger", 
% <=0.5 for "Shorter"). It computes population-level peri-event firing 
% rates for all SOs, "Bigger" SOs, and "Shorter" SOs. Then, it calculates 
% the Modulation Index (MI) for each individual cell in both groups, and 
% generates detailed plots (LFP, raster, firing rate) for cells with an 
% MI above the group mean. Finally, it exports the firing rates, MIs, and 
% figures.
%
% INPUTS:
%   - SpikesSWS120806.mat: Binary spike train data during SWS.
%   - thal_ch_norm_filtered_so120806.mat: Filtered thalamic LFP data.
%   - SOdetected120806.mat: Detected SO events and landmarks.
%   - SOreferenceChannelDelayAndRatio120806.mat: Precomputed peak ratios.
%
% OUTPUTS:
%   - Visualizations: Population firing rates (All, Bigger, Shorter) and 
%     individual cell plots for highly modulated cells.
%   - FiringrateSo120806.mat: Population firing rates (Bigger/Shorter).
%   - ModuIndexSo120806.mat: Single-cell Modulation Indices (Bigger/Shorter).
%   - Batch-saved figures (.png, .fig) in the specified directory.
%
% DEPENDENCIES:
%   - Custom functions: SpikeRaster, findThroughs, findMaxPeak.
% =========================================================================

clc 
tic
close all
clear
changeCurrentFolder('D:\daniel\Mouse12-120806')
%%
load SpikesSWS120806.mat
load thal_ch_norm_filtered_so120806.mat
load SOdetected120806.mat 
load SOreferenceChannelDelayAndRatio120806.mat 
%%

fs = 1250;
winSize = 0.5;
smoothSize = round(0.05*fs);
winSample = (-round(winSize*fs):round(winSize*fs));
soSample = find(SOdetected.ISBLIPE  (1,:) == 1);
spikeData = spikes_sws;
refCh = 1;
sws = SWS_episode(refCh,:);
soSample(soSample < round(winSize*fs) | soSample > length(sws)-round(winSize*fs)) = [];

dataFiltered = zeros(1, length(winSample));
% dataRaw = zeros(1, length(winSample));
data_raster = zeros(length(soSample), length(winSample));

for i=1:length(soSample)
    dataFiltered = dataFiltered + sws(refCh, soSample(i)+winSample)/length(soSample);
%     dataRaw = dataRaw + zscore(cortexLfp(1, soSample(i)+winSample))/length(soSample);
    data_raster(i,:) = spikeData(soSample(i)+winSample);
end

firingRate = mean(data_raster,1)*fs;
firingRate = conv(firingRate, gausswin(smoothSize)/smoothSize, "same");

t = winSample/fs;

figure
upLim = ceil(max(firingRate));
title ('Mouse12-120806 ','Color','k')
subplot(3, 1, 1)
plot(t, dataFiltered,'Color','k',LineWidth=2)
title (' mean raw data around SOs for Mouse12-120806 ','Color','k')
ylabel('Amp.','Color','k')
set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0], 'defaultAxesZColor', [0 0 0]); 
subplot(3, 1, 2)
SpikeRaster(data_raster, fs, [-winSize winSize],0.001);
title (' raster plot of all cells for Mouse12-120806 ','Color','k')
ylabel('Trials','Color','k')
set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0 ], 'defaultAxesZColor', [0 0 0]); 
subplot(3, 1, 3)
area(t, firingRate,'FaceColor','k','EdgeColor','k')
title (' Firing rate for Mouse12-120806 ','Color','k')
ylabel('FR (spike/sec)','Color','k')
xlabel('Time (s)','Color','k')
set(gca,'fontsize',16,'color',[1 1 1 ])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0], 'defaultAxesZColor', [0 0 0]); 
ylim([0 upLim])


%% firing rate for bigger than threshold 
fs = 1250;
winSize = 0.5;
smoothSize = round(0.05*fs);
winSample = (-round(winSize*fs):round(winSize*fs));
bigindex = find(SOreferenceChannelDelayAndRatio.ratio >0.5);
soSample = find(SOdetected.ISBLIPE  (1,:) == 1);
soSampleBig = soSample  (1,bigindex);
spikeData = spikes_sws;
soSampleBig(soSampleBig < round(winSize*fs) | soSampleBig > length(sws)-round(winSize*fs)) = [];

dataFiltered = zeros(1, length(winSample));
% dataRaw = zeros(1, length(winSample));
data_raster = zeros(length(soSampleBig), length(winSample));

for i=1:length(soSampleBig)
    dataFiltered = dataFiltered + sws(1, soSampleBig(i)+winSample)/length(soSampleBig);
%     dataRaw = dataRaw + zscore(cortexLfp(1, soSample(i)+winSample))/length(soSample);
    data_raster(i,:) = spikeData(soSampleBig(i)+winSample);
end

firingRate = mean(data_raster,1)*fs;
firingRateBig = conv(firingRate, gausswin(smoothSize)/smoothSize, "same");


figure
upLim = ceil(max(firingRateBig));
title ('Mouse12-120806 ','Color','k')
subplot(3, 1, 1)
plot(t, dataFiltered,'Color',[0.4940 0.1840 0.5560]	,LineWidth=2)
title (' mean raw data around SOs for Mouse12-120806 (for bigger than threshold)','Color','k')
ylabel('Amp.','Color','k')
set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0], 'defaultAxesZColor', [0 0 0]); 
subplot(3, 1, 2)
SpikeRaster(data_raster, fs, [-winSize winSize],0.001);
title (' raster plot of all cells for Mouse12-120806 (for bigger than threshold)','Color','k')
ylabel('Trials','Color','k')
set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0 ], 'defaultAxesZColor', [0 0 0]); 
subplot(3, 1, 3)
area(t, firingRateBig,'FaceColor',[0.4940 0.1840 0.5560])
title (' Firing rate for Mouse12-120806 (for bigger than threshold)','Color','k')
ylabel('FR (spike/sec)','Color','k')
xlabel('Time (s)','Color','k')
set(gca,'fontsize',16,'color',[1 1 1 ])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0], 'defaultAxesZColor', [0 0 0]); 
ylim([0 upLim])

%% firing rate for shorter than threshold 
fs = 1250;
winSize = 0.5;
smoothSize = round(0.05*fs);
winSample = (-round(winSize*fs):round(winSize*fs));
shortindex = find(SOreferenceChannelDelayAndRatio.ratio <= 0.5);
soSample = find(SOdetected.ISBLIPE  (1,:) == 1);
soSampleshort = soSample  (1,shortindex);
spikeData = spikes_sws(1:7,:);
soSampleshort(soSampleshort < round(winSize*fs) | soSampleshort > length(sws)-round(winSize*fs)) = [];

dataFiltered = zeros(1, length(winSample));
% dataRaw = zeros(1, length(winSample));
data_raster = zeros(length(soSampleshort), length(winSample));

for i=1:length(soSampleshort)
    dataFiltered = dataFiltered + sws(1, soSampleshort(i)+winSample)/length(soSampleshort);
%     dataRaw = dataRaw + zscore(cortexLfp(1, soSample(i)+winSample))/length(soSample);
    data_raster(i,:) = spikeData(soSampleshort(i)+winSample);
end

firingRate = mean(data_raster,1)*fs;
firingRateshort = conv(firingRate, gausswin(smoothSize)/smoothSize, "same");


figure
upLim = ceil(max(firingRateshort));
title ('Mouse12-120806 ','Color','k')
subplot(3, 1, 1)
plot(t, dataFiltered,'Color',[0.9290 0.6940 0.1250]	,LineWidth=2)
title (' mean raw data around SOs for Mouse12-120806 (shorter than threshold) ','Color','k')
ylabel('Amp.','Color','k')
set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0], 'defaultAxesZColor', [0 0 0]); 
subplot(3, 1, 2)
SpikeRaster(data_raster, fs, [-winSize winSize],0.001);
title (' raster plot of all cells for Mouse12-120806 (shorter than threshold)','Color','k')
ylabel('Trials','Color','k')
set(gca,'fontsize',16,'color',[1 1 1])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0 ], 'defaultAxesZColor', [0 0 0]); 
subplot(3, 1, 3)
area(t, firingRateBig,'FaceColor',[0.9290 0.6940 0.1250]	,'EdgeColor','k')
title (' Firing rate for Mouse12-120806 (shorter than threshold)','Color','k')
ylabel('FR (spike/sec)','Color','k')
xlabel('Time (s)','Color','k')
set(gca,'fontsize',16,'color',[1 1 1 ])
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultAxesXColor', [0 0 0], 'defaultAxesYColor', [0 0 0], 'defaultAxesZColor', [0 0 0]); 
ylim([0 upLim])



%% indivisual for BIgger than threshold 
fs = 1250;
winSize = 0.5;
winSample = (-round(winSize*fs):round(winSize*fs));
limitWinSample = size((-round(fs/8):round(fs/8)),2);
smoothSize = round(0.01*fs);

bigindex = find(SOreferenceChannelDelayAndRatio.ratio >0.5);
soSample = find(SOdetected.ISBLIPE  (1,:) == 1);
soSampleBig = soSample  (1,bigindex);
spikeData = spikes_sws;
soSampleBig(soSampleBig < round(winSize*fs) | soSampleBig > length(sws)-round(winSize*fs)) = [];

[nRows,nCols] = size(spikeData);

firingRateBigInd = zeros(nRows,length(winSample));
ModuIndexBig = zeros(1,nRows);

sws = thal_ch_norm_filtered(refCh,:);


for k=1:size(spikeData,1)

    dataFiltered = zeros(1, length(winSample));
    % dataRaw = zeros(1, length(winSample));
    data_raster = zeros(length(soSampleBig), length(winSample));
    
    for i=1:length(soSampleBig)
        dataFiltered = dataFiltered + sws(1, soSampleBig(i)+winSample)/length(soSampleBig);
    %     dataRaw = dataRaw + zscore(cortexLfp(1, soSample(i)+winSample))/length(soSample);
        data_raster(i,:) = spikeData(soSampleBig(i)+winSample);
    end
    
    firingRate = mean(data_raster,1)*fs;
    firingRateBigInd(k,:) = conv(firingRate, gausswin(smoothSize)/smoothSize, "same");
    limitFiringRate(1,round((fs/2))-limitWinSample:round((fs/2))+limitWinSample) = firingRatebigInd(k,round((fs/2))-limitWinSample:round((fs/2))+limitWinSample);
    
    [throughs throughsLoc] = findThroughs(limitFiringRate);
    [maxPeak, maxPeakSample] = findMaxPeak(limitFiringRate);
%     Maxpeak = maxPeak;
    Maxthrough = min(throughs);
    ModuIndexBig(1,k) = abs(maxPeak-Maxthrough);
    MaxpeaksBig(1,k) = maxPeak;
    MaxthroughsBig(1,k) = min(throughs);


end

for j=1:size(ModuIndexBig,2)
    if isnan(ModuIndexBig(1,j))
        ModuIndexBig(1,j) = 0;
    end
end 
    MeanModuIndexBig =mean(ModuIndexBig) ;

    %plot


    t = winSample/fs;
 for k=1:size(spikeData,1)

    if ModuIndexBig(1,k) > MeanModuIndexBig

    spikedata = spikeData(k,:);

    for i=1:length(soSampleBig)
%         dataFiltered = dataFiltered + sws(1, soSampleGlob(i)+winSample)/length(soSampleGlob);
        data_raster(i,:) = spikedata(soSampleBig(i)+winSample);
    end
    
    upLimGlobInd = ceil(max(firingRateBigInd(k,:)));
    figure
    title ('Mouse12-120810 ','Color','k')
    subplot(3, 1, 1)
    plot(t, dataFiltered,'Color',[0.4940 0.1840 0.5560]	,LineWidth=2)
    title (['mean raw data around Global spindles for Mouse12-120810 ans cell number is  = ' num2str(k)],'Color','k')
    ylabel('Amp.','Color','k')
    
    subplot(3, 1, 2)
    SpikeRaster(data_raster, fs, [-winSize winSize], 0.001);
    title (['raster plot of all cells for Mouse12-120810 and cell is  = ' num2str(k) ] ,'Color','k')
    ylabel('Trials','Color','k')
    subplot(3, 1, 3)
    area(t, firingRateGlobInd(k,:),'FaceColor',[0.4940 0.1840 0.5560]	)
    title ([' Firing rate for Mouse12-120810 and cell number is = ' num2str(k) ],'Color','k')
    ylabel('FR (spike/sec)','Color','k')
    xlabel('Time (s)','Color','k')
    ylim([0 upLimGlobInd])

    end
end

%% indivisual for shorter than threshold 
fs = 1250;
winSize = 0.5;
winSample = (-round(winSize*fs):round(winSize*fs));
limitWinSample = size((-round(fs/8):round(fs/8)),2);
smoothSize = round(0.01*fs);

shortindex = find(SOreferenceChannelDelayAndRatio.ratio < 0.5);
soSample = find(SOdetected.ISBLIPE  (1,:) == 1);
soSampleshort = soSample  (1,shortindex);
spikeData = spikes_sws;
sws = thal_ch_norm_filtered(refCh,:);
soSampleshort(soSampleshort < round(winSize*fs) | soSampleshort > length(sws)-round(winSize*fs)) = [];

[nRows,nCols] = size(spikeData);

firingRateShortInd = zeros(nRows,length(winSample));
ModuIndexShort = zeros(1,nRows);




for k=1:size(spikeData,1)

    dataFiltered = zeros(1, length(winSample));
    % dataRaw = zeros(1, length(winSample));
    data_raster = zeros(length(soSampleBig), length(winSample));
    
    for i=1:length(soSampleBig)
        dataFiltered = dataFiltered + sws(1, soSampleBig(i)+winSample)/length(soSampleBig);
    %     dataRaw = dataRaw + zscore(cortexLfp(1, soSample(i)+winSample))/length(soSample);
        data_raster(i,:) = spikeData(soSampleBig(i)+winSample);
    end
    
    firingRate = mean(data_raster,1)*fs;
    firingRateShortInd(k,:) = conv(firingRate, gausswin(smoothSize)/smoothSize, "same");
    limitFiringRate(1,round((fs/2))-limitWinSample:round((fs/2))+limitWinSample) = firingRateShortInd(k,round((fs/2))-limitWinSample:round((fs/2))+limitWinSample);
    
    [throughs throughsLoc] = findThroughs(limitFiringRate);
    [maxPeak, maxPeakSample] = findMaxPeak(limitFiringRate);
%     Maxpeak = maxPeak;
    Maxthrough = min(throughs);
    ModuIndexShort(1,k) = abs(maxPeak-Maxthrough);
    MaxpeaksShort(1,k) = maxPeak;
    MaxthroughsShort(1,k) = min(throughs);


end

for j=1:size(ModuIndexShort,2)
    if isnan(ModuIndexShort(1,j))
        ModuIndexShort(1,j) = 0;
    end
end 
    MeanModuIndexShort =mean(ModuIndexShort) ;

    %plot


    t = winSample/fs;
 for k=1:size(spikeData,1)

    if ModuIndexShort(1,k) > MeanModuIndexShort

    spikedata = spikeData(k,:);

    for i=1:length(soSampleshort)
%         dataFiltered = dataFiltered + sws(1, soSampleGlob(i)+winSample)/length(soSampleGlob);
        data_raster(i,:) = spikedata(soSampleshort(i)+winSample);
    end
    
    upLimShortInd = ceil(max(firingRateShortInd(k,:)));
    figure
    title ('Mouse12-120810 ','Color','k')
    subplot(3, 1, 1)
    plot(t, dataFiltered,'Color',[0.9290 0.6940 0.1250],LineWidth=2)
    title (['mean raw data around Global spindles for Mouse12-120810 ans cell number is  = ' num2str(k)],'Color','k')
    ylabel('Amp.','Color','k')
    
    subplot(3, 1, 2)
    SpikeRaster(data_raster, fs, [-winSize winSize], 0.001);
    title (['raster plot of all cells for Mouse12-120810 and cell is  = ' num2str(k) ] ,'Color','k')
    ylabel('Trials','Color','k')
    subplot(3, 1, 3)
    area(t, firingRateShortInd(k,:),'FaceColor',[0.9290 0.6940 0.1250])
    title ([' Firing rate for Mouse12-120810 and cell number is = ' num2str(k) ],'Color','k')
    ylabel('FR (spike/sec)','Color','k')
    xlabel('Time (s)','Color','k')
    ylim([0 upLimShortInd])

    end
end

%% save firing retes

FiringrateSo120810.Bigger = firingRateBig;
FiringrateSo120810.Shorter = firingRateshort;
ModuIndex120810.Bigger = ModuIndexBig;
ModuIndex120810.Shorter = ModuIndexShort;
save FiringrateSo120810.mat FiringrateSo120810
save ModuIndexSo120810.mat ModuIndex120810
%% save figures
% Get the path to the directory where you want to save the figures
save_path = 'D:/daniel/Mouse12-120810/firing rate So';

% Get a list of all open figures
fig_list = findobj('Type', 'figure');

% Save each figure to the specified path
for i = 1:length(fig_list)
    fig = fig_list(i);
    saveas(fig, fullfile(save_path, sprintf('figure_%d.png', i)));
    saveas(fig, fullfile(save_path, sprintf('figure_%d.fig', i)));

end
 toc



%%

