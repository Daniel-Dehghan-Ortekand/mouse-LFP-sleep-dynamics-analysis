%% 
% =========================================================================
% SCRIPT: Slow Oscillation (SO) Propagation Delay vs. Physical Distance Analysis
% SUBJECT: Multi-channel Thalamic Recording
% =========================================================================
% DESCRIPTION:
% Analyzes the spatiotemporal propagation of Slow Oscillations (SOs) across 
% a multi-channel probe. Using Channel 2 as a reference, it calculates the 
% median time delay between the reference SO events and the nearest SO on 
% each other channel. Delays greater than 2 seconds are excluded as 
% non-propagating. The script generates individual delay histograms for 
% each channel and maps the median delays to the physical distance of each 
% electrode, grouping the results by the 8 physical shanks of the probe.
%
% INPUTS:
%   - thal_SO_ch[X].mat: Detected SO events (onset, peak, offset) per channel.
%
% OUTPUTS:
%   - delay_SO_hist/hist_SO_ch[X].png: Histograms of delay distributions.
%   - delay_hist_so[X].mat: Raw delay data for each channel.
%   - median_SO.png: Scatter plot of median SO delay (s) vs. physical 
%     electrode distance (µm), color-coded by shank.
% =========================================================================
clc
clear
close all
% load('SWS_episode_new_90.mat')
ch_number = 64;
fs=1250;
nbins=50;
% %%
% SWS_episode_hilbert = hilbert(SWS_episode);
% IMG_SWS_episode_hilbert = imag(SWS_episode_hilbert);
% re_SWS_episode_hilbert = real(SWS_episode_hilbert);
% load(['thal_spindles_ch' num2str(1) '.mat'])
% spindle_sample =  thal_spindles(:,1)*fs;
% for i=1:ch_number
%     for j=1:length(spindle_sample)
%        phase_sample = spindle_sample(j);
%     phase(j)= IMG_SWS_episode_hilbert(i,round(phase_sample)); 
%     end
%     save (['phase_ch' num2str(i) '.mat'])
% end 
%%
load  (['thal_SO_ch' num2str(2) '.mat'])
base =  transpose(thal_SO(:,2));
%  spindle_event = size(thal_spindles,1);
delay = zeros(1,length(thal_SO(:,2)));
median_all = zeros(1,ch_number);
ChSync=[7 1 8 4 5 3 6 10 15 9 16 12 13 11 14 49 62 51 64 53 61 57 59 60 55 56 ...
    63 54 58 52 50 41 38 33 42 40 44 48 46 36 47 34 45 35 43 37 39 17 24 18 ...
    23 19 22 20 21 25 32 26 31 27 30 28 29];

 for i = ChSync
    load(['thal_SO_ch' num2str(i) '.mat'])
    so_ch = thal_SO(:,1);
    delay_ch = base - so_ch;
    [~, delay_min_ind] = min(abs(delay_ch), [], 1); 
    delay_min = base - so_ch(delay_min_ind)';
    delay_min(abs(delay_min)>2)=[];
    median_all(i) = median(delay_min);
    
    f1=figure();
    histogram(delay_min, 100, 'BinLimits', [-1 1])
% % %     so_event = size(thal_SO,1);
% % %      %Diff = zeros(1,length(thal_spindles(:,1)));
% % %     so_event_ch = transpose(thal_SO(:,1));
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
xlabel ('time(s)')
ylabel ('number of spindles')
title(['chanel # ' num2str(i)])
% % % % xlim([-1000 1000])
% % % 
saveas(f1,['delay_SO_hist/hist_SO_ch' num2str(i) '.png']); 
close(f1);
save (['delay_hist_so' num2str(i) '.mat'], 'delay_min')
 end

 median_all([2 7 19 20 21]) = nan; 
%  ChSync=[2 7 1 8 4 5 3 6 10 15 9 16 12 13 11 14 49 62 51 64 53 61 57 59 60 55 56 ...
%     63 54 58 52 50 41 38 33 42 40 44 48 46 36 47 34 45 35 43 37 39 17 24 18 ...
%     23 19 22 20 21 25 32 26 31 27 30 28 29];
dis = [0 8.5 17 21 25 29 33 37 200 208.5 217 221 225 229 233 237 ...
    400 408.5 417 421 425 429 433 437 600 608.5 617 621 625 629 633 637 ...
    800 808.5 817 821 825 829 833 837 1000 1008.5 1017 1021 1025 1029 1033 ...
    1037 1200 1208.5 1217 1221 1225 1229 1233 1237 1400 1408.5 1417 1421 1425 1429 ...
    1433 1437];
dis_elec1 = [0 8.5 17 21 25 29 33 37];
dis_elec2 = [200 208.5 217 221 225 229 233 237];
dis_elec3 = [400 408.5 417 421 425 429 433 437];
dis_elec4 = [600 608.5 617 621 625 629 633 637];
dis_elec5 = [800 808.5 817 821 825 829 833 837] ;
dis_elec6 = [1000 1008.5 1017 1021 1025 1029 1033 1037 ];
dis_elec7 = [1200 1208.5 1217 1221 1225 1229 1233 1237];
dis_elec8 = [1400 1408.5 1417 1421 1425 1429 1433 1437];
f2 = figure
plot(dis_elec1,median_all([7 2 1 8 4 5 3 6]),'o','MarkerFaceColor','k')
hold on 
plot(dis_elec2,median_all([10 15 9 16 12 13 11 14]),'o','MarkerFaceColor','b')
plot(dis_elec3,median_all([49 62 51 64 53 61 57 59]),'o','MarkerFaceColor','r')
plot(dis_elec4,median_all([60 55 56 63 54 58 52 50]),'o','MarkerFaceColor','c')
plot(dis_elec5,median_all([41 38 33 42 40 44 48 46]),'o','MarkerFaceColor','m')
plot(dis_elec6,median_all([36 47 34 45 35 43 37 39]),'o','MarkerFaceColor','g')
plot(dis_elec7,median_all([17 24 18 23 19 22 20 21]),'o','MarkerFaceColor',[0.2 0.6 0.5])
plot(dis_elec8,median_all([25 32 26 31 27 30 28 29]),'o','MarkerFaceColor',[0.6 0.2 0.5])
hold off 
legend ('Electrod 1','Electrod 2','Electrod 3','Electrod 4','Electrod 5', ...
    'Electrod 6','Electrod 7','Electrod 8')
ylabel ('median delay (s)')
xlabel ('Distance(micrometres)')
title('Delay all channels for SOs ')
%  f2=figure;
% xlim([2 ch_number])
% ylabel ('median delay (s)')
% xlabel ('number of channels')
% title('Delay all channels for SOs')
 saveas(f2,['median_SO .png']); 
