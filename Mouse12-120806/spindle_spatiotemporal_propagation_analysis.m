%% 
% =========================================================================
% SCRIPT: Sleep Spindle Propagation Delay vs. Physical Distance Analysis
% SUBJECT: Multi-subject Thalamic Recording Analysis
% =========================================================================
% DESCRIPTION:
% Analyzes the spatiotemporal propagation of sleep spindles across a 
% multi-channel probe. For each subject, it identifies a reference channel 
% (from the separated spindles structure) and calculates the median time 
% delay between spindle onsets on the reference channel and the nearest 
* spindle on each other channel. These median delays are then mapped to 
% the physical distance of each electrode from the reference, allowing 
% visualization of how spindle propagation speed varies with distance 
% across different shanks. The script handles deleted/bad channels by 
% inserting NaN values at their positions to maintain correct spatial 
% mapping.
%
% INPUTS:
%   - sepratedSpindles[X].mat: Structure containing reference channel info.
%   - thal_spindles[X].mat: Cell array of spindle detections per channel.
%   - deletedChannels.mat: Cell array of bad channel indices per subject.
%
% OUTPUTS:
%   - Visualizations: Scatter plots of median spindle onset delay (s) vs. 
%     physical electrode distance (µm), color-coded by shank.
%
% NOTES:
%   - Delays > 2 seconds are excluded as likely non-propagating events.
%   - Physical distances are hardcoded based on probe geometry.
% =========================================================================
clc
clear
close all
% load('SWS_episode_new_90.mat')
% ch_number = 64;
fs=1250;
nbins=50;
load deletedChannels.mat
%%
% load  (['thal_spindles_ch' num2str(1) '.mat'])
% base =  transpose(thal_spindles(:,1));
% delay = zeros(1,length(thal_spindles(:,1)));
% median_all = zeros(1,ch_number);
% for i = 2:ch_number
%     load(['thal_spindles_ch' num2str(i) '.mat'])
%     spindle_ch = thal_spindles(:,1);
%     delay_ch = base - spindle_ch;
%     [~, delay_min_ind] = min(abs(delay_ch), [], 1); 
%     delay_min = base - spindle_ch(delay_min_ind)';
%     
%     median_all(i) = median(delay_min);
%     
%     f1=figure();
%     histogram(delay_min, 100, 'BinLimits', [-0.2 0.2])
% % % %     so_event = size(thal_spindles,1);
% % % %      %Diff = zeros(1,length(thal_spindles(:,1)));
% % % %     so_event_ch = transpose(thal_spindles(:,1));
% % % %     for k = 1:size(base,2)
% % % %         for j = 1:so_event
% % % %            Diff(j) = base(k) - so_event_ch(j) ;
% % % %         end
% % % %         delay(k) = min(abs(Diff));
% % % %     ind = find(Diff == delay(k));
% % % %    if Diff(k)<0
% % % %       delay(k) = -delay(k); 
% % % %    end
% % % %     end 
% % % % %     delay(i) = min(abs(Diff));
% % % % %     ind = find(Diff == delay(i));
% % % % %    if Diff(j)<0
% % % % %       delay(i) = -delay(i); 
% % % % %    end
% % % % f1 = figure;
% % % % histogram(delay,nbins)
% xlabel ('time(s)')
% ylabel ('number of spindles')
% title(['chanel # ' num2str(i)])
% % % % % xlim([-1000 1000])
% % % % 
% saveas(f1,['delay_hist/hist_spindle_ch' num2str(i) '.png']); 
% close(f1);
% save (['delay_hist_spindle' num2str(i) '.mat'], 'delay_min')
% end
% median_all([19 20 21]) = nan; 
% f2=figure;
% plot(median_all)
% xlim([2 ch_number])
% ylabel ('median delay (s)')
% xlabel ('number of channels')
% title('Delay all channels')
% saveas(f2,['median_spindles .png']); 

%%
%  load(['thal_spindles_ch' num2str(1) '.mat'])
%  base =  transpose(thal_spindles(:,1));
% %  spindle_event = size(thal_spindles,1);
%   delay = zeros(1,length(thal_spindles(:,1)));
%  for i = 2:ch_number
%     load(['thal_spindles_ch' num2str(i) '.mat'])
%      spindle_event = size(thal_spindles,1);
%      %Diff = zeros(1,length(thal_spindles(:,1)));
%     sp_event_ch = transpose(thal_spindles(:,1));
%     for k = 1:size(base,2)
%         for j = 1:spindle_event
%            Diff(j) = base(k) - sp_event_ch(j) ;
%         end
%         delay(k) = min(abs(Diff));
%     ind = find(Diff == delay(k));
%    if Diff(k)<0
%       delay(k) = -delay(k); 
%    end
%     end 
% %     delay(i) = min(abs(Diff));
% %     ind = find(Diff == delay(i));
% %    if Diff(j)<0
% %       delay(i) = -delay(i); 
% %    end
% f1 = figure;
% histogram(delay,nbins)
% save (['delay_hist' num2str(i)])
% xlabel ('time(s)')
% ylabel ('number of spindles')
% title(['chanel # ' num2str(i)])
% % xlim([-1000 1000])
% 
% saveas(f1,['delay_hist/hist_spindle_ch' num2str(i) '.png']); 
% close(f1);
%  end
%%
%     hold on
% for l = 2:8:ch_number
%     load (['delay_hist' num2str(l)])
%     histogram(delay,nbins)
% end
%%
digits(7);

 dis_elec1 = [0 8.5 17 21 25 29 33 37];
    dis_elec2 = [200 208.5 217 221 225 229 233 237];
    dis_elec3 = [400 408.5 417 421 425 429 433 437];
    dis_elec4 = [600 608.5 617 621 625 629 633 637];
    dis_elec5 = [800 808.5 817 821 825 829 833 837] ;
    dis_elec6 = [1000 1008.5 1017 1021 1025 1029 1033 1037 ];
    dis_elec7 = [1200 1208.5 1217 1221 1225 1229 1233 1237];
    dis_elec8 = [1400 1408.5 1417 1421 1425 1429 1433 1437];
    dis_elec = [dis_elec1;dis_elec2;dis_elec3;dis_elec4;dis_elec5;dis_elec6;...
        dis_elec7;dis_elec8];
pathsAmp = dir('*/sepratedSpindles*');
[nRaws, ~] = size(pathsAmp);
format long
for k=1:1%nRaws    
%     load  (['thal_spindles_ch' num2str(2) '.mat'])
    load(['sepratedSpindles' num2str(k) '.mat'])
    load (['thal_spindles' num2str(k) '.mat'])
    ref = sepratedSpindles.sepratedSpindles.referencChannel;
    thal_spindles_indi = thal_spindles{1,ref}.thal_spindles;
    base = ( transpose(thal_spindles_indi(:,1)));
    delay = zeros(1,length(thal_spindles_indi(:,1)));
    format lonG
        median_all = zeros(1,length(thal_spindles));

%     ChSync=[7 1 8 4 5 3 6 10 15 9 16 12 13 11 14 49 62 51 64 53 61 57 59 60 55 56 ...
%         63 54 58 52 50 41 38 33 42 40 44 48 46 36 47 34 45 35 43 37 39 17 24 18 ...
%         23 19 22 20 21 25 32 26 31 27 30 28 29];
    % ChSync = 7;
    for i = 1: length(thal_spindles)
        if i == ref
            continue
        else
%         load(['thal_spindles_ch' num2str(i) '.mat'])
        temp = thal_spindles{1,i}.thal_spindles;
        spindle_ch = temp(:,1);
        delay_ch = base - spindle_ch;
        [~, delay_min_ind] = min(abs(delay_ch), [], 1); 
        delay_min = base - spindle_ch(delay_min_ind)';
            delay_min(abs(delay_min)>2)=[];
%         median_all(i) = median(delay_min);
        digits(8)
        median_all(i) = median(delay_min);
%         f1=figure();
%         histogram(delay_min, 100, 'BinLimits', [-1 1])
    % % %     so_event = size(thal_spindles,1);
    % % %      %Diff = zeros(1,length(thal_spindles(:,1)));
    % % %     so_event_ch = transpose(thal_spindles(:,1));
    % % %     for k = 1:size(base,2)
    % % %         for j = 1:so_event
    % % %            Diff(j) = base(k) - so_event_ch(j) ;
    % % %         end
    % % %         delay(k) = min(abs(Diff));
    % % %     ind = find(Diff == delay(k));
    % % %    if Diff(k)<0
    % % %       delay(k) = -delay(k); 
    % % %    end
    % % %     end 
    % % % %     delay(i) = min(abs(Diff));
    % % % %     ind = find(Diff == delay(i));
    % % % %    if Diff(j)<0
    % % % %       delay(i) = -delay(i); 
    % % % %    end
    % % % f1 = figure;
    % % % histogram(delay,nbins)
%     xlabel ('time(s)')
%     ylabel ('number of spindles')
%     title(['chanel # ' num2str(i)])
    % % % % xlim([-1000 1000])
    % % % 
%     saveas(f1,['delay_hist/hist_spindle_ch' num2str(i) '.png']); 
%     close(f1);
%     save (['delay_hist_spindle' num2str(i) '.mat'], 'delay_min')
        end
    end
    dis = [0 8.5 17 21 25 29 33 37 200 208.5 217 221 225 229 233 237 ...
        400 408.5 417 421 425 429 433 437 600 608.5 617 621 625 629 633 637 ...
        800 808.5 817 821 825 829 833 837 1000 1008.5 1017 1021 1025 1029 1033 ...
        1037 1200 1208.5 1217 1221 1225 1229 1233 1237 1400 1408.5 1417 1421 1425 1429 ...
        1433 1437];
    del = deletedChannels{1,k};

    medianAll = zeros(1,64);
    medianAll(del) = nan;
    count = 1;
    for j=1:64
        if isnan(medianAll(j))
            continue
        else
            medianAll(j) = median_all(count);
            count = count + 1;
        end
    end 
% dis(del) = [];
%      median_all([2 7 19 20 21]) = nan; 
    % plot (dis , median_all,'o','MarkerFaceColor','k')
    % median_all([7 19 20 21]) = nan; 
    % ChSync=[2 7 1 8 4 5 3 6 10 15 9 16 12 13 11 14 49 62 51 64 53 61 57 59 60 55 56 ...
    %     63 54 58 52 50 41 38 33 42 40 44 48 46 36 47 34 45 35 43 37 39 17 24 18 ...
    %     23 19 22 20 21 25 32 26 31 27 30 28 29];
    % median_all([2 7 19 20 21]) = nan; 
   
    figure
    plot(dis_elec1,medianAll(1:8),'o','MarkerFaceColor','k')
    hold on 
    plot(dis_elec2,medianAll(9:16),'o','MarkerFaceColor','b')
    plot(dis_elec3,medianAll(17:24),'o','MarkerFaceColor','r')
    plot(dis_elec4,medianAll(25:32),'o','MarkerFaceColor','c')
    plot(dis_elec5,medianAll(33:40),'o','MarkerFaceColor','m')
    plot(dis_elec6,medianAll(41:48),'o','MarkerFaceColor','g')
    plot(dis_elec7,medianAll(49:56),'o','MarkerFaceColor',[0.2 0.6 0.5])
    plot(dis_elec8,medianAll(57:64),'o','MarkerFaceColor',[0.6 0.2 0.5])
    hold off 
    legend ('Electrod 1','Electrod 2','Electrod 3','Electrod 4','Electrod 5', ...
        'Electrod 6','Electrod 7','Electrod 8')
    ylabel ('median delay (s)')
    xlabel ('Distance(micrometres)')
    title('Delay all channels for spindles ')
    % f2=figure;
    % plot(ChSync_new,median_all,'o','MarkerFaceColor','k')
    % xlim([2 ch_number])
    % ylim([0.3 0.4])
    % ylabel ('median delay (s)')
    % xlabel ('number of channels')
    % title('Delay all channels for spindles ')
    % saveas(f2,['median_spindles .png']); 
    


end
