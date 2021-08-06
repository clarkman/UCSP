function hndl = plot3( obj )
%
% hndl = plot3(obj, plotType)
%
% Plot amplitude as colors (omit plotType)
% plotType -- optional; if = 'mesh', then plot using a 3D mesh
%
% Returns a handle to the figure, which can be used to save it as a file
%

siz = size(obj.samples);

%tdata=TimeData(obj.DataCommon.source);

timefirst = obj.DataCommon.timeOffset;
interval = 1 / obj.sampleRate;
nyquist = obj.sampleRate / 2.0;
timelast =  timefirst + (siz(2)-1)*interval;
timeaxisvec = timefirst: interval: timelast;


freqfirst = 0;
interval = obj.freqResolution;
freqlast =  (siz(1)-1)*interval;
freqaxisvec = freqfirst: interval: freqlast;

hndl = figure;
% Save the obj in the figure's handle, so we can get back to the data
setappdata(hndl, 'sourceData', obj);

[X Y] = meshgrid(timeaxisvec, freqaxisvec);
%mesh(X, Y, obj.samples);
surf(X, Y, obj.samples);

shading interp;

view([-150,45]);

str = buildPlotTitle(obj);
title(str);


xlabel([obj.timeAxisLabel, '   (', num2str(1/obj.sampleRate), ' sec resolution)']);
ylabel([obj.freqAxisLabel, '   (', num2str(obj.freqResolution), ' Hz resolution)']);
zlabel([obj.valueType, ' (', obj.valueUnit, ')']);

grid on;

% Force these as Matlab "auto overshoots.
yLims=get(get(gcf,'CurrentAxes'),'YLim');
set(get(gcf,'CurrentAxes'),'YLim',[yLims(1) nyquist]);

set(get(gcf,'CurrentAxes'),'XLim',[0 timelast]);

lighting gouraud
set(gcf,'Renderer','OpenGL');
%caxis([40 90]);

orient landscape;
