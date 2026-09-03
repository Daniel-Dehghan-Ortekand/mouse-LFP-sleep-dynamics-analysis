%% Change Current Working Directory
% This utility function changes the MATLAB working directory to a specified
% folder after verifying that the folder exists. An error is returned if
% the provided directory is invalid.

function changeCurrentFolder(newfolder)
%Check if newfolder is a valid folder 
if ~exist(newfolder ,'dir')
    error('newfolder does not exist.')

end 
%change the current folder 
cd(newfolder)

end
