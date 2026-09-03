% =========================================================================
% SCRIPT: Slow Oscillation (SO) Morphology, Secondary Peaks, and Spatial Heterogeneity
% SUBJECT: Multi-channel Thalamic Recording (8 Shanks)
% =========================================================================
% DESCRIPTION:
% Analyzes the morphology and spatial propagation of Slow Oscillations (SOs) 
% across 8 representative channels (one per shank). Computes the population 
% mean SO waveform and evaluates the presence, timing, and amplitude of 
% secondary peaks relative to the primary reference peak. Quantifies the 
% spatial heterogeneity of SO amplitudes across the 8 channels by calculating 
% the Mean, Standard Deviation (STD), and Coefficient of Variation (CV) for 
% each event. Additionally, compares these spatiotemporal metrics across 
% different frequency bands (broadband 0.5-10 Hz vs. the original filtered 
% signal) and visualizes specific high/low heterogeneity events.
%
% INPUTS:
%   - thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat: Filtered LFP 
%     data (one representative channel per shank).
%   - daleyForOneChannnelOfEachShankBaseOnMaxPeak.mat: Precomputed delay data.
%   - SWS_episode_new_90.mat: Raw SWS LFP data.
%
% OUTPUTS:
%   - Visualizations: 
%       1. Mean SO waveforms and spatial mean signals.
%       2. Scatter plots and histograms of peak-to-peak delays and amplitude 
%          ratios (secondary peak / primary peak).
%       3. Histograms of spatial Mean, STD, and CV of peak amplitudes.
%       4. Visual inspections of specific SO events highlighting spatial 
%          heterogeneity.
%
% DEPENDENCIES:
%   - Custom function: SOMolle (for Slow Oscillation detection).
%   - MATLAB Signal Processing Toolbox: eegfilt, findpeaks.
% =========================================================================

clc 
clear
% close all 
%% read the data and detection 
load thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat
load daleyForOneChannnelOfEachShankBaseOnMaxPeak.mat
load SWS_episode_new_90.mat

ch_number = size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1);
fs=1250;
ChNum=8;
sws = zeros(ChNum,length(SWS_episode(1,:)));
sws_ch_num = (1:8:64);

for i=1:ChNum
    sws(i, :) = SWS_episode(sws_ch_num(i),:);
end

Y = zeros(ch_number,length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)));
ISBLIPE = zeros(ch_number,length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)));
parfor i=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
[y,IsBlip]  = SOMolle(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(i,:));
Y(i,:) = y;
ISBLIPE(i,:) = IsBlip;
%   begins(i,:)=find(diff(Y)==1);
%   End(i,:) = find(diff(Y==-1));
%   peak(i,:)=find(ISBLIPE==1);
%   trough(i,:) = find(ISBLIPE==-1);
end
refTime = zeros(1,length(ISBLIPE(1,:)));
ref = ISBLIPE(1,:);
refTime =find(ref==1)/fs;
Locrefsamp = find(ref==1);
%% mean for all events in each channels

Colors = ['g','c','y','m','g','r','y','c'];
coefs = 1:8;

SampBack = fs/2;
SampForward = fs/2;
TimeBack = 0.5;
TimeForward = 0.5;
TimeLimit = 0.2;

figure
hold on

for i=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)    
    means_all = zeros(1, 2*SampBack+1);

    for j=1:size(Locrefsamp, 2)

        Tback = Locrefsamp(1,j)-SampBack;
        Tforward = Locrefsamp(1,j)+SampForward;
        means = thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(i, Tback:Tforward);
        means_all = means_all + means;
%         figure
%         plot((-fs:fs)/fs,means)

%     Tback = Locrefsamp(1,j)-fs:Locrefsamp(1,j)-round(0.2*fs);
%     Tforward = Locrefsamp(1,j)+round(0.2*fs):Locrefsamp(1,j)+fs;
%     sample = [Tback Tforward];
%     Means = mean(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(i,sample));

    end

    means_all = means_all / size(Locrefsamp, 2);
    plot((Tback:Tforward)/fs,means_all+coefs(i),Colors(i),'LineWidth',2)
    set(gca,'fontsize',16,'color',[0 0 0])
    set(groot, 'defaultFigureColor', [0 0 0]);
    set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
end 
%%
signal = zeros(1,length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)));
t = (1:length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)))/fs;
coef = 1:8;
for i=1:size(Locrefsamp, 2)
    Sback = Locrefsamp(1,i)-SampBack;
    Sforward = Locrefsamp(1,i)+SampForward;
    sample = Sback:Sforward;
    Means = mean( thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(:, sample));
    signal(1,sample)= Means;
end
figure
plot(t,(signal/fs),'LineWidth',2,'Color','y')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
hold on 
for k=1:size(Locrefsamp, 2)
xline(Locrefsamp(k)/fs, '--g')
xline((Locrefsamp(k)/fs)+TimeForward,'r')
xline((Locrefsamp(k)/fs)-TimeBack,'r')
xline((Locrefsamp(k)/fs)+TimeLimit,'c')
xline((Locrefsamp(k)/fs)-TimeLimit,'c')
end 
SwS = zeros(1,length(sws(1,:)));
for m=1:ChNum
    SwS = zscore(sws(m,:));
plot (t ,(SwS/fs)+(coef(m)*0.01),Colors(m) )
end 

hold off

%% avrage and ratio between Peak2/peak ref
signalAll = zeros(1,length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)));
refForMean = ISBLIPE(1,:);
refTime =find(refForMean==1)/fs;
refsamp = round(refTime*fs);
delayRaw = zeros(1,length(refTime(1,:)));
MeanPeaks = zeros(1,length(refTime(1,:)));
MaxPeakRAw = zeros(1,length(refTime(1,:)));
ratio = zeros(1,length(refTime(1,:)));

nbin = 100;

for ii=1:size(refsamp, 2)
    Sback = refsamp(1,ii)-SampBack;
    Sforward = refsamp(1,ii)+SampForward;
    sample = Sback:Sforward;
    Means = mean(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(:, sample));
    signalAll(1,sample)= Means;
end


    for iii=1:size(refTime,2)
    startsample = round(refTime(iii)*fs)-SampBack;
    endsample = round(refTime(iii)*fs)+SampForward;
    data = signalAll(1,startsample:endsample);
    [peaks, locations] = findpeaks(data);
    findpeaks(data)
    [maxPeak, maxIndex] = sort(peaks);
%     PeaksSort = sort(peaks); 
    MaxPeakRAw(iii) = maxPeak(end);
    % Get the corresponding location from the 'locations' data
    maxLocation = locations(maxIndex(end))+startsample;
    
    delayRaw(1,iii) = refTime(iii)-(maxLocation/fs);
    if delayRaw(1,iii) < 0.01 & delayRaw(1,iii) > -0.01
        if length(maxPeak)==1
        delayRaw(1,iii) = NaN;
        ratio(1,iii) = NaN;
        else
        MaxPeakRAw(iii) = maxPeak(end-1);
        maxLocation = locations(maxIndex(end-1))+startsample;
        delayRaw(1,iii) = refTime(iii)-(maxLocation/fs);
        ratio(1,iii) = MaxPeakRAw(iii)/thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,round(refTime(iii))*fs);
        end
        
    end 
%     rater(1,iii) = MaxPeak(iii)/signalAll(1,round(refTime(iii)*fs)); 

    end
figure
histogram(delay,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('Delay')
title('Histogram Delays ', 'Color', 'white')

figure
histogram(ratio,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('Delay')
title('Histogram Delays ', 'Color', 'white')



figure
plot(ratio, delayRaw, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'green','MarkerSize',8);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
xlabel('peak/PEAK')
ylabel('delay')

% Get handles to all open figures
figHandles = findall(0, 'Type', 'figure');

% Maximize each figure
parfor i = 1:numel(figHandles)
    set(figHandles(i), 'WindowState', 'maximized');
end

%% avrage and ratio between Peak2/peak1
signalAll = zeros(1,length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)));
refForMean = ISBLIPE(1,:);
refTime =find(refForMean==1)/fs;
refsamp = round(refTime*fs);
delayRaw = zeros(1,length(refTime(1,:)));
MeanPeaks = zeros(1,length(refTime(1,:)));
MaxPeakRAw = zeros(1,length(refTime(1,:)));
ratio = zeros(1,length(refTime(1,:)));

nbin = 100;

for ii=1:size(refsamp, 2)
    Sback = refsamp(1,ii)-SampBack;
    Sforward = refsamp(1,ii)+SampForward;
    sample = Sback:Sforward;
    Means = mean(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(:, sample));
    signalAll(1,sample)= Means;
end


    for iii=1:size(refTime,2)
    startsample = round(refTime(iii)*fs)-SampBack;
    endsample = round(refTime(iii)*fs)+SampForward;
    data = signalAll(1,startsample:endsample);
    [peaks, locations] = findpeaks(data);
    
    [maxPeak, maxIndex] = sort(peaks);
%     PeaksSort = sort(peaks); 
    MaxPeakRAw(iii) = maxPeak(end);
    % Get the corresponding location from the 'locations' data
    maxLocation = locations(maxIndex(end))+startsample;
    
    delayRaw(1,iii) = refTime(iii)-(maxLocation/fs);
    if delayRaw(1,iii) < 0.01 && delayRaw(1,iii) > -0.01
        if length(maxPeak)==1
        delayRaw(1,iii) = NaN;
        ratio(1,iii) = NaN;
        else
        MaxPeakRAw(iii) = maxPeak(end-1);
        maxLocation = locations(maxIndex(end-1))+startsample;
        delayRaw(1,iii) = refTime(iii)-(maxLocation/fs);
        ratio(1,iii) = MaxPeakRAw(iii)/maxPeak(end);
        end
        
    end 
%     rater(1,iii) = MaxPeak(iii)/signalAll(1,round(refTime(iii)*fs)); 

    end
figure
histogram(delay,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('Delay')
title('Histogram Delays ', 'Color', 'white')

figure
histogram(ratio,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('Delay')
title('Histogram peak/Peak ', 'Color', 'white')



figure
plot(ratio, delayRaw, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'green','MarkerSize',8);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
xlabel('peak/PEAK')
ylabel('delay')

% Get handles to all open figures
figHandles = findall(0, 'Type', 'figure');

% Maximize each figure
parfor i = 1:numel(figHandles)
    set(figHandles(i), 'WindowState', 'maximized');
end




%% Histogram of main peak amp

biggestPeakAmplitude = zeros(1,length(refTime(1,:)));
for iii=1:size(refTime,2)
    startsample = round(refTime(iii)*fs)-SampBack;
    endsample = round(refTime(iii)*fs)+SampForward;
    data = signalAll(1,startsample:endsample);
    [peakAmplitudes, peakLocations] = findpeaks(data);

   % Find the index of the biggest peak
    [~, maxPeakIndex] = max(peakAmplitudes);
    % Get the amplitude of the biggest peak
    biggestPeakAmplitude(iii) = peakAmplitudesRaw(maxPeakIndexRaw);
  
 end
figure
histogram(biggestPeakAmplitude,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('Amplitude');
ylabel('Count');
title('Histogram of Amplitude values of the biggest peak');
% Get handles to all open figures
figHandles = findall(0, 'Type', 'figure');

% Maximize each figure
parfor i = 1:numel(figHandles)
    set(figHandles(i), 'WindowState', 'maximized');
end

%% Histogram of STD and CV biggest amplitude for all channels 
Colors = ['g','c','y','m','g','r','y','c'];
coefs = 1:8;

SampBack = fs/2;
SampForward = fs/2;
TimeBack = 0.5;
TimeForward = 0.5;
sampLimit = 0.2*fs;

biggestPeakAmplitudeForEachChannel = zeros(1,8);
MeanForEachChannel = zeros(1,length(refTime(1,:)));
StdAll = zeros(1,length(refTime(1,:)));

for i=1:size(Locrefsamp, 2)    
    startsample = round(refTime(i)*fs)-sampLimit;
    endsample = round(refTime(i)*fs)+sampLimit;
    for j=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    data = thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(j,startsample:endsample);
    [peakAmplitudes, peakLocations] = findpeaks(data);

   % Find the index of the biggest peak
    [~, maxPeakIndex] = max(peakAmplitudes);
    % Get the amplitude of the biggest peak
    biggestPeakAmplitudeForEachChannel(1,j) = peakAmplitudes(maxPeakIndex);
    
    end

    MeanForEachChannel(1,i) = mean(biggestPeakAmplitudeForEachChannel);
    StdAll(1,i) = std(biggestPeakAmplitudeForEachChannel);
    

end 
CV = StdAll./MeanForEachChannel;
%
figure 
hold on 
for k=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    strsamp = refsamp(1,15)-SampBack;
    Endsamp = refsamp(1,15)+SampForward;
    plot((strsamp:Endsamp)/fs,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(k,strsamp:Endsamp)+2*k,'y')
end 
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title('CV = 14.10 ', 'Color', 'white')
xline((refTime(15)),'c')
hold off
%
figure
hold on 
for m=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    strsamp = refsamp(1,18)-SampBack;
    Endsamp = refsamp(1,18)+SampForward;
    plot((strsamp:Endsamp)/fs,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(m,strsamp:Endsamp)+2*m,'y')
end 
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title('CV = 22.76 ', 'Color', 'white')
xline((refTime(18)),'c')
hold off
%
figure 
hold on 
for n=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    strsamp = refsamp(1,41)-SampBack;
    Endsamp = refsamp(1,41)+SampForward;
    plot((strsamp:Endsamp)/fs,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(n,strsamp:Endsamp)+2*n,'y')
end 
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title('CV = 14.41', 'Color', 'white')

xline((refTime(41)),'c')

hold off 
%
figure
hold on 
for n=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    strsamp = refsamp(1,3)-SampBack;
    Endsamp = refsamp(1,3)+SampForward;
    plot((strsamp:Endsamp)/fs,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(n,strsamp:Endsamp)+2*n,'y')
end 
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title('CV = 2.74', 'Color', 'white')

xline((refTime(3)),'c')

hold off 
%
figure
hold on 
for n=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    strsamp = refsamp(1,58)-SampBack;
    Endsamp = refsamp(1,58)+SampForward;
    plot((strsamp:Endsamp)/fs,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(n,strsamp:Endsamp)+2*n,'y')
end 
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title('CV = 0.92', 'Color', 'white')

xline((refTime(58)),'c')

hold off 
%
figure
hold on 
for n=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    strsamp = refsamp(1,26)-SampBack;
    Endsamp = refsamp(1,26)+SampForward;
    plot((strsamp:Endsamp)/fs,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(n,strsamp:Endsamp)+2*n,'y')
end 
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title('STD = 0.53', 'Color', 'white')

xline((refTime(26)),'c')

hold off 
%
figure
hold on 
for n=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    strsamp = refsamp(1,58)-SampBack;
    Endsamp = refsamp(1,58)+SampForward;
    plot((strsamp:Endsamp)/fs,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(n,strsamp:Endsamp)+2*n,'y')
end 
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title('STD = 0.5149', 'Color', 'white')

xline((refTime(58)),'c')

hold off 
%
figure
hold on 
for n=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    strsamp = refsamp(1,111)-SampBack;
    Endsamp = refsamp(1,111)+SampForward;
    plot((strsamp:Endsamp)/fs,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(n,strsamp:Endsamp)+2*n,'y')
end 
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title('STD =    0.6192', 'Color', 'white')

xline((refTime(111)),'c')

hold off 
%
figure
hold on 
for n=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    strsamp = refsamp(1,111)-SampBack;
    Endsamp = refsamp(1,111)+SampForward;
    plot((strsamp:Endsamp)/fs,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(n,strsamp:Endsamp)+2*n,'y')
end 
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title('STD =    0.6192', 'Color', 'white')

xline((refTime(111)),'c')

hold off 
%
figure
hold on 
for n=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    strsamp = refsamp(1,15)-SampBack;
    Endsamp = refsamp(1,15)+SampForward;
    plot((strsamp:Endsamp)/fs,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(n,strsamp:Endsamp)+2*n,'y')
end 
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title('STD =     0.1053', 'Color', 'white')

xline((refTime(15)),'c')

hold off 
%
figure
hold on 
for n=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    strsamp = refsamp(1,18)-SampBack;
    Endsamp = refsamp(1,18)+SampForward;
    plot((strsamp:Endsamp)/fs,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(n,strsamp:Endsamp)+2*n,'y')
end 
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title('STD = 0.0668', 'Color', 'white')

xline((refTime(18)),'c')

hold off 
%
figure
hold on 
for n=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    strsamp = refsamp(1,20)-SampBack;
    Endsamp = refsamp(1,20)+SampForward;
    plot((strsamp:Endsamp)/fs,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(n,strsamp:Endsamp)+2*n,'y')
end 
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
title('STD = 0.1384', 'Color', 'white')

xline((refTime(20)),'c')

hold off 
%
figure
histogram(MeanForEachChannel,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);

figure
histogram(StdAll,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('STD for all channels')
title('Histogram STD for all channels ', 'Color', 'white')


figure
histogram(CV,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('CV for all channels')
title('Histogram CV for all channels ', 'Color', 'white')

%% plot Mean and STD and CV base on main peak amp

figure
plot(MeanForEachChannel, biggestPeakAmplitude, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'green','MarkerSize',8);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
xlabel('Mean For Each Channel')
ylabel('biggest Peak Amplitude')

figure
plot(StdAll, biggestPeakAmplitude, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'c','MarkerSize',8);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
xlabel('STD for all channels')
ylabel('biggest Peak Amplitude')

figure
plot(CV, biggestPeakAmplitude, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'white','MarkerSize',8);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
xlabel('CV for all channels')
ylabel('biggest Peak Amplitude')

%% Filtering between 0.5 to 10 Hz and detect peaks on the raw signal 
swsFiltered = zeros(size(sws,1),length(sws(1,:)));
signalAllRaw = zeros(1,length(sws(1,:)));
fs = 1250;
down_freq = 0.5;
up_freq = 10;

for ii=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    
    Means = mean(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(:, :));
    signalAllRaw(1,:)= Means;

end

swsFiltered(1,:) = eegfilt(signalAllRaw(1,:),fs,down_freq,up_freq,0,floor(fs/down_freq)*3,0,'fir1');
%%

biggestPeakAmplitudeRaw = zeros(1,length(refTime(1,:)));
ratio = zeros (1,length(refTime(1,:)));
delayRaw = zeros (1,length(refTime(1,:)));


% for iii=1:size(refTime,2)
% 
%     startsample = round(refTime(iii)*fs)-SampBack;
%     endsample = round(refTime(iii)*fs)+SampForward;
%     dataRaw = signalAllRaw(1,startsample:endsample);
%     [peakAmplitudesRaw, peakLocationsRaw] = findpeaks(dataRaw);
%     [sortpeakAmplitudesRaw, sortpeakLocationsRaw]= sort(peakAmplitudesRaw);
%     ratio(iii) = sortpeakAmplitudesRaw(end-1)/sortpeakAmplitudesRaw(end);
%     distance = sortpeakLocationsRaw (sortpeakAmplitudesRaw(end-1))+startsample;
%     delayRaw(iii) = distance - refTime(1,iii);
% 
%  end

for iii = 1:size(refTime, 2)
    startsample = round(refTime(iii) * fs) - SampBack;
    endsample = round(refTime(iii) * fs) + SampForward;
    dataRaw = swsFiltered(1, startsample:endsample);
    [peakAmplitudesRaw, peakLocationsRaw] = findpeaks(dataRaw);
    [~, sortIndices] = sort(peakAmplitudesRaw);
    sortedPeakAmplitudesRaw = peakAmplitudesRaw(sortIndices);
    if length(peakAmplitudesRaw)==1
        delayRaw(1,iii) = NaN;
        ratio(1,iii) = NaN;
    else
    ratio(iii) = sortedPeakAmplitudesRaw(end-1) / sortedPeakAmplitudesRaw(end);
    distance = peakLocationsRaw(sortIndices(end-1)) + startsample;
    delayRaw(iii) = (distance/fs) - refTime(1, iii);
    end
end

%   for iii=1:size(refTime,2)
%     startsample = round(refTime(iii)*fs)-SampBack;
%     endsample = round(refTime(iii)*fs)+SampForward;
%     dataRaw = swsFiltered(1,startsample:endsample);
%     [peaksRaw, locationsRaw] = findpeaks(data);
% %     findpeaks(data)
%     [maxPeakRaw, maxIndexRAw] = sort(peaksRaw);
% %     PeaksSort = sort(peaks); 
%     MaxPeakRAw(iii) = maxPeakRaw(end);
%     % Get the corresponding location from the 'locations' data
%     maxLocation = locations(maxIndexRAw(end))+startsample;
%     
%     delayRaw(1,iii) = refTime(iii)-(maxLocation/fs);
%     if delayRaw(1,iii) < 0.01 && delayRaw(1,iii) > -0.01
%         if length(maxPeakRaw)==1
%         delayRaw(1,iii) = NaN;
%         ratio(1,iii) = NaN;
%         else
%         MaxPeakRAw(iii) = maxPeak(end-1);
%         maxLocation = locations(maxIndex(end-1))+startsample;
%         delayRaw(1,iii) = refTime(iii)-(maxLocation/fs);
%         ratio(1,iii) = MaxPeakRAw(iii)/maxPeak(end);
%         end
%         
%     end 
%   end

 figure
plot(delayRaw, ratio, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'magenta','MarkerSize',8);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
xlabel('delay(s)')
ylabel('ratio(peak/PEAK)')
%%
biggestPeakAmplitudeRaw = zeros(1,length(refTime(1,:)));
ratio = zeros (1,length(refTime(1,:)));
delayRaw = zeros (1,length(refTime(1,:)));
sampLimit = 0.2*fs;
sampref = fs*refTime;
SAMPBACK = round(0.2*fs);
SAMPFORW = round(0.2*fs);


for iii = 1:size(refTime, 2)

    startsample = round(refTime(iii) * fs) - SampBack;
    endsample = round(refTime(iii) * fs) + SampForward;
    dataRaw = swsFiltered(1, startsample:endsample);
    
%     STARTSAMP = round(refTime(iii) * fs) - SAMPBACK;
%     ENDSAMP = round(refTime(iii) * fs) + SAMPFORW;
%     DATARAW = swsFiltered(1, STARTSAMP:ENDSAMP);


%     [PeakAmplitudesRaw, PeakLocationsRaw] = findpeaks(DATARAW);

%     temppeakLocationsRaw = peakLocationsRaw + startsample;

%     [refPeak, indrefpeak]= peakAmplitudesRaw(abs(temppeakLocationsRaw) <= sampLimit);
%     [refPeak , indrefpeak] = max(PeakAmplitudesRaw);
%     indrefpeaksamp = PeakLocationsRaw(indrefpeak) + STARTSAMP;

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
        ratio(1,iii) = NaN;
    else
    ratio(iii) = sortedPeakAmplitudesRaw(end) / refpeakAmplitude;
    distance = peakLocationsRaw(sortIndices(end)) + startsample;
    delayRaw(iii) = (distance/fs) - refTime(1, iii);
    end

end

 figure
plot(delayRaw, ratio, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'magenta','MarkerSize',8);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
xlabel('delay(s)')
ylabel('ratio(peak/PEAK)')
%
eventNum = 54; % event num = 3,1,54
T = (round(refTime(eventNum) * fs) - SampBack:round(refTime(eventNum) * fs) + SampForward)/fs;
figure
plot(T,swsFiltered(1,round(refTime(eventNum) * fs) - SampBack:round(refTime(eventNum) * fs) + SampForward),'y')
xline(refTime(eventNum),'-g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
legend(['ratio = ' num2str(ratio(eventNum)) ], ['delay = ' num2str(delayRaw(eventNum))],'TextColor', 'red', 'Location', 'northwest')

%% only for refrence channels 
biggestPeakAmplitudeRaw = zeros(1,length(refTime(1,:)));
ratio = zeros (1,length(refTime(1,:)));
delayRaw = zeros (1,length(refTime(1,:)));
sampLimit = 0.2*fs;
sampref = fs*refTime;
SAMPBACK = round(0.2*fs);
SAMPFORW = round(0.2*fs);

fs=1250;
down_freq = 0.5;
up_freq = 10;

%exclude reference signal and filter between 0.5 to 10 Hz

REFchannel = zeros (1,length(sws(1,:)));
REFchannel(1,:) = sws(1,:);
REFchannelFiltered = eegfilt(REFchannel(1,:),fs,down_freq,up_freq,0,floor(fs/down_freq)*3,0,'fir1');
%%

for iii = 1:size(refTime, 2)

    startsample = round(refTime(iii) * fs) - SampBack;
    endsample = round(refTime(iii) * fs) + SampForward;
    dataRaw = REFchannelFiltered(1, startsample:endsample);
    
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
        ratio(1,iii) = NaN;
    else
    ratio(iii) = sortedPeakAmplitudesRaw(end) / refpeakAmplitude;
    distance = peakLocationsRaw(sortIndices(end)) + startsample;
    delayRaw(iii) = (distance/fs) - refTime(1, iii);
    end

end

 figure
plot(delayRaw, ratio, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'red','MarkerSize',8);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
xlabel('delay(s)')
ylabel('ratio(peak/PEAK)')
%%
eventNum = 1; % event num = 1,9,18,96
T = (round(refTime(eventNum) * fs) - SampBack:round(refTime(eventNum) * fs) + SampForward)/fs;
figure
plot(T,REFchannelFiltered(1,round(refTime(eventNum) * fs) - SampBack:round(refTime(eventNum) * fs) + SampForward),'y')
xline(refTime(eventNum),'-g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
legend(['ratio = ' num2str(ratio(eventNum)) ], ['delay = ' num2str(delayRaw(eventNum))],'TextColor', 'red', 'Location', 'northwest')
%
histogram(ratio,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('ratio')
title('Histogram ratios ', 'Color', 'white')
%%
