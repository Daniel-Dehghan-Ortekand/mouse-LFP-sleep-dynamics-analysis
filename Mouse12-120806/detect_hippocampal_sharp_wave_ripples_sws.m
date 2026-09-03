% =========================================================================
% SCRIPT: Hippocampal Sharp-Wave Ripple (SWR) Detection and Visualization
% SUBJECT: Multi-channel Hippocampal Recording (5 Channels)
% =========================================================================
% DESCRIPTION:
% Detects sharp-wave ripples (150-200 Hz) in hippocampal LFP data during 
% Slow-Wave Sleep (SWS). The script selects 5 hippocampal channels, 
% applies z-scoring and bandpass filtering (150-200 Hz), then uses an 
% envelope-based detection method: it computes the analytic signal amplitude 
% via the Hilbert transform, applies a moving-average smoothing filter, and 
% identifies ripple events as epochs where the smoothed envelope exceeds 
% the median plus 4 standard deviations. Events shorter than 30 ms are 
% discarded. Finally, it extracts the peak amplitude index within each 
% detected event.
%
% INPUTS:
%   - SWS_episode_new_90.mat: Raw continuous multi-channel SWS LFP data.
%
% OUTPUTS:
%   - HIP_ch_norm.mat: Z-scored hippocampal LFP data (5 channels).
%   - HIP_ch_norm_filtered_riple.mat: Bandpass filtered (150-200 Hz) 
%     hippocampal data.
%   - ripple_parameters_for_ch[X].mat: Detected ripple events (start, stop, 
%     peak indices) for each channel.
%   - Visualizations: Filtered LFP traces with optional ripple peak markers.
%
% DEPENDENCIES:
%   - MATLAB Signal Processing Toolbox: eegfilt, hilbert.
%   - Custom function: smooth (moving average).
% =========================================================================

%% zero step: start codes

clc
clear
close all
ch_number=5;
fs=1250;
%up and down frequency for data filtering in SECTION one : pre-processing
up_band=200;
down_band=150;
load('SWS_episode_new_90.mat')
HIP_CH=[SWS_episode(65,:);
    SWS_episode(67,:);
    SWS_episode(69,:);
    SWS_episode(71,:);
    SWS_episode(73,:);];

%% first step:pre-processing and filtering

HIP_ch_norm=zeros(ch_number,length(HIP_CH(1,:)));
for i=1:ch_number
    HIP_ch_norm(i,:)=zscore(HIP_CH(i,:));
end
save HIP_ch_norm.mat HIP_ch_norm -v7.3
HIP_ch_norm_filtered_riple=zeros(ch_number,length(HIP_CH(1,:)));
for j=1:ch_number
    HIP_ch_norm_filtered_riple(j,:) = eegfilt(HIP_ch_norm(j,:),fs,down_band,up_band,0,floor(fs/down_band)*3,0,'fir1');
end
save('HIP_ch_norm_filtered_riple.mat', 'HIP_ch_norm_filtered_riple')


%% second step:ripple detection
load('HIP_ch_norm_filtered_riple.mat')
%comute RMS of signal 
for k=1:ch_number
    amplitude = abs (hilbert(HIP_ch_norm_filtered_riple(k,:)) );
    power = smooth ( smooth(amplitude),(0.05*fs),'moving');
    ripple_power_mean = median (power);
    ripple_power_STD = std (power);
    riple_power_threshold = ripple_power_mean + (4*ripple_power_STD);
    %find start and stop as indices of threshold crossing 
    crossing = diff (power > riple_power_threshold);
    start= find (crossing > 0);
    stop = find (crossing < 0);
    if stop(1) < start(1)
        stop(1)=[];
    end
    if start(end) > stop(end)
       start(end) =[];
    end
    %discard short event 
    tooshort = stop - start < round(0.03*fs);
    start(tooshort) = [];
    stop(tooshort) = [];
    %find peak index
    peak = zeros(length(start),1);
    for i=1:length(start)
       [~ , P_ind] = max(HIP_ch_norm_filtered_riple(start(i):stop(i)));
       peak(i)=P_ind+start(i)-1;
    end
    ripple_parameters=[start stop peak];
%     save(['ripple_parameters_for_ch' num2str(k) '.mat'],'ripple_parameters')
%     plot (t,HIP_ch_norm_filtered_riple(1,:),'b')
%     hold on
%     plot (ripple_parameters(1,3),HIP_ch_norm_filtered_riple(1,round(ripple_parameters(1,3)/fs)),'*r')
end 


%% Thired step: resault
figure
t = (0.01/fs:1/fs:length(HIP_ch_norm_filtered_riple(1,:))/fs);
hold on
for i=1:ch_number
    load (['ripple_parameters_for_ch' num2str(i) '.mat'],'ripple_parameters')
    ripple_event=length(ripple_parameters(:,1));
    plot (t,HIP_ch_norm_filtered_riple(i,:)+(8*i),'b')
%     for h=1:ripple_event
%         plot(ripple_parameters(h,3)/fs,HIP_ch_norm_filtered_riple(i,ripple_parameters(h,3))+(8*i),'*r')
%     end
 end
