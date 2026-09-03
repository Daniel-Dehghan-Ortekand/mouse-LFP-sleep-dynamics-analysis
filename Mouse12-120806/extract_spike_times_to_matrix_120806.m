% =========================================================================
% SCRIPT: Convert Spike Time Cell Array to Zero-Padded Numeric Matrix
% SUBJECT: Mouse12-120806
% =========================================================================
% DESCRIPTION:
% Loads spike time data stored as a cell array (where each cell contains 
% the spike times for a single unit) and converts it into a uniform, 
% zero-padded numeric matrix. This standardizes the data format for 
% downstream analyses that require matrix operations rather than cell 
% array iterations, such as binary spike train generation or population 
% firing rate calculations.
%
% INPUTS:
%   - Mouse12-120806.spikes.cellinfo.mat: Cell array of spike times 
%     (variable: spikes.times).
%
% OUTPUTS:
%   - SpikesTimesAllCells.mat: A numeric matrix (MaxSpikes x NumCells) 
%     containing the spike times for each unit, zero-padded to match the 
%     length of the longest spike train.
% =========================================================================

clc
clear 
close all

load    Mouse12-120806.spikes.cellinfo.mat
CellNum = size(spikes.times ,2);
%choose the longest length for Cell array 
MaxLen = 0;
for j=1:CellNum
    if length(spikes.times{1,j})>MaxLen
        MaxLen = length((spikes.times{1,j}));
    end
end  

% exclude spikes times from cell array to a matrix
SpikesTimesAllCells = zeros(MaxLen,CellNum);
for i=1:CellNum
 SpikesTimesAllCells(1:length(spikes.times{:,i}),i) = cell2mat(spikes.times(:,i));
end 

%save data 
save    SpikesTimesAllCells.mat SpikesTimesAllCells
