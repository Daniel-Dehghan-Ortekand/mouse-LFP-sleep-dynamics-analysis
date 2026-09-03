%% Find local minima (troughs) in a signal
% This function identifies the troughs (local minima) of an input signal
% by inverting the signal and detecting its peaks. It returns both the
% trough amplitudes and their corresponding sample locations.

function [throughs, throughsLoc] = findThroughs(signal)

% Invert the signal.
invertedSignal = -signal;

% Find the peaks of the inverted signal.
[peaks, peakLocs] = findpeaks(invertedSignal);

% The throughs of the original signal are the peaks of the inverted signal.
throughs = signal(peakLocs);
throughsLoc = peakLocs;

end
