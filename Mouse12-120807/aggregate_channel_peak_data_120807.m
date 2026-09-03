% =========================================================================
% SCRIPT: Aggregate Channel-Specific Spindle Peak Data into a Single File
% SUBJECT: Mouse12-120807
% =========================================================================
% DESCRIPTION:
% Iterates through 63 recording channels to load individual spindle 
% peak detection files. Consolidates these separate, channel-specific peak 
% amplitude and location data into a single unified cell array structure 
% for streamlined downstream analysis and batch processing.
%
% INPUTS:
%   - real_peaks_120807_[1-63].mat: Individual peak detection files for 
%     each of the 63 channels (containing peak amplitudes and sample 
%     indices for each detected spindle event).
%
% OUTPUTS:
%   - real_peaks2.mat: A single .mat file containing a 1x63 cell array 
%     ('real_peaks') where each cell holds the peak data for its 
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
       data= load(['real_peaks_120807_' num2str(k)]); 
      real_peaks{k} = data;
%     save(['thal_spindles' num2str(k)], 'thal_spindles', '-v7.3');
%         clear data

end
save real_peaks2.mat real_peaks
%%

