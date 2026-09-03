% =========================================================================
% SCRIPT: Slow Oscillation (SO) Morphology, Rhythmicity, and Amplitude Classification
% SUBJECT: Mouse12-120806
% =========================================================================
% DESCRIPTION:
% Analyzes the morphology and temporal rhythmicity of Slow Oscillations 
% (SOs) during Slow-Wave Sleep (SWS). It separates SO events into two 
% groups ("Big" and "Short") based on their secondary-to-primary peak 
% amplitude ratio (threshold = 0.5). The script computes the spatially 
% averaged mean signals for both groups, statistically compares their 
% amplitudes using a t-test, and evaluates SO rhythmicity by calculating 
% the dominant peak-to-peak distance and the percentage of consecutive 
% events occurring within that interval. Finally, it re-detects SOs using 
% the SOMolle algorithm to isolate and visualize individual high-ratio 
% events (ratio > 1) alongside their detection masks.
%
% INPUTS:
%   - SWS_episode.mat: Raw SWS LFP data.
%   - thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat: Filtered 
%     LFP data (one representative channel per shank).
%   - SOdetectedForChooseOneChannelFromEachShank.mat: Previously detected 
%     SO events and landmarks.
%   - SOreferenceChannelDelayAndRatio.mat: Precomputed delay and amplitude 
%     ratios for the reference channel SOs.
%
% OUTPUTS:
%   - SepratedMeanSignals.mat: Structure containing the spatially averaged 
%     mean signals and event indices for the "Big" and "Short" groups.
%   - Visualizations: Mean SO waveforms, amplitude comparison plots, and 
%     individual high-ratio SO events with SOMolle detection masks.
%   - Statistical Results: T-test comparison of amplitudes and calculation 
%     of rhythmicity percentages for both SO groups.
%
% DEPENDENCIES:
%   - Custom function: SOMolle (for Slow Oscillation detection).
%   - MATLAB Signal Processing Toolbox: findpeaks.
% =========================================================================

clc 
clear
close all
changeCurrentFolder('D:\daniel\Mouse12-120806')
%% choose one channel of each shank 
load SWS_episode.mat
load thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat
load SwsIncludeOneChannelOfEachChannels.mat
load SOdetectedForChooseOneChannelFromEachShank.mat
load REFchannelFilteredBetween0.5to10Hz.mat
load SOreferenceChannelDelayAndRatio.mat 

%% means 
% define global variables
fs = 1250;
t = (1:length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)))/fs;
THreshold = 0.5;
sampBack = fs/2;
sampForward=fs/2;
Colors = ['g','c','y','m','g','r','y','c'];
coef = 1:8:64;
SampBack = fs/2;
SampForward = fs/2;
TimeBack = 0.5;
TimeForward = 0.5;
TimeLimit = 0.2;

% define local variables

signalBig = zeros(1,length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)));
signalshort = zeros(1,length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)));
BiggerThanthreshold = find(SOreferenceChannelDelayAndRatio.ratio > 0.5);
ShorterThanthreshold = find (SOreferenceChannelDelayAndRatio.ratio <= 0.5);
refsamp= find(SOdetected.ISBLIPE(1,:)==1);
refTime = refsamp/fs;
refsampBig= refsamp(BiggerThanthreshold);
refsampShort= refsamp(ShorterThanthreshold);

% mean for bigger than threshold

for i=1:size(BiggerThanthreshold, 2)
    Sback = refsampBig(1,i)-sampBack;
    Sforward = refsampBig(1,i)+sampForward;
    sample = Sback:Sforward;
    Means = mean( thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(:, sample));
    signalBig(1,sample)= Means;
end

% mean for shorter than threshold

for j=1:size(ShorterThanthreshold, 2)
    Sback = refsampShort(1,j)-sampBack;
    Sforward = refsampShort(1,j)+sampForward;
    sample = Sback:Sforward;
    Means = mean( thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(:, sample));
    signalshort(1,sample)= Means;
end

% save signals for shorter and bigger than threshold 
SepratedMeanSignals.SignalsBiggerThanThreshold = signalBig;
SepratedMeanSignals.SignalsShorterThanThreshold = signalshort;
SepratedMeanSignals.EventsBiggerThanThreshold = BiggerThanthreshold;
SepratedMeanSignals.EventsShorterThanThreshold = ShorterThanthreshold ; 

save SepratedMeanSignals.mat SepratedMeanSignals


% plot for bigger
figure
plot(t,(signalBig)-coef(2),'LineWidth',2,'Color','y')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
hold on 
for k=1:size(refsampBig, 2)
xline(refsampBig(k)/fs, '--g')
xline((refsampBig(k)/fs)+TimeForward,'r')
xline((refsampBig(k)/fs)-TimeBack,'r')
xline((refsampBig(k)/fs)+TimeLimit,'c')
xline((refsampBig(k)/fs)-TimeLimit,'c')
end 

SwS = zeros(1,length(sws(1,:)));

for m=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    SwS = zscore(sws(m,:));
plot (t ,(SwS)+(coef(m)),Colors(m) )
end 

hold off

figure
plot(t,(signalshort)-coef(2),'LineWidth',2,'Color','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 

hold on 
for k=1:size(refsampShort, 2)
xline(refsampShort(k)/fs, '--g')
xline((refsampShort(k)/fs)+TimeForward,'r')
xline((refsampShort(k)/fs)-TimeBack,'r')
xline((refsampShort(k)/fs)+TimeLimit,'c')
xline((refsampShort(k)/fs)-TimeLimit,'c')
end 

SwS = zeros(1,length(sws(1,:)));

for m=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    SwS = zscore(sws(m,:));
plot (t ,(SwS)+(coef(m)),Colors(m) )
end 

hold off
%

% plot mean for datas that are bigger than threshold

figure
hold on

for i=1:1%size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)    
    means_allBig = zeros(1, 2*SampBack+1);

    for j=1:size(refsampBig, 2)

        Tback = refsampBig(1,j)-SampBack;
        Tforward = refsampBig(1,j)+SampForward;
        means = thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(i, Tback:Tforward);
        means_allBig = means_allBig + means;

    end

    means_allBig = means_allBig / size(refsampBig, 2);
    plot((Tback:Tforward)/fs,means_allBig+coef(i),Colors(i),'LineWidth',2)
    set(gca,'fontsize',16,'color',[0 0 0])
    set(groot, 'defaultFigureColor', [0 0 0]);
    set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 

end 
    title('mean for datas that are bigger than threshold ', 'Color', 'white')

hold off

% plot mean for datas that are shorter than threshold

figure
hold on

for i=1:1%size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)    
    means_allshort = zeros(1, 2*SampBack+1);

    for j=1:size(refsampShort, 2)

        Tback = refsampShort(1,j)-SampBack;
        Tforward = refsampShort(1,j)+SampForward;
        means = thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(i, Tback:Tforward);
        means_allshort = means_allshort + means;

    end

    means_allshort = means_allshort / size(refsampShort, 2);
    plot((Tback:Tforward)/fs,means_allshort+coef(i),Colors(i),'LineWidth',2)
    set(gca,'fontsize',16,'color',[0 0 0])
    set(groot, 'defaultFigureColor', [0 0 0]);
    set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
end 
    title('mean for datas that are shorter than threshold ', 'Color', 'white')

hold off
%% amplitude compare
ampBig = signalBig(refsampBig);
ampshort = signalshort(refsampShort);

% compute means

meanbig = mean(ampBig);
meanshort = mean(ampshort);

% Perform t-test
[h, p] = ttest2(ampBig, ampshort);

% Display results
if h
    disp(['mean amplitude for Big ratio is ' num2str(meanbig)]);
    disp(['mean amplitude for short ratio is ' num2str(meanshort)]);
    fprintf('There is a significant difference between the means.\n');
else
    disp(['mean amplitude for Big ratio is ' num2str(meanbig)]);
    disp(['mean amplitude for short ratio is ' num2str(meanshort)]);
    fprintf('There is no significant difference between the means.\n');
end
fprintf('p-value: %.4f\n', p);

%%
figure
plot (t ,signalBig+(coef(1)),Colors(1) )
hold on 
plot (t ,signalshort+(coef(2)),Colors(2) )
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
legend('bigger','shorter')

% Access the legend object
hLegend = findobj(gcf, 'Type', 'Legend');

% Change the color of the legend text
hLegend.TextColor = 'white';
hold off
%%

t1 = length((-fs/2:fs/2)/fs);
for i=1:1
    means_allshort = zeros(1, 2*SampBack+1);

    for j=1:size(refsampShort, 2)

        Tback = refsampShort(1,j)-SampBack;
        Tforward = refsampShort(1,j)+SampForward;
        meansshort = thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(i, Tback:Tforward);
        means_allshort = means_allshort + meansshort;

    end
    means_allshort = means_allshort / size(refsampShort, 2);
end 
for i=1:1
    means_allbig = zeros(size(refsampBig, 2), 2*SampBack+1);

    for j=1:size(refsampBig, 2)

        Tback = refsampBig(1,j)-SampBack;
        Tforward = refsampBig(1,j)+SampForward;
        temp = thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(i, Tback:Tforward);
        means_allbig (j,:)= temp;

    end
    means_allBig = mean(means_allbig,1);
end 
figure

plot ( means_allBig,Colors(1),"LineWidth",2 )
hold on 

plot (means_allshort,Colors(2),'LineWidth',2 )
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
legend('bigger','shorter')

% Access the legend object
hLegend = findobj(gcf, 'Type', 'Legend');

% Change the color of the legend text
hLegend.TextColor = 'white';
hold off

%%

% for Big

[peaksBig, indexBig] = findpeaks(means_allBig);
sortedpeaks = sort(peaksBig);
last_peak_index = find(peaksBig == sortedpeaks(end));
second_last_peak_index = find(peaksBig == sortedpeaks(end-1));
distanceBig = indexBig(last_peak_index) - indexBig(second_last_peak_index);

% for short

[peaksshort, indexshort] = findpeaks(means_allshort);
sortedpeaks = sort(peaksshort);
last_peak_index = find(peaksshort == sortedpeaks(end));
second_last_peak_index = find(peaksshort == sortedpeaks(end-1));
distanceshort = indexshort(last_peak_index) - indexshort(second_last_peak_index);

%%


countbig = 0;
for k=1:size(refsampBig,2)-1
    distance = refsampBig(i+1)-refsampBig(i);
    if distance <  distanceBig
        countbig = countbig + 1;
    end
end
bigPercent = countbig/size(refsampBig,2);
%
countshort = 0;
for k=1:size(refsampShort,2)-1
    distance = refsampShort(i+1)-refsampShort(i);
    if distance <  distanceshort
        countshort = countshort + 1;
    end
end
shortPercent = countshort/size(refsampShort,2);

disp(['percent for bigs = ' num2str(bigPercent)]);
disp(['percent for shorts = ' num2str(shortPercent)]);

%%

 biggestPeakAmplitudeRaw = zeros(1,length(refTime(1,:)));
ratioRawOneChannel = zeros (1,length(refTime(1,:)));
delayRaw = zeros (1,length(refTime(1,:)));
sampLimit = 0.2*fs;
sampref = fs*refTime;
SAMPBACK = round(0.2*fs);
SAMPFORW = round(0.2*fs);
SampBack = fs/2;
SampForward=fs/2;
fs=1250;
refSignal = thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:);

[y, IsBlip] = SOMolle(refSignal);

refsampch1 = find( IsBlip == 1);

for iii = 1:size(refsampch1, 2)

    startsample = refsampch1(iii)  - SampBack;
    endsample = refsampch1(iii)  + SampForward;
    dataRaw = refSignal(1, startsample:endsample);
    
    [peakAmplitudesRaw, peakLocationsRaw] = findpeaks(dataRaw);
    centerLocation = peakLocationsRaw - SampBack - 1;
    refIndex = find(abs(centerLocation) < SAMPBACK);

    if length(refIndex) > 1
        [~, maxxIndex] = max(peakAmplitudesRaw(refIndex));
        refIndex = refIndex(maxxIndex);
    end

    refpeakAmplitude = peakAmplitudesRaw(refIndex);

    peakAmplitudesRaw(refIndex) = [];
    peakLocationsRaw(refIndex) = [];

    [~, sortIndices] = sort(peakAmplitudesRaw);
    sortedPeakAmplitudesRaw = peakAmplitudesRaw(sortIndices);

    if isempty(peakAmplitudesRaw)
        delayRaw(1,iii) = NaN;
        ratioRawOneChannel(1,iii) = NaN;
    else
    ratioRawOneChannel(iii) = sortedPeakAmplitudesRaw(end) / refpeakAmplitude;
    distance = peakLocationsRaw(sortIndices(end)) + startsample;
    delayRaw(iii) = (distance/fs) - refTime(1, iii);
    end

end
ratiobigger = find(ratioRawOneChannel > 1);
upTh = 1.5;
downTH = -1;
yTime = y/fs;
for i=1:size(ratiobigger,2)
    refsampbigger = refsampch1(ratiobigger(i));
    startsample = refsampbigger - SampBack;
    endsample = refsampbigger  + SampForward;
    figure 
    plot((-fs/2:fs/2)/fs,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,startsample:endsample),'Color','y','LineWidth',2)
    hold on 
    plot ((-fs/2:fs/2)/fs , y(1,startsample:endsample),'Color','white','LineWidth',2 )
    yline(upTh,'r','LineWidth',2)
    yline(downTH,'g','LineWidth',2)
    set(gca,'fontsize',16,'color',[0 0 0])
    set(groot, 'defaultFigureColor', [0 0 0]);
    set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
    title(['event number = ' num2str(ratiobigger(i))],'Color','white')

end 
%%
display (['number of Shorter Than threshold = ' num2str(size(ShorterThanthreshold,2))])
display (['number of bigger Than threshold = ' num2str(size(BiggerThanthreshold,2))])


