% =========================================================================
% SCRIPT: Slow Oscillation (SO) Global/Local Classification & Delay Visualization
% SUBJECT: Multi-channel Thalamic Recording (8 Shanks)
% =========================================================================
% DESCRIPTION:
% Analyzes the spatiotemporal propagation of Slow Oscillations (SOs) across 
% 8 representative thalamic channels. It classifies each detected SO as 
% "Global" (if the propagation delay is < 0.2s on at least 7 channels) or 
% "Local". The script computes and plots the spatially averaged LFP waveforms 
% time-locked to Local SO events. It then analyzes the population mean signal 
% to extract secondary peak delays and amplitude ratios. Finally, it isolates 
% and visually inspects specific SO events exhibiting extreme positive or 
% negative propagation delays to characterize atypical propagation patterns.
%
% INPUTS:
%   - thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat: Filtered LFP 
%     data (one representative channel per shank).
%   - daleyForOneChannnelOfEachShank.mat: Precomputed inter-channel delays.
%   - SWS_episode_new_90.mat: Raw SWS LFP data.
%
% OUTPUTS:
%   - Visualizations: 
%       1. Average LFP waveforms for Local SOs across 8 channels.
%       2. Continuous population mean signal with event markers.
%       3. Histograms of delays and peak amplitudes.
%       4. Scatter plot of secondary peak ratios vs. delays.
%       5. Detailed visual inspections of 6 extreme positive and 6 extreme 
%          negative delay events.
%
% DEPENDENCIES:
%   - Custom function: SOMolle (for Slow Oscillation detection).
%   - MATLAB Signal Processing Toolbox: findpeaks.
% =========================================================================


clear
% close all 
%%
load thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat
load daleyForOneChannnelOfEachShank
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
%% detect GLobal and Local 
ref = ISBLIPE(1,:);
refTime =find(ref==1)/fs;
GlobalBorder = 7;
count = zeros(1, size(refTime,2));
Global = zeros(1, size(refTime,2));
Local = zeros(1, size(refTime,2));


for i=1:size(refTime,2)
    if sum(abs(delay(:,i)) < 0.2) >= GlobalBorder
        Global(i) = refTime(i);
    else
        Local(i) = refTime(i);
    end
end

GLobref = find(Global>0);
GLobrefTime = Global(GLobref);
globrefsamp = round(GLobrefTime*fs);

Locref = find(Local>0);
LocrefTime = Local(Locref);
Locrefsamp = round(LocrefTime*fs);


%% mean 

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

%% avrage
signalAll = zeros(1,length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,:)));
refForMean = ISBLIPE(1,:);
refTime =find(refForMean==1)/fs;
refsamp = round(refTime*fs);
delayForMean = zeros(1,length(refTime(1,:)));
MeanPeaks = zeros(1,length(refTime(1,:)));

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
%     figure
%     plot(data)
%     hold on
%     plot(locations,peaks,'*k')
    % Find the index of the maximum peak in the 'peaks' data
    [minPeak, minIndex] = min(locations);
    
    % Get the corresponding location from the 'locations' data
    minLocation = locations(minIndex)+startsample;

    delayForMean(1,iii) = refTime(iii)-(minLocation/fs);
    MeanPeaks(iii) = minPeak;
%     close(figure(4))
    end
figure
histogram(delay,nbin,'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('Delay')
title('Histogram Delays ', 'Color', 'white')

figure
histogram(MeanPeaks,nbin,'FaceColor','y')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
xlabel('MeanPeaks')
title('Histogram MeanPeaks ', 'Color', 'white')
%% figure base on event 
for k = 1:20%size(refsamp,2)
figure
plot(t,(signalAll),'LineWidth',2,'Color','y')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
hold on 
 
xline(refsamp(k)/fs, '--g')
% xline((refsamp(k)/fs)+1,'r')
% xline((refsamp(k)/fs)-1,'r')
% xline((refsamp(k)/fs)+0.2,'c')
% xline((refsamp(k)/fs)-0.2,'c')
 
SwS = zeros(1,length(sws(1,:)));
for m=1:3
    SwS = zscore(sws(m,:));
plot (t ,(SwS/fs)+coef(m)+4,Colors(m) )
end 

hold off
xlim([(refsamp(k)/fs)-5  (refsamp(k)/fs)+5])
end
% Get handles to all open figures
figHandles = findall(0, 'Type', 'figure');

% Maximize each figure
for i = 1:numel(figHandles)
    set(figHandles(i), 'WindowState', 'maximized');
end
%% plot hist base on devide nearest peak/ so peak 
rater = zeros(1,length(refTime(1,:)));
  for iii=1:size(refTime,2)
    startsample = round(refTime(iii)*fs)-SampBack;
    endsample = round(refTime(iii)*fs)+SampForward;
    data = signalAll(1,startsample:endsample);
    [peaks, locations] = findpeaks(data);

    % Find max
%     [~, maxIndex] = max(peaks);
    maxIndex = find(locations > 500 & locations < 700);

    % Find the index of the maximum peak in the 'peaks' data
    [sortPeak, sortIndex] = sort(abs(locations-locations(maxIndex)));
    
    if length(sortIndex)<2
        
        delayForMean(1,iii) = NaN;
        rater(1,iii) = NaN;

    else

        minIndex = sortIndex(2);

        % Get the corresponding location from the 'locations' data
        minLocation = locations(minIndex)+startsample;
    
        delayForMean(1,iii) = refTime(iii)-(minLocation/fs);
        rater(1,iii) = minPeak/refTime(iii); 
    end 
    
    
  
  end
figure
plot(rater, delayForMean, 'Color', 'y', 'Marker', 'o', 'LineStyle', 'none', 'MarkerFaceColor', 'green','MarkerSize',8);
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


%% plot

Coefs = 1:5:40;
count = 6;
positive_index = find(delayForMean > 0.4, count);
% zero_index = find(delayForMean < 0.01 & delayForMean > -0.01, count);
negetive_index = find(delayForMean < -0.35, count);

for i = 1:count

    % pos
    figure
    iii = positive_index(i);
    startsample = round(refTime(iii)*fs)-SampBack;
    endsample = round(refTime(iii)*fs)+SampForward;
    data = signalAll(1,startsample:endsample);
    t1 =(startsample : endsample)/fs;
    plot(t1,data,'LineWidth',2,'Color','y')
    hold on 
    plot (t1,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,startsample:endsample)-Coefs(1)+4,'g')
    [~, locations] = findpeaks(data);
    plot(t1(locations), data(locations)+0.1, 'vy', 'MarkerFaceColor', 'y')

 
    xline(refsamp(iii)/fs, '--g')
     
    SwS = zeros(1,length(sws(1,:)));
    for m=1:3
        SwS = zscore(sws(m,:));
        plot (t1,SwS(startsample:endsample)+Coefs(m)+8,Colors(m) )
    end 
    

    title(['delay = ' num2str(delayForMean(iii)) ' , rate = ' num2str(rater(iii))])
    set(gca,'fontsize',16,'color',[0 0 0])
    set(groot, 'defaultFigureColor', [0 0 0]);
    set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
    hold off

end


% for i = 1:count
% 
%     % zero
%     figure
%     iii = zero_index(i);
%     startsample = round(refTime(iii)*fs)-SampBack;
%     endsample = round(refTime(iii)*fs)+SampForward;
%     data = signalAll(1,startsample:endsample);
%     findpeaks(data);
% 
% end


for i = 1:count

    % neg
    figure
    iii = negetive_index(i);
    startsample = round(refTime(iii)*fs)-SampBack;
    endsample = round(refTime(iii)*fs)+SampForward;
    data = signalAll(1,startsample:endsample);
    findpeaks(data);
    t1 =(startsample : endsample)/fs;
    plot(t1,data,'LineWidth',2,'Color','y')
    hold on 
    plot (t1,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(1,startsample:endsample)-Coefs(1)-4,'g')
    [~, locations] = findpeaks(data);
    plot(t1(locations), data(locations)+0.1, 'vy', 'MarkerFaceColor', 'y')
    plot (t1,SwS(1:startsample:endsample)-Coefs(2)-4,Colors(m) )

 
    xline(refsamp(iii)/fs, '--g')
     
    SwS = zeros(1,length(sws(1,:)));
    for m=1:3
        SwS = zscore(sws(m,:));
        plot (t1,SwS(startsample:endsample)+Coefs(m)+8,Colors(m) )
    end 
    

    title(['delay = ' num2str(delayForMean(iii)) ' , rate = ' num2str(rater(iii))])
    set(gca,'fontsize',16,'color',[0 0 0])
    set(groot, 'defaultFigureColor', [0 0 0]);
    set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
    hold off

end
