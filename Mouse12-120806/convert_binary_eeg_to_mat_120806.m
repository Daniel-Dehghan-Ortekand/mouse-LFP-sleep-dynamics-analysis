% =========================================================================
% SCRIPT: Load Raw Binary EEG and Save as .mat File
% SUBJECT: Mouse12-120806
% =========================================================================
% DESCRIPTION:
% Reads a continuous 90-channel raw EEG recording from a binary file 
% using a custom binary loader function and saves the loaded data as a 
% MATLAB .mat file (v7.3 format) for efficient downstream processing.
%
% INPUTS:
%   - Mouse12-120806.eeg: Raw binary EEG recording file (90 channels, 
%     1250 Hz sampling rate).
%
% OUTPUTS:
%   - thal_allchanel_Mouse12_120806_new_90.mat: MATLAB file containing 
%     the full continuous LFP data matrix.
%
% DEPENDENCIES:
%   - Custom function: bz_LoadBinary (for reading the raw .eeg file).
% =========================================================================

%%read the .EEG file and save all channel
clear 
clc
thal_allchanel_Mouse12_120806_new = bz_LoadBinary('Mouse12-120806.eeg','nChannels',90,'frequency',1250);
fs=1250;
save thal_allchanel_Mouse12_120806_new_90 -v7.3
