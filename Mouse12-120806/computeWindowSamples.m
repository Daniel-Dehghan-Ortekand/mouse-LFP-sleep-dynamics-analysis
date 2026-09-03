function windowSamples = computeWindowSamples(fs, limitWinSample)
% =========================================================================
% FUNCTION: computeWindowSamples
% =========================================================================
% DESCRIPTION:
% Calculates a vector of integer array indices representing a time window 
% centered around the midpoint of a 1-second epoch (sample fs/2). This is 
% useful for extracting a specific segment of a signal (e.g., to find 
% peak and trough firing rates around a stimulus or event).
%
% INPUTS:
%   - fs              : Sampling frequency in Hz (e.g., 1250).
%   - limitWinSample  : Number of samples to extend the window backward 
%                       and forward from the center point.
%
% OUTPUTS:
%   - windowSamples   : A row vector of integer indices from 
%                       (center - limit) to (center + limit).
% =========================================================================

    % Calculate the center index (midpoint of a 1-second window)
    centerIdx = round(fs / 2);
    
    % Calculate the lower and upper integer bounds for the window
    lowerLimit = centerIdx - limitWinSample;
    upperLimit = centerIdx + limitWinSample;
    
    % Create a vector of integer indices for the window
    % Ensure they are integers in case limitWinSample is a float
    windowSamples = round(lowerLimit) : round(upperLimit);

end


% Compute the inverse of round((fs/2)).
invRoundFsHalf = inv(round(fs/2));

% Subtract limitWinSample from the inverse of round((fs/2)).
lowerLimit = invRoundFsHalf - limitWinSample;

% Compute round((fs/2))+limitWinSample.
upperLimit = round(fs/2) + limitWinSample;

% Create a vector of integers from the inverted value of round((fs/2))-limitWinSample to the round((fs/2))+limitWinSample.
windowSamples = lowerLimit:upperLimit;

end
