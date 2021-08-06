function overlay(obj, symbol)
%
% Plots obj against time based on obj's sampling rate
% Combines the title and source fields as the plot's title.
% Optional:  Uses "symbol" (as defined in the Matlab "plot" function) as
% the symbol for each plotted point.

hold on;
newplot;

first = obj.DataCommon.timeOffset;
interval = 1 / obj.sampleRate;
last =  first + (length(obj.samples)-1)*interval;

axisvec = first: interval: last;

if (nargin == 2)
    plot(axisvec, obj.samples, symbol);
else
    plot(axisvec, obj.samples);
end

str = buildPlotTitle(obj);

title(str);

xlabel(obj.axisLabel);
ylabel([obj.valueType, ' (', obj.valueUnit, ')']);
grid on;

orient landscape;

hold off;
