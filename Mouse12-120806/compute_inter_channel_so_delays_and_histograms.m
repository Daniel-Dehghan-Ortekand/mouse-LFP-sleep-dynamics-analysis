
% =========================================================================
% SCRIPT: Compute Slow Oscillation (SO) Propagation Delays and Spatial Distribution
% SUBJECT: Multi-channel Thalamic Recording (Representative Shanks)
% =========================================================================
% DESCRIPTION:
% Analyzes the spatiotemporal propagation of Slow Oscillations (SOs) across 
% 8 representative thalamic channels. After detecting SOs using the SOMolle 
% algorithm, it calculates the propagation delay for each channel relative 
% to a reference channel (Channel 1) by finding the maximum peak within a 
% 1-second window around each reference SO event. The script then evaluates 
% the spatial distribution of SOs by counting how many channels detect an 
% SO within a 0.2-second temporal window for each event. Finally, it 
% generates a histogram of this spatial distribution and individual delay 
% histograms for each non-reference channel.
%
% INPUTS:
%   - thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat: Z-scored, 
%     0.5-4 Hz bandpass filtered LFP data for the 8 representative channels.
%
% OUTPUTS:
%   - daleyForOneChannnelOfEachShank.mat: A matrix (Channels x SO_events) 
%     containing the propagation delays relative to the reference channel.
%   - Visualizations: 
%       1. Histogram of the spatial distribution of SOs (number of channels 
%          detecting an SO within a 0.2s window).
%       2. Individual delay histograms for channels 2 through 8.
%
% DEPENDENCIES:
%   - Custom function: SOMolle (for Slow Oscillation detection).
%   - MATLAB Signal Processing Toolbox: findpeaks.
% =========================================================================
clc 
clear
% close all
%%
load thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat

ch_number = size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1);
fs=1250;
nbins=100;

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
%% delay
% in code dige code nemishe!!!!!!!!
% kojaaaaaaaayi?
ref = ISBLIPE(1,:);
refTime =find(ref==1)/fs;
delay = zeros(ch_number,length(refTime(1,:)));
sampBack = fs/2;
sampForward=fs/2;

for ii=2:ch_number

    for iii=1:size(refTime,2)
    startsample = round(refTime(iii)*fs)-sampBack;
    endsample = round(refTime(iii)*fs)+sampForward;
    data = thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(ii,startsample:endsample);
    [peaks, locations] = findpeaks(data);
%     figure
%     plot(data)
%     hold on
%     plot(locations,peaks,'*k')
    % Find the index of the maximum peak in the 'peaks' data
    [maxPeak, maxIndex] = max(peaks);
    
    % Get the corresponding location from the 'locations' data
    maxLocation = locations(maxIndex)+startsample;

    delay(ii,iii) = refTime(iii)-(maxLocation/fs);
%     close(figure(4))
    end
end
save daleyForOneChannnelOfEachShank delay
 %%  SOs distribution in all channels  

count = zeros(1, size(refTime,2));
for i=1:size(refTime,2)
    count(i) = sum(abs(delay(:,i)) < 0.2);
end

figure
histogram(count,(0:9),'FaceColor','g')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
% % Get a handle to the histogram object
% h = histogram(count,(0:9),'FaceColor','g');
% 
% % Change the border color
% h.EdgeColor = 'y';  % You can specify any valid color name or RGB values
% 
% % Refresh the plot
% drawnow

xlabel('channels count  ')
title('Histogram of channels count', 'Color', 'white')



    
%% Histogram
for j=2: size(delay,1)

    figure
    histogram(delay(j,:),nbins,'FaceColor','y')
    
    xlabel('time(s)')
    title(['delay for channel ' num2str(j)], 'Color', 'white')

%     xlim([-0.1 0.1])
    set(gca,'fontsize',16,'color',[0 0 0])
    set(groot, 'defaultFigureColor', [0 0 0]);
    set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
    
end
h = get(groot,'Children');
for i=1:length(h)
    set(h(i),'WindowState','maximized');
end
