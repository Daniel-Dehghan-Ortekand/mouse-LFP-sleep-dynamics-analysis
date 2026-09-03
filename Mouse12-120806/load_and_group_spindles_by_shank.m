% =========================================================================
% SCRIPT: Load and Group Sleep Spindle Detections by Probe Shank
% SUBJECT: Multi-channel Thalamic Recording (64 Channels)
% =========================================================================
% DESCRIPTION:
% Iterates through a 64-channel recording to load individual sleep spindle 
% detection files, grouping them by the 8 physical shanks of the probe 
% (8 channels per shank). This structure is typically used as a precursor 
% to analyzing spindle synchrony, propagation, or spatial overlap within 
% and across individual shanks.
%
% INPUTS:
%   - thal_ch_norm_filtered.mat: Filtered LFP data (loaded but not used).
%   - thal_spindles_ch[X].mat: Individual spindle detection files for 
%     each of the 64 channels.
%
% OUTPUTS:
%   - Loads the spindle data into the MATLAB workspace.
%   - (Recommended) Stores the data in a structured cell array for 
%     downstream shank-specific analysis.
% =========================================================================

clc 
clear 
% close all
ch_num = 64;
fs=1250;
%%
load('thal_ch_norm_filtered.mat')

for i=1:8:ch_num
    load  (['thal_spindles_ch' num2str(i) '.mat'])
    for j=i+1:i+8
        load  (['thal_spindles_ch' num2str(j+1) '.mat'])
        
    end 
end 
