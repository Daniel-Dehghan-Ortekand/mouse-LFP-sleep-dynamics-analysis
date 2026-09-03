% =========================================================================
% SCRIPT: Aggregate Channel-Specific Spindle Peak Data into a Single File
% SUBJECT: N/A (General batch processing script)
% =========================================================================
% DESCRIPTION:
% Iterates through 61 recording channels to load individual spindle 
% peak detection files. Consolidates these separate, channel-specific peak 
% amplitude and location data into a single unified cell array structure 
% for streamlined downstream analysis and batch processing.
%
% INPUTS:
%   - real_peaks[1-61].mat: Individual peak detection files for 
%     each of the 61 channels (containing peak amplitudes and sample 
%     indices for each detected spindle event).
%
% OUTPUTS:
%   - real_peaks1.mat: A single .mat file containing a 1x61 cell array 
%     ('real_peaks') where each cell holds the peak data for its 
%     respective channel.
% =========================================================================

clc 
clear 
close all 
%%

% pathsthal = dir('*/thal_spindles_ch*');


for k=1:61
% 
%     filename = strcat(pathsthal(k).folder, filesep, pathsthal(k).name); % Use filesep instead of just '/'
%     data = load(filename);
       data= load(['real_peaks' num2str(k)]); 
      real_peaks{k} = data;
%     save(['thal_spindles' num2str(k)], 'thal_spindles', '-v7.3');
%         clear data

end
save real_peaks1.mat real_peaks
%%

