% =========================================================================
% SCRIPT: Full Slow Oscillation (SO) Analysis Pipeline: Propagation, Ratios, and Spatial Heterogeneity
% SUBJECT: Mouse12-120806
% =========================================================================
% DESCRIPTION:
% Comprehensive pipeline for analyzing Slow Oscillations (SOs) during 
% Slow-Wave Sleep (SWS). It begins by loading raw 90-channel EEG data, 
% segmenting SWS episodes, and selecting one representative channel per 
% shank (8 channels total) for 0.5-4 Hz filtering and SO detection 
% (via SOMolle). The script computes inter-channel propagation delays 
% and evaluates the amplitude ratio and delay of secondary-to-primary 
% peaks. It quantifies spatial heterogeneity across the 8 shanks using 
% Mean, STD, and CV of peak amplitudes. Finally, it compares these 
% spatiotemporal metrics across different frequency bands (0.5-4 Hz vs. 
% 0.5-10 Hz) and spatial scales (population mean vs. single reference 
% channel).
%
% INPUTS:
%   - Mouse12-120806.eeg: Raw 90-channel binary EEG recording.
%   - SwsTime: Predefined start/stop times for SWS episodes.
%
% OUTPUTS:
%   - SWS_episode.mat: Segmented SWS LFP data.
%   - SwsIncludeOneChannelOfEachChannels.mat: Selected shank channels.
%   - thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat: Filtered 
%     and z-scored LFP data (0.5-4 Hz).
%   - SOdetectedForChooseOneChannelFromEachShank.mat: Detected SO events.
%   - REFchannelFilteredBetween0.5to10Hz.mat: Reference channel filtered 
%     to 0.5-10 Hz.
%   - SOreferenceChannelDelayAndRatio.mat: Delay and ratio metrics for 
%     the reference channel (0.5-10 Hz).
%   - Visualizations: Scatter plots, histograms, and spatial heterogeneity 
%     metrics (Mean, STD, CV) for various SO properties.
%
% DEPENDENCIES:
%   - Custom functions: bz_LoadBinary, SOMolle.
%   - MATLAB Signal Processing Toolbox: eegfilt, findpeaks.
% =========================================================================

clear 
clc
close all
changeCurrentFolder('D:\daniel\Mouse12-120806')
%% read the .EEG file and save all channel

thal_allchanel_Mouse12_120806_new = bz_LoadBinary('Mouse12-120806.eeg','nChannels',90,'frequency',1250);
fs=1250;
save thal_allchanel_Mouse12_120806 -v7.3
OriginalData = thal_allchanel_Mouse12_120806_new;
%% creat NREM EPISOD

ch_number=90;
OriginalData=transpose(OriginalData);
OriginalData=double(OriginalData);

SwsTime = [823.3	1015.1
1327.6	1559.7
3415.9	3899.3
4018.1	4650.6
4833.1	5379.7
5513.2	5527.3
5527.3	6038.1
6133.3	6688.2
9880.2	11424
11911	12632
12672	12818
12839	12927
13042	13791
13971	14761
14783	14900
];

SWSpacket_num = size(SwsTime,1);


SWS_ind = false(1, length(OriginalData));
for i=1:SWSpacket_num
%     start_sample = round(sws(i,1)*fs);
%     stop_sample = round(sws(i,2)*fs);
    start_time = round(SwsTime(i,1)*fs);
    stop_time = round(SwsTime(i,2)*fs);
    SWS_ind(start_time:stop_time) = 1;
end
SWS_episode = OriginalData(:,SWS_ind);

save SWS_episode.mat  SWS_episode -v7.3

%% choose one channel of each shank 
load SWS_episode.mat
ChNum=8;
fs=1250;
DownBand = 0.5;
UpBand = 4;
sws = zeros(ChNum,length(SWS_episode(1,:)));
sws_ch_num = (1:8:64);

for i=1:ChNum
    sws(i, :) = SWS_episode(sws_ch_num(i),:);
end
save SwsIncludeOneChannelOfEachChannels.mat  sws
thal_ch_norm = zeros(size(sws,1),length(SWS_episode(1,:)));

for ii=1:size(sws,1)
    thal_ch_norm(ii,:)=zscore(sws(ii,:));
end

thal_ch_norm_filtered_ChooseOneChannelFromEachShanks=zeros(size(sws,1),length(SWS_episode(1,:)));

parfor j=1:size(sws,1)
    thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(j,:) = eegfilt(thal_ch_norm(j,:),fs,DownBand,UpBand,0,floor(fs/DownBand)*3,0,'fir1');
    disp(j)
end

save thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat thal_ch_norm_filtered_ChooseOneChannelFromEachShanks

%% Detect and compute delay
load thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat

ch_numbers = size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1);
fs=1250;
nbins=100;

Y = zeros(ch_numbers,length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)));
ISBLIPE = zeros(ch_numbers,length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)));

for i=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
[y,IsBlip]  = SOMolle(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(i,:));
Y(i,:) = y;
ISBLIPE(i,:) = IsBlip;
end

% Create a structure and assign variables
SOdetected.Y = Y;
SOdetected.ISBLIPE = ISBLIPE;
save SOdetectedForChooseOneChannelFromEachShank.mat SOdetected

% delay

ref = ISBLIPE(1,:);
refTime =find(ref==1)/fs;
delay = zeros(ch_numbers,length(refTime(1,:)));
sampBack = fs/2;
sampForward=fs/2;

for ii=2:ch_numbers

    for iii=1:size(refTime,2)
    startsample = round(refTime(iii)*fs)-sampBack;
    endsample = round(refTime(iii)*fs)+sampForward;
    data = thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(ii,startsample:endsample);
    [peaks, locations] = findpeaks(data);

    [maxPeak, maxIndex] = max(peaks);
    
    % Get the corresponding location from the 'locations' data
    maxLocation = locations(maxIndex)+startsample;

    delay(ii,iii) = refTime(iii)-(maxLocation/fs);
%     close(figure(4))
    end
end
% save daleyForOneChannnelOfEachShankBaseOnMaxPeak delay

%% plot avraged signal with its raw data for all channels 
signal = zeros(1,length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)));
t = (1:length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)))/fs;
Colors = ['g','c','y','m','g','r','y','c'];
coef = 1:8;
refsamp = round(refTime*fs);

for i=1:size(refsamp, 2)
    Sback = refsamp(1,i)-sampBack;
    Sforward = refsamp(1,i)+sampForward;
    sample = Sback:Sforward;
    Means = mean( thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(:, sample));
    signal(1,sample)= Means;
end

TimeForward = sampForward/fs;
TimeBack = sampBack/fs;
TimeLimit = (0.2*fs)/fs;

figure
plot(t,(signal),'LineWidth',2,'Color','y')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
hold on 
for k=1:size(refsamp, 2)
xline(refsamp(k)/fs, '--g')
xline((refsamp(k)/fs)+TimeForward,'r')
xline((refsamp(k)/fs)-TimeBack,'r')
xline((refsamp(k)/fs)+TimeLimit,'c')
xline((refsamp(k)/fs)-TimeLimit,'c')
end 

SwS = zeros(1,length(sws(1,:)));

for m=1:size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1)
    SwS = zscore(sws(m,:));
plot (t ,(SwS/fs)+(coef(m)*0.01),Colors(m) )
end 

hold off

%% avrage and ratio between Peak2/peak ref
signalAll = zeros(1,length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)));
refForMean = ISBLIPE(1,:);
refTime =find(refForMean==1)/fs;
refsamp = round(refTime*fs);
delayBetweenPeaks = zeros(1,length(refTime(1,:)));
MeanPeaks = zeros(1,length(refTime(1,:)));
MaxPeak = zeros(1,length(refTime(1,:)));
ratio = zeros(1,length(refTime(1,:)));
sampBack = fs/2;
sampForward = fs/2;
SAMPBACK = round(0.2*fs);
SAMPFORW = round(0.2*fs);
nbin = 100;

for ii=1:size(refsamp, 2)
    Sback = refsamp(1,ii)-sampBack;
    Sforward = refsamp(1,ii)+sampForward;
    sample = Sback:Sforward;
    Means = mean(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(:, sample));
    signalAll(1,sample)= Means;
end

for iii = 1:size(refTime, 2)

    startsample = round(refTime(iii) * fs) - sampBack;
    endsample = round(refTime(iii) * fs) + sampForward;
    data = signalAll(1, startsample:endsample);
    
    [peakAmplitudes, peakLocations] = findpeaks(data);
    centerLocation = peakLocations - sampBack - 1;
    refIndex = find(abs(centerLocation) < SAMPBACK);

    if length(refIndex) > 1
        [~, maxxIndex] = max(peakAmplitudes(refIndex));
        refIndex = refIndex(maxxIndex);
    end

    refpeakAmplitude = peakAmplitudes(refIndex);

    peakAmplitudes(refIndex) = [];
    peakLocations(refIndex) = [];

    [~, sortIndices] = sort(peakAmplitudes);
    sortedPeakAmplitudes = peakAmplitudes(sortIndices);

    if isempty(peakAmplitudes)
        delayBetweenPeaks(1,iii) = NaN;
        ratio(1,iii) = NaN;
    else
    ratio(iii) = sortedPeakAmplitudes(end) / refpeakAmplitude;
    distance = peakLocations(sortIndices(end)) + startsample;
    delayBetweenPeaks(iii) = (distance/fs) - refTime(1, iii);
    end

end

 figure
plot(delayBetweenPeaks, ratio, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'red','MarkerSize',8);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
xlabel('delay(s)')
ylabel('ratio(peak/PEAK) ')
title('For avrage on filtered data', 'Color', 'white')
legend ('peak = second peak and PEAK = first peak (reference peak)','textcolor','white')

figure
histogram(delayBetweenPeaks,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('Delay(s)')
title('Histogram Delays for avrage on filtered data', 'Color', 'white')

figure
histogram(ratio,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('Delay(s)')
title('Histogram peak/Peak for avrage on filtered data ', 'Color', 'white')





% Get handles to all open figures
figHandles = findall(0, 'Type', 'figure');

% Maximize each figure
parfor i = 1:numel(figHandles)
    set(figHandles(i), 'WindowState', 'maximized');
end

eventNum = 58; % event num = 1,9,18,96
T = (round(refTime(eventNum) * fs) - sampBack:round(refTime(eventNum) * fs) + sampForward)/fs;
figure
plot(T,signalAll(1,round(refTime(eventNum) * fs) - sampBack:round(refTime(eventNum) * fs) + sampForward),'y')
xline(refTime(eventNum),'-g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
legend(['ratio = ' num2str(ratio(eventNum)) ], ['delay = ' num2str(delay(eventNum))],'TextColor', 'red', 'Location', 'northwest')
%
% histogram(ratio,nbin,'FaceColor','g')
% set(gca,'fontsize',16,'color',[0 0 0])
% set(groot, 'defaultFigureColor', [0 0 0]);
% set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
% xlabel('ratio')
% title('Histogram ratios ', 'Color', 'white')
%% Histogram of main peak amp

biggestPeakAmplitude = zeros(1,length(refTime(1,:)));
for iii=1:size(refTime,2)
    startsample = round(refTime(iii)*fs)-sampBack;
    endsample = round(refTime(iii)*fs)+sampForward;
    data = signalAll(1,startsample:endsample);
    [peakAmplitudes, peakLocations] = findpeaks(data);

   % Find the index of the biggest peak
    [~, maxPeakIndex] = max(peakAmplitudes);
    % Get the amplitude of the biggest peak
    biggestPeakAmplitude(iii) = peakAmplitudes(maxPeakIndex);
  
 end
figure
histogram(biggestPeakAmplitude,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('Amplitude');
ylabel('Count');
title('Histogram of Amplitude values of the biggest peak','Color','white');
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

for i=1:size(refsamp, 2)    
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

%% for the raw data 
biggestPeakAmplitudeRaw = zeros(1,length(refTime(1,:)));
ratioRaw = zeros (1,length(refTime(1,:)));
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
        ratioRaw(1,iii) = NaN;
    else
    ratioRaw(iii) = sortedPeakAmplitudesRaw(end) / refpeakAmplitude;
    distance = peakLocationsRaw(sortIndices(end)) + startsample;
    delayRaw(iii) = (distance/fs) - refTime(1, iii);
    end

end

 figure
plot(delayRaw, ratioRaw, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'magenta','MarkerSize',8);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
xlabel('delay(s)')
ylabel('ratio(peak/PEAK)')
title('For filtered between 0.5 to 10 HZ', 'Color', 'white')
legend ('peak = second peak and PEAK = first peak (reference peak)','textcolor','white')
%
figure
histogram(ratioRaw,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('Ratio');
ylabel('Count');
title('Histogram of ratio for filtered data between 0.5 to 10 channel','Color','white');
%for test
eventNum = 58; % event num = 1,9,18,96
T = (round(refTime(eventNum) * fs) - sampBack:round(refTime(eventNum) * fs) + sampForward)/fs;
figure
plot(T,signalAll(1,round(refTime(eventNum) * fs) - sampBack:round(refTime(eventNum) * fs) + sampForward),'y')
xline(refTime(eventNum),'-g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
legend(['ratio = ' num2str(ratioRaw(eventNum)) ], ['delay = ' num2str(delay(eventNum))],'TextColor', 'red', 'Location', 'northwest')
%
%% only for refrence channels 
 biggestPeakAmplitudeRaw = zeros(1,length(refTime(1,:)));
ratioRawOneChannel = zeros (1,length(refTime(1,:)));
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
save REFchannelFilteredBetween0.5to10Hz.mat REFchannelFiltered
%%
load REFchannelFilteredBetween0.5to10Hz.mat
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
        ratioRawOneChannel(1,iii) = NaN;
    else
    ratioRawOneChannel(iii) = sortedPeakAmplitudesRaw(end) / refpeakAmplitude;
    distance = peakLocationsRaw(sortIndices(end)) + startsample;
    delayRaw(iii) = (distance/fs) - refTime(1, iii);
    end

end
%save data
SOreferenceChannelDelayAndRatio.delay = delayRaw;
SOreferenceChannelDelayAndRatio.ratio = ratioRawOneChannel;
save SOreferenceChannelDelayAndRatio.mat    SOreferenceChannelDelayAndRatio

 figure
plot(delayRaw, ratioRawOneChannel, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'c','MarkerSize',8);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
xlabel('delay(s)')
ylabel('ratio(peak/PEAK)')
title('For reference channel that filtered between 0.5 to 10 HZ ', 'Color', 'white')
legend ('peak = second peak and PEAK = first peak (reference peak)','textcolor','white')
%
figure
histogram(ratioRawOneChannel,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('Ratio');
ylabel('Count');
title('Histogram of ratio for reference channel','Color','white');

%% plot for test the algorithm 
% 
% eventNum = 1; % event num = 1,9,18,96
% T = (round(refTime(eventNum) * fs) - SampBack:round(refTime(eventNum) * fs) + SampForward)/fs;
% figure
% plot(T,REFchannelFiltered(1,round(refTime(eventNum) * fs) - SampBack:round(refTime(eventNum) * fs) + SampForward),'y')
% xline(refTime(eventNum),'-g')
% set(gca,'fontsize',16,'color',[0 0 0])
% set(groot, 'defaultFigureColor', [0 0 0]);
% set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
% set(gcf, 'Color', 'k');
% legend(['ratio = ' num2str(ratio(eventNum)) ], ['delay = ' num2str(delayRaw(eventNum))],'TextColor', 'red', 'Location', 'northwest')
% %
% histogram(ratio,nbin,'FaceColor','g')
% set(gca,'fontsize',16,'color',[0 0 0])
% set(groot, 'defaultFigureColor', [0 0 0]);
% set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
% xlabel('ratio')
% title('Histogram ratios ', 'Color', 'white')
%% plot 0.5 to 10 and 0.5 to 4 ratios 
 figure
plot(ratioRaw, ratio, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'y','MarkerSize',8);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
xlabel('ratio for 0.5 to 10 Hz(s)')
ylabel('ratio for 0.5 to 4 Hz (s)')

%% plot ratio for reference and mean filtered between 0.5 to 10 Hz
 figure
plot(ratioRaw, ratioRawOneChannel, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'y','MarkerSize',8);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
set(gcf, 'Color', 'k');
xlabel('ratio for mean signal filtered between 0.5 to 10 Hz(s)')
ylabel('ratio for reference 0.5 to 4 Hz (s)')
