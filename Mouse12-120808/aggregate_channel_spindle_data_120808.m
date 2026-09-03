% =========================================================================
% SCRIPT: Aggregate Channel-Specific Spindle Detections into a Single File
% SUBJECT: Mouse12-120808
% =========================================================================
% DESCRIPTION:
% Iterates through all 64 recording channels to load individual sleep 
% spindle detection files. Consolidates these separate, channel-specific 
% spindle events into a single unified cell array structure for easier 
% downstream analysis, data management, and batch processing.
%
% INPUTS:
%   - thal_spindles_120808_ch[1-64].mat: Individual spindle detection 
%     files for each of the 64 channels.
%
% OUTPUTS:
%   - thal_spindles3.mat: A single .mat file containing a 1x64 cell array 
%     ('thal_spindles') where each cell holds the spindle data for its 
%     respective channel.
% =========================================================================

clc 
clear 
close all 
%%

% pathsthal = dir('*/thal_spindles_ch*');


for k=1:64
% 
%     filename = strcat(pathsthal(k).folder, filesep, pathsthal(k).name); % Use filesep instead of just '/'
%     data = load(filename);
       data= load(['thal_spindles_120808_ch' num2str(k)]); 
      thal_spindles{k} = data;
%     save(['thal_spindles' num2str(k)], 'thal_spindles', '-v7.3');
%         clear data

end
save thal_spindles3.mat thal_spindles
%%

