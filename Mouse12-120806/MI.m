

function [ModuIndex] = MI(limitFiringRate)
% =========================================================================
% FUNCTION: MI - Calculate Modulation Index for Firing Rate
% =========================================================================
% DESCRIPTION:
% Computes the Modulation Index (MI) of a time-windowed firing rate signal.
% The MI is defined as the absolute difference between the maximum peak 
% amplitude and the minimum trough amplitude within the signal. This metric
% quantifies the depth of firing rate modulation (excitation/inhibition) 
% around a specific physiological event.
%
% INPUTS:
%   - limitFiringRate : 1D vector of the firing rate signal (typically a 
%                       restricted time window around an event).
%
% OUTPUTS:
%   - ModuIndex       : Scalar value representing the peak-to-trough 
%                       amplitude difference (Modulation Index). Returns 
%                       NaN if no valid peaks or troughs are detected.
%
% DEPENDENCIES:
%   - Custom functions: findThroughs, findMaxPeak.
% =========================================================================
    [throughs throughsLoc] = findThroughs(limitFiringRate);
    [maxPeak, maxPeakSample] = findMaxPeak(limitFiringRate);
%     Maxpeak = maxPeak;
    Maxthrough = min(throughs);
    ModuIndex = abs(maxPeak-Maxthrough);

end
