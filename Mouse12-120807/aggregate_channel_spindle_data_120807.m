% =========================================================================
% SCRIPT: Aggregate Channel-Specific Spindle Detections into a Single File
% SUBJECT: Mouse12-120807
% =========================================================================
% DESCRIPTION:
% Iterates through 63 recording channels to load individual sleep spindle 
% detection files. Consolidates these separate, channel-specific spindle 
% events into a single unified cell array structure for easier downstream 
% analysis, data management, and batch processing.
%
% INPUTS:
%   - thal_spindles_120807_ch[1-63].mat: Individual spindle detection 
%     files for each of the 63 channels.
%
% OUTPUTS:
%   - thal_spindles2.mat: A single .mat file containing a 1x63 cell array 
%     ('thal_spindles') where each cell holds the spindle data for its 
%     respective channel.
% =========================================================================

clc 
clear 
close all 
%%

% pathsthal = dir('*/thal_spindles_ch*');


for k=1:63
% 
%     filename = strcat(pathsthal(k).folder, filesep, pathsthal(k).name); % Use filesep instead of just '/'
%     data = load(filename);
       data= load(['thal_spindles_120807_ch' num2str(k)]); 
      thal_spindles{k} = data;
%     save(['thal_spindles' num2str(k)], 'thal_spindles', '-v7.3');
%         clear data

end
save thal_spindles2.mat thal_spindles
%%

