%SPIKERASTER Generate a raster plot of spike activity aligned to events.
%   This function converts spike samples to time coordinates and displays
%   each spike as a horizontal line for each trial. The raster is plotted
%   within the specified time range, with the line length controlled by
%   the input linesize parameter.
%
%   Inputs:
%       data_raster - Binary spike raster matrix (trials × samples).
%       fs          - Sampling frequency in Hz.
%       range       - Time range for the raster plot [start end] in seconds.
%       linesize    - Half-length of each spike marker in seconds.
%
%   Outputs:
%       data_raster - Input spike raster matrix.
%       t           - Time vector corresponding to the raster samples.
%
%   The function is used to visualize trial-by-trial spike timing relative
%   to an event, with each row representing one trial and each horizontal
%   line representing an individual spike.


function [data_raster, t] = SpikeRaster(data_raster, fs, range, linesize)
%SPIKERASTER Summary of this function goes here
%   Detailed explanation goes here

t = range(1):1/fs:range(2);

hold on
for trialCount = 1:size(data_raster,1)
    spikePos = t(data_raster(trialCount, :) == 1);
    for spikeCount = 1:length(spikePos)
        plot([spikePos(spikeCount)-linesize spikePos(spikeCount)+linesize], ...
            [trialCount trialCount], 'k', 'LineWidth', 2);
    end
end
xlim(range)
ylim([1 trialCount])

end
