% =========================================================================
% SCRIPT: Classify and Visualize Slow Oscillation (SO) Global vs. Local Propagation
% SUBJECT: Multi-channel Thalamic Recording (8 Representative Shanks)
% =========================================================================
% DESCRIPTION:
% Analyzes the spatiotemporal propagation of Slow Oscillations (SOs) across 
% 8 representative thalamic channels. After detecting SOs using the SOMolle 
% algorithm, the script classifies each event as "Global" or "Local" based 
% on a spatial propagation criterion: an SO is defined as Global if its peak 
% is detected on at least 7 out of 8 channels within a 0.2-second window. 
% The script generates a comprehensive multi-panel visualization displaying 
% the filtered LFP, the binary SOMolle detection mask, and the raw LFP for 
% all 8 shanks. It overlays text markers ('G' for Global, 'L' for Local) 
% and vertical lines indicating the temporal classification windows directly 
% on the reference channel's trace.
%
% INPUTS:
%   - thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat: Z-scored, 
%     0.5-4 Hz bandpass filtered LFP data for the 8 representative channels.
%   - daleyForOneChannnelOfEachShank.mat: Precomputed inter-channel SO 
%     propagation delays relative to the reference channel.
%   - SWS_episode_new_90.mat: Raw continuous SWS LFP data.
%
% OUTPUTS:
%   - Visualizations: Multi-panel plot showing raw LFP, filtered SO LFP, 
%     and SOMolle detection masks for 8 channels, with overlaid Global/Local 
%     classification markers and temporal window indicators.
%
% DEPENDENCIES:
%   - Custom function: SOMolle (for Slow Oscillation detection).
% =========================================================================

clc 
clear 
close all
%% pre-process
load thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat
load daleyForOneChannnelOfEachShank
load SWS_episode_new_90.mat

ch_number = size(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks,1);
fs=1250;
ChNum=8;
sws = zeros(ChNum,length(SWS_episode(1,:)));


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
Global = zeros(1, size(refTime,2));
Local = zeros(1, size(refTime,2));


for i=1:size(refTime,2)
    if sum(abs(delay(:,i)) < 0.2) >= GlobalBorder
        Global(i) = refTime(i);
    else
        Local(i) = refTime(i);
    end
end

%% plot 
t=[1:length(thal_ch_norm_filtered_ChooseOneChannelFromEachShanks)]./fs;
Colors = ['g','c','y','m','g','r','y','c'];
coefs = 10:20:160;
GLobref = find(Global>0);
GLobrefTime = Global(GLobref);
globrefsamp = round(GLobrefTime*fs);

Locref = find(Local>0);
LocrefTime = Local(Locref);
Locrefsamp = round(LocrefTime*fs);

sws_ch_num = (1:8:64);
for i=1:ChNum
    sws(i, :) = SWS_episode(sws_ch_num(i),:);
end


figure;
hold on
for i=1:size(sws,1)
plot(t,thal_ch_norm_filtered_ChooseOneChannelFromEachShanks(i,:)+coefs(i)+4,Colors(i))
% plot (t,y*3,t,IsBlip*3,'LineWidth',2,'Color','r')
plot (t,(Y(i,:)*3)+coefs(i)+4,'LineWidth',2,'Color','white')
plot (t,zscore(sws(i,:))+coefs(i)-4,Colors(i))
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
if i == 1
    for j=1:length(globrefsamp)
        text (globrefsamp(j)/fs ,coefs(i)+10,'G','FontSize',14,'FontWeight','bold','Color','y')
    end

    for k = 1:length(Locrefsamp)
        text (Locrefsamp(k)/fs ,coefs(i)+10,'L','FontSize',14,'FontWeight','bold','Color','y')
        xline(Locrefsamp(k)/fs, '--g');
        xline((Locrefsamp(k)/fs)+1,'r')
        xline((Locrefsamp(k)/fs)-1,'r')
        xline((Locrefsamp(k)/fs)+0.2,'c')
        xline((Locrefsamp(k)/fs)-0.2,'c')
    end

end
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

hold off

