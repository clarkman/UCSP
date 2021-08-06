function showVerticalLine(xpos, ymin, ymax)
% showVerticalLine(position)
% Adds a vertical line at the specified x-axis position to the current plot figure


line([xpos xpos], [ymin ymax], 'Color', 'r');



