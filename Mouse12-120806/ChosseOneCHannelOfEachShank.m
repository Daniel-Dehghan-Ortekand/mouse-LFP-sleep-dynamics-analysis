% =========================================================================
% SCRIPT: Slow Oscillation (SO) Detection and Visualization on Representative Channels
% SUBJECT: Multi-channel Thalamic Recording (8 Representative Shanks)
% =========================================================================
% DESCRIPTION:
% Selects one representative channel from each of the 8 probe shanks 
% (channels 1, 9, 17... 57). The selected channels are z-scored and 
% bandpass filtered between 0.5 and 4 Hz to isolate the Slow Oscillation 
% (SO) frequency band. The script then runs the SOMolle detection algorithm 
% on each filtered channel to identify SO events. Finally, it generates 
% comprehensive visualizations displaying the raw LFP, the filtered SO 
% signal, and the binary SO detection masks, complete with amplitude 
% threshold lines and a custom dark theme.
%
% INPUTS:
%   - SWS_episode_new_90.mat: Raw multi-channel SWS LFP data.
%
% OUTPUTS:
%   - thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat: Z-scored, 
%     0.5-4 Hz bandpass filtered LFP data for the 8 representative channels.
%   - Visualizations: Multi-panel plots showing raw LFP, filtered SO LFP, 
%     and SOMolle detection masks with threshold indicators.
%
% DEPENDENCIES:
%   - Custom function: SOMolle (for Slow Oscillation detection).
%   - MATLAB Signal Processing Toolbox: eegfilt.
% =========================================================================

clc 
close all
clear
%%
load SWS_episode_new_90.mat
ChNum=8;
fs=1250;
DownBand = 0.5;
UpBand = 4;
%% filtering
sws = zeros(ChNum,length(SWS_episode(1,:)));
sws_ch_num = (1:8:64);

for i=1:ChNum
    sws(i, :) = SWS_episode(sws_ch_num(i),:);
end

% sws(all(sws==0, 2), :) = [];

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

%% detection
load thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat
load SWS_episode_new_90.mat

fs=1250;
t=[1:length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks)]./fs;

Y = zeros(size(sws,1),length(SWS_episode(1,:)));
ISBLIPE = zeros(size(sws,1),length(SWS_episode(1,:)));

begins = zeros(size(sws,1),length(SWS_episode(1,:)));
End = zeros(size(sws,1),length(SWS_episode(1,:)));  
peak = zeros(size(sws,1),length(SWS_episode(1,:)));
trough = zeros(size(sws,1),length(SWS_episode(1,:)));

parfor i=1:size(sws,1)
[y,IsBlip]  = SOMolle(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(i,:));
Y(i,:) = y;
ISBLIPE(i,:) = IsBlip;
%   begins(i,:)=find(diff(Y)==1);
%   End(i,:) = find(diff(Y==-1));
%   peak(i,:)=find(ISBLIPE==1);
%   trough(i,:) = find(ISBLIPE==-1);
end
  %% plot 
Colors = ['g','c','y','m','g','r','y','c'];
coefs = 10:20:160;
figure;
hold on
for i=1:size(sws,1)
plot(t,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(i,:)+coefs(i)+4,Colors(i))
% plot (t,y*3,t,IsBlip*3,'LineWidth',2,'Color','r')
plot (t,(Y(i,:)*3)+coefs(i)+4,'LineWidth',2,'Color','white')
plot (t,zscore(SWS_episode(i,:))+coefs(i)-4,Colors(i))
% xlim([1240 1260])
% yline(2+coefs(i)+4, '--g', 'LineWidth', 2);
% yline(-1.5+coefs(i)+4, '--y', 'LineWidth', 2);
yline(1.5+coefs(i)+4, '--g');
yline(-1+coefs(i)+4, '--y');
% %  
% begins=find(diff(y)==1);
% begins2 = find(diff(y==-1));
% peak=find(IsBlip==1);
% trough = find(IsBlip==-1);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
   set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
  end

   figNum=1;
for m = 1:figNum
    figure(m)
%     xlim([400, 500])
    fig = figure(m);
    % Save the figure as a .fig file in the specified path
%     savefig(fig,[path,'figure_',num2str(m),'.fig']);
end
%Once you have plotted them, run the script above to maximize their windows. 
% The get(groot,'Children') command returns a list of all the current figure handles, 
% which are then used to set the window state of each figure to "maximized"
h = get(groot,'Children');
for i=1:length(h)
    set(h(i),'WindowState','maximized');
end
% Get a list of all open figures
figHandles = findall(0,'Type','figure');
%%
 %% plot just filtered data 
Colors = ['g','c','y','m','g','r','y','c'];
coefs = 10:10:80;

figure;
hold on
for i=1:size(sws,1)
plot(t,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(i,:)+coefs(i)+4,Colors(i))
% plot (t,y*3,t,IsBlip*3,'LineWidth',2,'Color','r')
plot (t,(Y(i,:)*3)+coefs(i)+4,'LineWidth',2,'Color','white')
% plot (t,zscore(SWS_episode(i,:))+coefs(i)-4,Colors(i))
% xlim([1240 1260])
% yline(2+coefs(i)+4, '--g', 'LineWidth', 2);
% yline(-1.5+coefs(i)+4, '--y', 'LineWidth', 2);
yline(1.5+coefs(i)+4, '--g');
yline(-1+coefs(i)+4, '--y');
% %  
% begins=find(diff(y)==1);
% begins2 = find(diff(y==-1));
% peak=find(IsBlip==1);
% trough = find(IsBlip==-1);
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
   set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]); 
  end

   figNum=1;
for m = 1:figNum
    figure(m)
%     xlim([400, 500])
    fig = figure(m);
    % Save the figure as a .fig file in the specified path
%     savefig(fig,[path,'figure_',num2str(m),'.fig']);
end
%Once you have plotted them, run the script above to maximize their windows. 
% The get(groot,'Children') command returns a list of all the current figure handles, 
% which are then used to set the window state of each figure to "maximized"
h = get(groot,'Children');
for i=1:length(h)
    set(h(i),'WindowState','maximized');
end
% Get a list of all open figures
figHandles = findall(0,'Type','figure');

ax = axes;
%Define the speed and range of movement 
speed = 0.1;
range = 5;


