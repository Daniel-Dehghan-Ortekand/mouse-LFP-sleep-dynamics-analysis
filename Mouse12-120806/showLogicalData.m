function showLogicalData(logicalData)
% =========================================================================
% FUNCTION: showLogicalData - Visualize 2D Logical Matrices
% =========================================================================
% DESCRIPTION:
% Renders a 2D logical matrix as a color-coded image, where 'false' (0) 
% values are displayed in red and 'true' (1) values are displayed in blue. 
% This is highly useful for visualizing event detection masks, spike rasters, 
% or binary channel states over time.
%
% INPUTS:
%   - logicalData : 2D logical or numeric matrix (Channels x Time).
%
% OUTPUTS:
%   - Generates a new figure window displaying the logical matrix.
% =========================================================================
% Get the size of the logical data.
[numRows, numCols] = size(logicalData);

% Create a new figure.
figure;

% Plot the logical data using different colors for true and false values.
for i = 1:numRows
    for j = 1:numCols
        if logicalData(i, j)
            plot(j, i, 'ob', 'MarkerSize', 10);
        else
            plot(j, i, 'xr', 'MarkerSize', 10);
        end
    end
end

% Set the axis limits.
axis([0 numCols 0 numRows]);

% Add labels to the x- and y-axes.
xlabel('Time (samples)');
ylabel('Channel');

% Set the title of the figure.
title('Logical Data');

end
