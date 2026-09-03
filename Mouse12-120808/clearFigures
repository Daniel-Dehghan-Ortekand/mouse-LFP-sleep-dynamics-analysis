%% Figure cleanup function
% This function removes previously saved MATLAB figure (.fig) and image
% (.png) files from the specified folder to prevent outdated figures from
% remaining in the output directory before saving new analysis results.

function clearFigures(folderPath)
% Specify the path of the folder
% folderPath = 'C:\MyFigures';

% Clear all .fig files in the folder
files = dir(fullfile(folderPath, '*.fig'));
for iFile = 1:length(files)
    delete(fullfile(folderPath, files(iFile).name));
end

% Clear all .png files in the folder
files = dir(fullfile(folderPath, '*.png'));
for iFile = 1:length(files)
    delete(fullfile(folderPath, files(iFile).name));
end
end
