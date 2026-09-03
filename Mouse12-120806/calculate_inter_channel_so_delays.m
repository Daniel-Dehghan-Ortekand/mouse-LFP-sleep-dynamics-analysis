% =========================================================================
% SCRIPT: Compute Slow Oscillation (SO) Propagation Delays Across Representative Channels
% SUBJECT: Multi-channel Thalamic Recording (Representative Shanks)
% =========================================================================
% DESCRIPTION:
% Runs the SOMolle detection algorithm on pre-filtered LFP data from 
% representative channels (one per shank) to identify Slow Oscillation 
% (SO) peaks. Using the first channel as a reference, it extracts a 
% 1-second window around each reference SO peak for all other channels, 
% finds the maximum peak within that window, and calculates the 
% propagation delay (in seconds) relative to the reference channel's peak.
%
% INPUTS:
%   - thal_ch_norm_filtered_ChooseOneChannelFromEachShanks.mat: Z-scored, 
%     0.5-4 Hz bandpass filtered LFP data for the representative channels.
%
% OUTPUTS:
%   - daleyForOneChannnelOfEachShankBaseOnMaxPeak.mat: A matrix 
%     (Channels x SO_events) containing the propagation delays of the SO 
%     peaks for each channel relative to the reference channel (Channel 1).
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
save daleyForOneChannnelOfEachShankBaseOnMaxPeak delay
