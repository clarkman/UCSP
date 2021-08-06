function points = pickPoints()
%
% Let the user pick a set of points from the current figure. Find the
% actual data value that is closest to the mouse click.
% Display each point as it is selected; display the actual data value (not
% the pixel where the mouse was clicked).


% Get the corresponding source object for the current figure
figureObj = getappdata(gcf, 'sourceData');

hold on
% Initially, the list of points is empty.
points = [];
n = 0;
% Loop, picking up the points.
disp('Left mouse button picks points. Right mouse button picks last point.');

btn = 1;
while btn == 1
    [xi,yi,btn] = ginput(1)
    
    % Find the nearest actual data value to the selected mouse click
    [xii, yii] = nearestPoint(figureObj, xi, yi);
    
    plot(xii,yii,'ko')
    %plot(xi,yi,'ko')
    n = n+1;
    points(:,n) = [xii;yii];
    %points(:,n) = [xi;yi];
end
