% =========================================================================
% SCRIPT: Basic Spike-Triggered Average (STA) Computation & Demonstration
% SUBJECT: N/A (Uses synthetic/dummy data for demonstration)
% =========================================================================
% DESCRIPTION:
% Computes the population Spike-Triggered Average (STA) of a Local Field 
% Potential (LFP) signal time-locked to multi-channel spike trains. It 
% extracts a backward-looking time window around each spike, handles 
% edge-boundary padding with zeros, accumulates the LFP snippets across 
% all channels, and normalizes the final waveform by the total spike count.
%
% INPUTS:
%   - lfpData: 1D vector of the LFP signal (Currently using synthetic 
%     random data for demonstration).
%   - spikeData: 2D binary matrix (Channels x Time) where 1 indicates a 
%     spike (Currently using synthetic random data).
%   - windowSize: Number of samples to extract prior to each spike.
%
% OUTPUTS:
%   - Visualizations: 
%       1. A single plot displaying the normalized, population-averaged 
%          STA waveform over time.
% =========================================================================

% Define the LFP data and spike data
lfpData = rand(1, 1000); % Example LFP data (replace with your actual data)
spikeData = randi([0 ,1],7, 1000); % Example spike data (replace with your actual data)
windowSize = 200; % Window size for spike triggered average

% Compute spike triggered average
sta = zeros(1, windowSize);
for i = 1:size(spikeData, 1)
    for j = 1:size(spikeData, 2)
        if spikeData(i,j) == 1
            if j-windowSize >= 1
                sta = sta + lfpData(j-windowSize+1:j);
            else
                sta = sta + [zeros(1, windowSize-j), lfpData(1:j)];
            end
        end
    end
end
sta = sta / sum(sum(spikeData));

% Plot the spike triggered average
figure;
plot(linspace(-windowSize/2, windowSize/2, windowSize), sta);
xlabel('Time (ms)');
ylabel('Amplitude');
title('Spike Triggered Average');
