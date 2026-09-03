% =========================================================================
% SCRIPT: Compute and Plot Power Spectral Density (PSD) using Welch's Method
% SUBJECT: Multi-channel SWS Recording (Channels 2 and 10)
% =========================================================================
% DESCRIPTION:
% Extracts two specific channels (Channel 2 and Channel 10) from a 
% continuous Slow-Wave Sleep (SWS) recording and computes their Power 
% Spectral Density (PSD) using Welch's method. The PSD is estimated using 
% a 10-second Hamming window with 50% overlap and zero-padded to the next 
% power of 2. The resulting spectra are visualized on a log-log scale and 
% saved as a PNG image.
%
% INPUTS:
%   - SWS_episode_new_90.mat: Continuous multi-channel SWS LFP data.
%
% OUTPUTS:
%   - Visualizations: Log-log plot of the Power Spectral Density for the 
%     two selected channels.
%   - power_spectrum.png: Saved image of the PSD plot.
%
% DEPENDENCIES:
%   - MATLAB Signal Processing Toolbox: pwelch, hamming.
% =========================================================================

%% Load data from matrix
load('SWS_episode_new_90.mat');
two_channel = zeros (2,length(SWS_episode));
two_channel(1,:) = SWS_episode(2,:);
two_channel(2,:) = SWS_episode(10,:);
%% Convert data to double data type
% data = double(SWS_episode(1:64,:));
    data = double(two_channel);
% Calculate power spectrum using Welch's method
fs = 1250;          % Sampling rate
nsc = floor(fs*10);
window = hamming(nsc);    % Window function
noverlap = floor(nsc/2);     % Number of samples to overlap between segments
nfft = 2^nextpow2(nsc);        % Length of FFT
[Pxx, f] = pwelch(data', window, noverlap, nfft, fs);

% Plot power spectrum in a single image
figure;
% imagesc(f, 1:size(Pxx, 2), Pxx);
loglog(f, Pxx);
% colorbar;
title('Power Spectrum');
xlabel('Frequency (Hz)');
ylabel('Power');

% Save the image as PNG
saveas(gcf, 'power_spectrum.png');
