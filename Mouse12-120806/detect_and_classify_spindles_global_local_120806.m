% =========================================================================
% SCRIPT: Sleep Spindle Detection and Global/Local Classification
% SUBJECT: Mouse12-120806
% =========================================================================
% DESCRIPTION:
% Processes multi-channel thalamic LFP data during Slow-Wave Sleep (SWS) 
% to detect sleep spindles (7-15 Hz) and classify them as "Global" or 
% "Local". It employs two distinct classification methods: 
% 1) A spatial overlap method (based on Yuval Nir's approach) evaluating 
%    simultaneous spindle presence across all channels, within single 
%    shanks, and across specific channels. 
% 2) A population amplitude method, which computes the spatial mean of a 
%    binary spindle mask and classifies events based on whether their mean 
%    population amplitude exceeds a specific threshold (0.76) on the 
%    reference channel.
%
% INPUTS:
%   - SWS_episode_new_90.mat: Raw multi-channel SWS LFP data.
%
% OUTPUTS:
%   - thal_ch_norm_filtered.mat: Z-scored, 7-15 Hz bandpass filtered data.
%   - thal_spindles_ch[X].mat: Detected spindle events per channel.
%   - real_peaks[X].mat: Peak amplitude indices per channel.
%   - meansSignalForMethode2ToSeprate.mat: Population spindle probability signal.
%   - sepratedSpindles120806.mat: Structure containing the reference channel 
%     and classified Global/Local spindles and peaks.
%
% DEPENDENCIES:
%   - Custom function: find_spindles (for initial spindle detection).
%   - MATLAB Signal Processing Toolbox: eegfilt.
% =========================================================================

%% section zero :body 
clc
clear
% close all
fs=1250;
ch_number=64;
%up and down frequency for data filtering in SECTION one : pre-processing
up_freq=15;
down_freq=7;
%start and end time for demonstrate event in section four:resualt
start_time=0.1;
end_time=20;
%spindle_event provide number of spindles pick on indivisual channels in the section four:resualt with '*' sign
spindle_event=20;
%read data and craet new thal_ch.mat
load ('thal_ch_norm_filtered.mat')
% thal_allchanel_Mouse12_120806=double(thal_allchanel_Mouse12_120806);
%% SECTION one : pre-processing 
% thal_ch=transpose(NREM_episode);
%data filtering & normalization
load('SWS_episode_new_90.mat')
k= [19 20 21];
SWS_episode = SWS_episode(1:64,:);
SWS_episode(k,:) =[] ;
ch_number = size(SWS_episode, 1);
figure
hold on 
for i=1:ch_number
plot(zscore(SWS_episode(i,:))+10*i)
end
%

thal_ch_norm=zeros(ch_number,length(SWS_episode(1,:)));
for i=1:ch_number
    thal_ch_norm(i,:)=zscore(SWS_episode(i,:));
end
%     save thal_ch_norm.mat thal_ch_norm -v7.3
thal_ch_norm_filtered=zeros(ch_number,length(SWS_episode(1,:)));
for j=1:ch_number
    disp (j)
thal_ch_norm_filtered(j,:) = eegfilt(thal_ch_norm(j,:),fs,down_freq,up_freq,0,floor(fs/down_freq)*3,0,'fir1');
end
   save thal_ch_norm_filtered.mat thal_ch_norm_filtered -v7.3

%% spindle detection 
% load('thal_ch_norm.mat')
% load('thal_ch_norm_filtered.mat')
t=((1:length(thal_ch_norm_filtered(1,:))))/fs; %time
samples=zeros(length(SWS_episode(1,:)),2);
samples(:,1)=t;
for k=1:ch_number
    samples(:,2)=thal_ch_norm_filtered(k,:);
    thal_spindles = find_spindles(samples,2,'threshold',2.5, 'peak',4,'durations',[500 3000]);
      save (['thal_spindles_ch' num2str(k) '.mat'],'thal_spindles') 
end
%% SECTION three : find pick
for m=1:ch_number
   load  (['thal_spindles_ch' num2str(m) '.mat'])
   onset=thal_spindles(:,1);
   offset=thal_spindles(:,3);
   onset_ind=round(onset*fs);
   offset_ind=round(offset*fs);
   real_peaks=zeros(2,length(onset_ind));
   for n=1:length(onset_ind)
       thal_ch_norm_filtered_sample=thal_ch_norm_filtered(m,onset_ind(n):offset_ind(n));
         [pks,locs] = max(thal_ch_norm_filtered_sample);
         real_peaks(:,n)=[pks locs+onset_ind(n)-1];

   end
    save (['real_peaks' num2str(m) '.mat'],'real_peaks') 


end 
%% section four:resualt
% load('thal_ch_norm_filtered.mat') 
figure
hold on
for i=1:ch_number
   load  (['thal_spindles_ch' num2str(i) '.mat'])
%    load (['real_peaks' num2str(i) '.mat'],'real_peaks')
   start_sample=start_time*fs;
   end_sample= end_time*fs;
   t1=(start_sample:end_sample)/fs;
   thal_ch_norm_filtered_sample = thal_ch_norm_filtered(i,start_sample:end_sample);
   sws_sample = SWS_episode(i,start_sample:end_sample);
   plot (t1,thal_ch_norm_filtered_sample+(2*i),'y')
   plot (t1,zscore(sws_sample)+(1*i),'g')
   title('Spindles for 70 chanel in thalamus and hipocamp')
   xlabel('time(ms)')
   ylabel('Chanels')
   set(gca,'fontsize',16, 'color', [0 0 0 ]);
   
% %    for j=1:spindle_event
% %          t2=[thal_spindles(j,1),thal_spindles(j,3)];
% %          plot(t2,[real_peaks(1,j)+(1*i) real_peaks(1,j)+(1*i)],'k')
% %           plot(real_peaks(2,j)/fs,real_peaks(1,j)+(1*i),'*k')
% %    end
      for j=1:spindle_event
%              t2=[thal_spindles(j,1),thal_spindles(j,3)];
%              plot(t2,[real_peaks(1,j)+(1*i) real_peaks(1,j)+(1*i)],'k')
              plot(thal_spindles(j,1),thal_ch_norm_filtered(i,round(thal_spindles(j,1)*fs))+(2*i),'*r')
              plot(thal_spindles(j,3),thal_ch_norm_filtered(i,round(thal_spindles(j,3)*fs))+(2*i),'*m')

       end
   
 end
                                               

%% for one shank 
%  load('thal_ch_norm_filtered.mat') 

figure
 hold on
% start_time=1175.5;
% end_time=1176.5;
spindle_event = size(thal_spindles,1);
for i=1:8
    load  (['thal_spindles_ch' num2str(i) '.mat'])
%    load (['real_peaks' num2str(i) '.mat'],'real_peaks')
   start_sample=start_time*fs;
   end_sample=end_time*fs;
   t1=(1:length(thal_ch_norm_filtered(1,:)))/fs;
   thal_ch_norm_filtered_sample=thal_ch_norm_filtered(i,:);
    plot (t1,thal_ch_norm_filtered_sample+(1*i),'b')
     % plot (t1,thal_ch_norm_filtered_sample)
   title('Spindles for 70 chanel in thalamus')
   xlabel('time(ms)')
   ylabel('Chanels')
   set(gca,'fontsize',16)
   hold on 
   for j=1:spindle_event
         t2=[thal_spindles(j,1),thal_spindles(j,3)];
%          plot(t2,[real_peaks(1,j)+(1*i) real_peaks(1,j)+(1*i)],'k')
          plot(real_peaks(2,j)/fs,real_peaks(1,j)+(1*i),'*k')
   end
   
end

%%

% hold on 
% t1=(start_sample:end_sample)/fs;
%      start_sample=start_time*fs;
%    end_sample=end_time*fs;
% for i=ch_number
% 
% t1=(start_sample:end_sample)/fs;
%    plot (t1,thal_ch_norm_filtered_sample(i,:))
% end 
%%
% % load('thal_ch_norm_filtered.mat') 
% % 
% % load  (['thal_spindles_ch' num2str(1) '.mat'])
% % figure
% % hold on
%% plot base on events 
spindle_event = 10;
ch_number = 61;
fs=1250;
for k=1:spindle_event
    figure
    hold on
    for i=1:ch_number
    %    load (['real_peaks' num2str(i) '.mat'],'real_peaks')
        load  (['thal_spindles_ch' num2str(1) '.mat'])

       start_sample=(thal_spindles(k,1)-1.5)*fs;
       end_sample= (thal_spindles(k,3)+1.5)*fs;
       t1=(start_sample:end_sample)/fs;
       thal_ch_norm_filtered_sample = thal_ch_norm_filtered(i,start_sample:end_sample);
       sws_sample = 0.5*(zscore(SWS_episode(i,start_sample:end_sample)));
       plot (t1,thal_ch_norm_filtered_sample+(3*i),'y')
       plot (t1,sws_sample+(3*i)-1.5,'g')
       
       
    % %    for j=1:spindle_event
    % %          t2=[thal_spindles(j,1),thal_spindles(j,3)];
    % %          plot(t2,[real_peaks(1,j)+(1*i) real_peaks(1,j)+(1*i)],'k')
    % %           plot(real_peaks(2,j)/fs,real_peaks(1,j)+(1*i),'*k')
    % %    end
%         for j=1:1
    %              t2=[thal_spindles(j,1),thal_spindles(j,3)];
    %              plot(t2,[real_peaks(1,j)+(1*i) real_peaks(1,j)+(1*i)],'k')
                    load  (['thal_spindles_ch' num2str(i) '.mat'])
                    s_ind = find(thal_spindles(:, 1) > start_sample/fs & thal_spindles(:, 3) < end_sample/fs, 1, "first");

                    if ~isempty(s_ind)
                      plot(thal_spindles(s_ind,1),thal_ch_norm_filtered(i,round(thal_spindles(s_ind,1)*fs))+(3*i),'*r')
                      plot(thal_spindles(s_ind,3),thal_ch_norm_filtered(i,round(thal_spindles(s_ind,3)*fs))+(3*i),'*m')
                    end
%            end
       
    end

    title(['Spindles for 64 chanel in thalamus event number ' num2str(k)])
    xlabel('time(ms)')
    ylabel('Chanels')
    set(gca,'fontsize',16, 'color', [0 0 0 ]);
end 

%%
%% plot base on events 
spindle_event = 10;
for k=1:spindle_event
    figure
    hold on
    for i=1:8:ch_number
    %    load (['real_peaks' num2str(i) '.mat'],'real_peaks')
        load  (['thal_spindles_ch' num2str(1) '.mat'])

       start_sample=(thal_spindles(k,1)-1.5)*fs;
       end_sample= (thal_spindles(k,3)+1.5)*fs;
       t1=(start_sample:end_sample)/fs;
       thal_ch_norm_filtered_sample = thal_ch_norm_filtered(i,start_sample:end_sample);
       sws_sample = 0.5*(zscore(SWS_episode(i,start_sample:end_sample)));
       plot (t1,thal_ch_norm_filtered_sample+(i),'y')
       plot (t1,sws_sample+(i)-1.5,'g')
       
       
    % %    for j=1:spindle_event
    % %          t2=[thal_spindles(j,1),thal_spindles(j,3)];
    % %          plot(t2,[real_peaks(1,j)+(1*i) real_peaks(1,j)+(1*i)],'k')
    % %           plot(real_peaks(2,j)/fs,real_peaks(1,j)+(1*i),'*k')
    % %    end
%         for j=1:1
    %              t2=[thal_spindles(j,1),thal_spindles(j,3)];
    %              plot(t2,[real_peaks(1,j)+(1*i) real_peaks(1,j)+(1*i)],'k')
                    load  (['thal_spindles_ch' num2str(i) '.mat'])
                    s_ind = find(thal_spindles(:, 1) > start_sample/fs & thal_spindles(:, 3) < end_sample/fs, 1, "first");

                    if ~isempty(s_ind)
                      plot(thal_spindles(s_ind,1),thal_ch_norm_filtered(i,round(thal_spindles(s_ind,1)*fs))+(i),'*r')
                      plot(thal_spindles(s_ind,3),thal_ch_norm_filtered(i,round(thal_spindles(s_ind,3)*fs))+(i),'*m')
                    end
%            end
       
    end

    title(['Spindles for 64 chanel in thalamus event number ' num2str(k)])
    xlabel('time(ms)')
    ylabel('Chanels')
    set(gca,'fontsize',16, 'color', [0 0 0 ]);
end 
%% local and global base on yuval nier method 

TH = 32;
ch_number = 64;
load  (['thal_spindles_ch' num2str(1) '.mat'])
ref  = thal_spindles;
SpindleEvents = size(ref,1);
GlobalEvent = zeros(size(ref,1),size(ref,2));
LocalEvent = zeros(size(ref,1),size(ref,2));
for i=1:SpindleEvents
    count = 0;
    for j=2:ch_number
        load  (['thal_spindles_ch' num2str(j) '.mat']) 
        condition1 = thal_spindles(:,3) - ref(i,1);
        condition2 = ref(i,3) - thal_spindles(:,1);
        index = find(condition1 > 0 & condition2 > 0);

        if  ~isempty(index)
            count = count+1;    
        end
       
    end
    if count > TH
        GlobalEvent(i,:) = ref(i,:);
    else
        LocalEvent(i,:) = ref(i,:);
    end
end 
GlobalEvent(all(GlobalEvent==0,2),:)=[];
LocalEvent(all(LocalEvent==0,2),:)=[];

globPercent = (length(GlobalEvent)/SpindleEvents)*100
locpercent = (length(LocalEvent)/SpindleEvents)*100



%% for one Channel 


TH = 4;
ch_number_inSHank = 8;
load  (['thal_spindles_ch' num2str(1) '.mat'])
ref  = thal_spindles;
SpindleEvents = size(ref,1);
GlobalEventInShank = zeros(size(ref,1),size(ref,2));
LocalEventInShank = zeros(size(ref,1),size(ref,2));
for i=1:SpindleEvents
    count = 0;
    for j=2:ch_number_inSHank
        load  (['thal_spindles_ch' num2str(j) '.mat']) 
        condition1 = thal_spindles(:,3) - ref(i,1);
        condition2 = ref(i,3) - thal_spindles(:,1);
        index = find(condition1 > 0 & condition2 > 0);

        if  ~isempty(index)
            count = count+1;    
        end
       
    end
    if count > TH
        GlobalEventInShank(i,:) = ref(i,:);
    else
        LocalEventInShank(i,:) = ref(i,:);
    end
end 
GlobalEventInShank(all(GlobalEventInShank==0,2),:)=[];
LocalEventInShank(all(LocalEventInShank==0,2),:)=[];

globPercentOneShank = (length(GlobalEventInShank)/SpindleEvents)*100
locpercentOneShank = (length(LocalEventInShank)/SpindleEvents)*100
%%
%
spindle_event = 10;
for k=1:spindle_event
    figure
    hold on
    for i=1:ch_number_inSHank
    %    load (['real_peaks' num2str(i) '.mat'],'real_peaks')
        load  (['thal_spindles_ch' num2str(1) '.mat'])

       start_sample=(thal_spindles(k,1)-1.5)*fs;
       end_sample= (thal_spindles(k,3)+1.5)*fs;
       t1=(start_sample:end_sample)/fs;
       thal_ch_norm_filtered_sample = thal_ch_norm_filtered(i,start_sample:end_sample);
       sws_sample = 0.5*(zscore(SWS_episode(i,start_sample:end_sample)));
       plot (t1,thal_ch_norm_filtered_sample+(3*i),'y')
       plot (t1,sws_sample+(3*i)-1.5,'g')
       
       
    % %    for j=1:spindle_event
    % %          t2=[thal_spindles(j,1),thal_spindles(j,3)];
    % %          plot(t2,[real_peaks(1,j)+(1*i) real_peaks(1,j)+(1*i)],'k')
    % %           plot(real_peaks(2,j)/fs,real_peaks(1,j)+(1*i),'*k')
    % %    end
%         for j=1:1
    %              t2=[thal_spindles(j,1),thal_spindles(j,3)];
    %              plot(t2,[real_peaks(1,j)+(1*i) real_peaks(1,j)+(1*i)],'k')
                    load  (['thal_spindles_ch' num2str(i) '.mat'])
                    s_ind = find(thal_spindles(:, 1) > start_sample/fs & thal_spindles(:, 3) < end_sample/fs, 1, "first");

                    if ~isempty(s_ind)
                      plot(thal_spindles(s_ind,1),thal_ch_norm_filtered(i,round(thal_spindles(s_ind,1)*fs))+(3*i),'*r')
                      plot(thal_spindles(s_ind,3),thal_ch_norm_filtered(i,round(thal_spindles(s_ind,3)*fs))+(3*i),'*m')
                    end
%            end
       
    end

    title(['Spindles for 8 chanel in thalamus for first shank ' num2str(k)])
    xlabel('time(ms)')
    ylabel('Chanels')
    set(gca,'fontsize',16, 'color', [0 0 0 ]);
end 

%% between channels 



TH = 4;
ch_number = 8;
load  (['thal_spindles_ch' num2str(1) '.mat'])
ref  = thal_spindles;
SpindleEvents = size(ref,1);
GlobalEventBetweenchannels = zeros(size(ref,1),size(ref,2));
LocalEventBetweenchannels = zeros(size(ref,1),size(ref,2));
for i=1:SpindleEvents
    count = 0;
    for j=2:8:ch_number
        load  (['thal_spindles_ch' num2str(j) '.mat']) 
        condition1 = thal_spindles(:,3) - ref(i,1);
        condition2 = ref(i,3) - thal_spindles(:,1);
        index = find(condition1 > 0 & condition2 > 0);

        if  ~isempty(index)
            count = count+1;    
        end
       
    end
    if count > TH
        GlobalEventBetweenchannels(i,:) = ref(i,:);
    else
        LocalEventBetweenchannels(i,:) = ref(i,:);
    end
end 

GlobalEventInShank(all(GlobalEventBetweenchannels==0,2),:)=[];
LocalEventInShank(all(LocalEventBetweenchannels==0,2),:)=[];
%
globPercentBetweenchannels = (length(GlobalEventInShank)/SpindleEvents)*100
locpercentbetweenchannels  = (length(LocalEventInShank)/SpindleEvents)*100

ch_number = 64;

%plot base on events 
spindle_event = 20;
for k=1:spindle_event
    figure
    hold on
    for i=1:8:ch_number
    %    load (['real_peaks' num2str(i) '.mat'],'real_peaks')
        load  (['thal_spindles_ch' num2str(1) '.mat'])

       start_sample=(thal_spindles(k,1)-1.5)*fs;
       end_sample= (thal_spindles(k,3)+1.5)*fs;
       t1=(start_sample:end_sample)/fs;
       thal_ch_norm_filtered_sample = thal_ch_norm_filtered(i,start_sample:end_sample);
       sws_sample = 0.5*(zscore(SWS_episode(i,start_sample:end_sample)));
       plot (t1,thal_ch_norm_filtered_sample+(i),'y')
       plot (t1,sws_sample+(i)-1.5,'g')
       
       
    % %    for j=1:spindle_event
    % %          t2=[thal_spindles(j,1),thal_spindles(j,3)];
    % %          plot(t2,[real_peaks(1,j)+(1*i) real_peaks(1,j)+(1*i)],'k')
    % %           plot(real_peaks(2,j)/fs,real_peaks(1,j)+(1*i),'*k')
    % %    end
%         for j=1:1
    %              t2=[thal_spindles(j,1),thal_spindles(j,3)];
    %              plot(t2,[real_peaks(1,j)+(1*i) real_peaks(1,j)+(1*i)],'k')
                    load  (['thal_spindles_ch' num2str(i) '.mat'])
                    s_ind = find(thal_spindles(:, 1) > start_sample/fs & thal_spindles(:, 3) < end_sample/fs, 1, "first");

                    if ~isempty(s_ind)
                      plot(thal_spindles(s_ind,1),thal_ch_norm_filtered(i,round(thal_spindles(s_ind,1)*fs))+(i),'*r')
                      plot(thal_spindles(s_ind,3),thal_ch_norm_filtered(i,round(thal_spindles(s_ind,3)*fs))+(i),'*m')
                    end
%            end
       
    end

    title(['Spindles for 8 channel exclude each shank ' num2str(k)])
    xlabel('time(ms)')
    ylabel('Chanels')
    set(gca,'fontsize',16, 'color', [0 0 0 ]);
end 
%%  methode 2 for sepration 
% make zero for times that dont have event and 1 for events and then compute average
load thal_ch_norm_filtered.mat
fs=1250;
CHNUM = size(thal_ch_norm_filtered,1);
Newthal_ch_norm_filtered = zeros(CHNUM,length(thal_ch_norm_filtered(1,:)));
signalCH = zeros (CHNUM,length(thal_ch_norm_filtered(1,:))); 
for i=1:CHNUM
    load  (['thal_spindles_ch' num2str(i) '.mat']);
    for j=1:size(thal_spindles,1)
%         Newthal_ch_norm_filtered(i,round(thal_spindles(j,1)*fs):round(thal_spindles(j,3)*fs)) = thal_ch_norm_filtered(i,round(thal_spindles(j,1)*fs):round(thal_spindles(j,3)*fs));
        Newthal_ch_norm_filtered(i,round(thal_spindles(j,1)*fs):round(thal_spindles(j,3)*fs)) = 1;
    end
 
end 


% compute avg

Means = mean( Newthal_ch_norm_filtered(:, :));
signal= Means;
save meansSignalForMethode2ToSeprate    signal
%
figure
hold on 
for i=1:ch_number
plot((thal_ch_norm_filtered(i,:))+10*i)
end
%
% OnesSamples = transpose(find(Newthal_ch_norm_filtered==1));
Diff = diff(signal);
startsSamplesForMeans = find(Diff > 0);
toRemove = false(1, size(startsSamplesForMeans, 2));
for m = 1:size(startsSamplesForMeans, 2)
    if signal(1, startsSamplesForMeans(m)-1) ~= 0
        toRemove(m) = true;
    end 
end

startsSamplesForMeans(toRemove) = [];

startsTimesForMeans = startsSamplesForMeans/fs;
%
endsSamplesForMeans = find(Diff < 0);
toRemoveEnd = false(1,size(endsSamplesForMeans,2));
for n = 1:size(endsSamplesForMeans, 2)
    if signal(1, endsSamplesForMeans(n)+1) ~= 0
        toRemoveEnd(n) = true;
    end 
end

endsSamplesForMeans(toRemoveEnd) = [];

endsTimesForMeans = endsSamplesForMeans/fs;

%%
% figure 
% t2 = (1:length(Newthal_ch_norm_filtered(1,:)))/fs;
% plot(t2,signal,'Color','yellow','LineWidth',2.5)
% set(gca,'fontsize',16,'color',[0 0 0])
% set(groot, 'defaultFigureColor', [0 0 0]);
% set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
% hold on
% for k=1:size(startsTimesForMeans,2)
%     xline(startsTimesForMeans(1,k),'Color','c','LineWidth',2)
% end
% 
% for k= 1:size(endsTimesForMeans,2)
%         xline(endsTimesForMeans(1,k),'Color','green','LineWidth',2)
% end
% hold off
%%
difference = min(length(endsTimesForMeans),length(startsTimesForMeans));
durationTH = 0.5;

for i = 1:size(startsTimesForMeans,2)
    for j = 1:size(endsTimesForMeans,2)
        Distance(i,j) = abs(startsTimesForMeans(i)-endsTimesForMeans(j));
        if Distance(i,j) < durationTH
            difStart(i) = startsTimesForMeans(i);
            difEnd(i) = endsTimesForMeans(j);
        end
    end
end 

difStartZero = find(difStart == 0);
difStart(difStartZero) = [];

difEndZero = find(difEnd == 0);
difEnd(difEndZero) = [];
% for i = 1:difference
%     dif(i) =abs(endsTimesForMeans(i) - startsTimesForMeans(i));
%     if dif(i) < durationTH
%         difStart(i) = startsTimesForMeans(i);
%         difEnd(i) = endsTimesForMeans(i);
%     end
% end 

%%
load SWS_episode_new_90.mat
t = (1:length(SWS_episode(1,:)))/fs;

figure
plot(t,(signal*3)-5,'Color','yellow','LineWidth',2.5)
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold on 
coef = 2:5:337;
for i=1:(CHNUM/8)
    plot(t,zscore(SWS_episode(i,:))+coef(i),'Color','green','LineWidth',1.5)

end 


for j=1:length(difStart(1,:))
    xline(difStart(1,j),'Color','c','LineWidth',2)
    xline(difEnd(1,j),'Color','y','LineWidth',2)
end 
hold off
ylim([-10 45])
%%
event = 1;

for i=1:event
    figure
     start = difStart(i)-20;
     stop = difEnd(i)+20;
     hold on 
     for j=1:(CHNUM/8)
    plot(start:stop,zscore(SWS_episode(j,(round(start*fs):round(stop*fs))+coef(j)),'Color','green','LineWidth',1.5))
    plot(start:stop,signal(1,round((start:stop)*fs)),'Color','yellow','LineWidth',2.5)
    set(gca,'fontsize',16,'color',[0 0 0])
    set(groot, 'defaultFigureColor', [0 0 0]);
    set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
     end 
     xline(difStart(1,i),'Color','c','LineWidth',2)
    xline(difEnd(1,i),'Color','c','LineWidth',2)
    hold off
end 

%
% for k=1:CHNUM
%     signalCH(k,:) = mean( Newthal_ch_norm_filtered(k, :));
% end
%plot
% figure 
% 
% plot(t2,signal,'Color','yellow','LineWidth',2.5)
% title ('avraged signal for all 64 channel')
% xlabel('time(s)')
% ylim([0 1.5])
% set(gca,'fontsize',16,'color',[0 0 0])
% set(groot, 'defaultFigureColor', [0 0 0]);
% set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);

%plot base on channels hold on 
% figure
% for k=1:CHNUM
%     plot(t2,signalCH)
% end
% hold off
%% 
% find channel with the most spindle event 
load thal_ch_norm_filtered.mat
load meansSignalForMethode2ToSeprate    signal

fs=1250;
ch_number=size(thal_ch_norm_filtered,1);
load  (['thal_spindles_ch' num2str(1) '.mat']);
maxSpin = size(thal_spindles,1);
for i=2:ch_number
    load  (['thal_spindles_ch' num2str(i) '.mat']);
    if size(thal_spindles,1) > maxSpin
       maxSpin =  size(thal_spindles,1);
       mostSpinCh = i;
    end
end 

% compute avg for signal variable between start and end of each event for refrence channel 
refCH = load  (['thal_spindles_ch' num2str(mostSpinCh) '.mat']);
for k=1:size(refCH.thal_spindles,1)
    DiffRef(k) = refCH.thal_spindles(k,3) - refCH.thal_spindles(k,1) ;
end
BigDiff = round(max(DiffRef)*fs);
means = zeros(maxSpin,round(BigDiff)) ;
for j=1:maxSpin
    startSpin = round(refCH.thal_spindles(j,1)*fs);
    endSpin = round(refCH.thal_spindles(j,3)*fs);
    means(j,1:endSpin-startSpin+1) = signal(1,startSpin:endSpin);
%     meansAll = meansAll + means;
end 
Avg = mean(means(:,:));
TMean = (1:length(Avg))/fs;
figure
plot(TMean,Avg,'LineWidth',2,'Color','yellow')
title ('avg for the spindles base on reference channel ','Color','white')
xlabel('time','Color','white')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);

% meanAmp =


%%
nbin = 50;
nbin_new = 1000;
figure
histogram (DiffRef,nbin,'FaceColor','white','EdgeColor','green')
title ('histogram spindles duration for reference channel (Channel 7) ','Color','white')
xlabel('duration(s)','Color','white')
ylabel ('count','Color','white')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);

%
figure
histogram (Avg,nbin_new,'FaceColor','red','EdgeColor','green')
title ('histogram spindles amplitude for reference channel (Channel 7) ','Color','white')
xlabel('amplitude','Color','white')
ylabel ('count','Color','white')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
% 
figure
histogram (signal,nbin,'FaceColor','red','EdgeColor','green')
title ('histogram spindles amplitude for reference channel (Channel 13) ','Color','white')
xlabel('amplitude','Color','white')
ylabel ('count','Color','white')
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);

%%
load meansSignalForMethode2ToSeprate    signal
CHNUM = size(thal_ch_norm_filtered,1);
% load('SWS_episode_new_90.mat')

startSam = 11045;
SampInterval = 3*fs;
eventNUM = 1;
start_t_sample = 6*fs;
end_t_sample = 12*fs;
% t = (start_t_sample:length(SWS_episode(1,startSam-(SampInterval):startSam+(SampInterval))))/fs;
t= (start_t_sample:end_t_sample)/fs;
figure
plot(t,(signal(1,startSam-(SampInterval):startSam+(SampInterval))*3)-5,'Color','yellow','LineWidth',2.5)
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold on 
coef = 2:5:337;
sepraterCH = [8 16 21 29 37 45 53];
for i=1:CHNUM
    if i == mostSpinCh
       plot(t,zscore(SWS_episode(i,startSam-(SampInterval):startSam+(SampInterval)))+coef(i),'Color','white','LineWidth',1.5)
       i=i+1;
    end
    plot(t,zscore(SWS_episode(i,startSam-(SampInterval):startSam+(SampInterval)))+coef(i),'Color','green','LineWidth',1.5)
    load  (['thal_spindles_ch' num2str(i) '.mat'])
    if thal_spindles(eventNUM,1) > (SampInterval/fs) && thal_spindles(eventNUM,1) < ((SampInterval*2*fs)/fs) 
     plot(thal_spindles(eventNUM,1),zscore(SWS_episode(i,round(thal_spindles(eventNUM,1)*fs)))+coef(i),'*r')
     plot(thal_spindles(eventNUM,3),zscore(SWS_episode(i,round(thal_spindles(eventNUM,3)*fs)))+coef(i),'*m')
    end
    
end 

for  i=sepraterCH
        yline(coef(i)+2,'Color','white','LineWidth',2.5)
end 
hold off

% 
% for j=1:length(difStart(1,:))
%     xline(difStart(1,j),'Color','c','LineWidth',2)
%     xline(difEnd(1,j),'Color','y','LineWidth',2)
% end 
% hold off
ylim([-10 45])
%%
ChNUM = [ 13 9 10 14 15 16 50 54 56 58];
t_teSt = (1:length(SWS_episode(mostSpinCh,:)))/fs;
% colOr = ['g' , 'y' 'y' 'y' 'y' 'y' 'g ' 'y' 'y' 'y' ];
figure
% plot(t_teSt,zscore(SWS_episode(mostSpinCh,:))+coef(1),'LineWidth',1.5)
% hold on 
% for j=1 : size(refCH.thal_spindles,1)
%      plot(thal_spindles(j,1),zscore(SWS_episode(i,round(thal_spindles(j,1)*fs)))+coef(i),'*r')
%      plot(thal_spindles(j,3),zscore(SWS_episode(i,round(thal_spindles(j,3)*fs)))+coef(i),'*m')
%     end 
hold on 
for i = ChNUM
    if i == mostSpinCh
        plot(t_teSt,zscore(SWS_episode(i,:))+(10*i),'LineWidth',1.5, 'Color','white')
        load  (['thal_spindles_ch' num2str(i) '.mat'])
        for j=1 : size(thal_spindles,1)
             plot(thal_spindles(j,1),zscore(SWS_episode(i,round(thal_spindles(j,1)*fs)))+(10*i),'*r')
             plot(thal_spindles(j,3),zscore(SWS_episode(i,round(thal_spindles(j,3)*fs)))+(10*i),'*m')
        end 
    else 
        plot(t_teSt,zscore(SWS_episode(i,:))+(10*i),'LineWidth',1.5,'Color','green')
        load  (['thal_spindles_ch' num2str(i) '.mat'])
        for j=1 : size(thal_spindles,1)
             plot(thal_spindles(j,1),zscore(SWS_episode(i,round(thal_spindles(j,1)*fs)))+(10*i),'*r')
             plot(thal_spindles(j,3),zscore(SWS_episode(i,round(thal_spindles(j,3)*fs)))+(10*i),'*m')
        end 
    end 
    
end
set(gca,'fontsize',16,'color',[0 0 0])
set(groot, 'defaultFigureColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [1 1 1], 'defaultAxesYColor', [1 1 1], 'defaultAxesZColor', [1 1 1]);
hold off
% legend ('ch = 7',' ch =9', 'color','white')
% text ('ch7 = 1119  and ch9 = 1088' )
%%
MensnsForChNUM = zeros(size(thal_ch_norm_filtered,1),length(thal_ch_norm_filtered(mostSpinCh,:)));
% SUM = size(1,BigDiff);

coeff = 1:2:20;
figure
hold on 
for i = ChNUM
    load  (['thal_spindles_ch' num2str(i) '.mat'])
    for k=1:size(thal_spindles,1)
        startSpin = round(thal_spindles(k,1)*fs);
        endSpin = round(thal_spindles(k,3)*fs);
        SUM(k,1:endSpin-startSpin+1) = thal_ch_norm_filtered(i,startSpin:endSpin);
%         SUM = SUM + thal_ch_norm_filtered(i,(thal_spindles(k,1)*fs):(thal_spindles(k,3)*fs));
    end 
    Average = mean(SUM(:,:));
    tt = (1:length(Average))/fs;
%     MensnsForChNUM(i,:) = mean (thal_ch_norm_filtered(i,:));
    if i == mostSpinCh
        plot(tt,Average+(i),'LineWidth',1.5)
    else 
        plot(tt,Average+(i),'LineWidth',1.5,'Color','red')
        
    end 
    
end
%%
load  (['thal_spindles_ch' num2str(mostSpinCh) '.mat'])
MEAN = zeros(1,size(thal_spindles,1));
for i=1:size(thal_spindles,1)
    startSpindleSample = thal_spindles(i,1)*fs;
    endSpindleSample = thal_spindles(i,3)*fs;
    MEAN(1,i) = mean(signal(1,startSpindleSample:endSpindleSample),'all');
end
Meadian = median(MEAN);

figure

hist(MEAN,30)
title('Histogram AVG signal between start and end spindles base on ref channel for 120806','Color','white')
xlabel('amplitude','Color','white')
hold on 
xline(Meadian,'Color','red','LineWidth',2)
% text (Meadian,'Color','red','FontSize',20,'Position',[7.5 100])
text('Color','red','FontSize',20,'Position',[Meadian 100],'String',num2str(Meadian))
%% seprate global and local base on threshold 
load (['real_peaks' num2str(mostSpinCh) '.mat'])

TH = 0.76;

for i=1:size(MEAN,2)
    if MEAN(1,i) > TH
        globalspin(i,:) = thal_spindles(i,:);
        globPeaks(:,i) = real_peaks(:,i);
    else
        locspin(i,:) = thal_spindles(i,:);
        locPeaks(:,i) = real_peaks(:,i);
    end 
end
% Find rows with all zero values
locsrowsToDelete = all(locspin == 0, 2);
locscolomnToDelete = all(locPeaks==0,1);
% Remove rows with all zero values
locspin(locsrowsToDelete, :) = [];
% locPeaks(locscolomnToDelete,:) = [];
locPeaks(:,locscolomnToDelete) = [];

globrowsToDelete = all(globalspin == 0, 2);
globcolomnToDelete = all(globPeaks == 0, 1);
globalspin(globcolomnToDelete, :) = [];
globPeaks(:,locscolomnToDelete) = [];

% save spindles base on global and local 
sepratedSpindles120806.referencChannel = mostSpinCh;
sepratedSpindles120806.localSPindles = locspin;
sepratedSpindles120806.globalSPindles = globalspin;
sepratedSpindles120806.LocalPeaks = locPeaks;
sepratedSpindles120806.globalPeaks = globPeaks;
save sepratedSpindles120806 sepratedSpindles120806

%%
