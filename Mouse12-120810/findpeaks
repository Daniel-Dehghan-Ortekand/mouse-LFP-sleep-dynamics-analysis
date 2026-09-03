%% Maximum peak detection
% This function identifies all local peaks in the input signal and
% determines the peak with the maximum amplitude. It returns both the
% amplitude of the maximum peak and its corresponding sample location.

function [maxPeak, maxPeakSample] = findMaxPeak(signal)

% Find the peaks in the signal.
[peaks, peakLocs] = findpeaks(signal);

% Find the maximum peak.
[maxPeak, maxPeakInd] = max(peaks);

% Get the sample of the maximum peak.
maxPeakSample = peakLocs(maxPeakInd);

end
