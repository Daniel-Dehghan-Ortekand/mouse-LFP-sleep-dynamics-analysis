% =========================================================================
% SCRIPT: Aggregate Channel-Specific Spindle Peak Data into a Single File
% SUBJECT: Mouse12-120808
% =========================================================================
% DESCRIPTION:
% Iterates through all 64 recording channels to load individual spindle 
% peak detection files. Consolidates these separate, channel-specific peak 
% amplitude and location data into a single unified cell array structure 
% for streamlined downstream analysis and batch processing.
%
% INPUTS:
%   - real_peaks_120808_[1-64].mat: Individual peak detection files for 
%     each of the 64 channels (containing peak amplitudes and sample 
%     indices for each detected spindle event).
%
% OUTPUTS:
%   - real_peaks3.mat: A single .mat file containing a 1x64 cell array 
%     ('real_peaks') where each cell holds the peak data for its 
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
       data= load(['real_peaks_120808_' num2str(k)]); 
      real_peaks{k} = data;
%     save(['thal_spindles' num2str(k)], 'thal_spindles', '-v7.3');
%         clear data

end
save real_peaks3.mat real_peaks
%%

