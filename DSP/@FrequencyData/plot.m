function hndl = plot(obj, symbol, value)
%
% Plots input data against time based on the sampling rate
% (samples/sec)
% Combines the title and source fields as the plot's title.
% Optional:  Uses "symbol" (as defined in the Matlab "plot" function) as
% the symbol for each plotted point.

axisvec = freqVector(obj);

if (nargin == 2)
    plot(axisvec, obj.samples, symbol);
elseif( nargin == 3 )
    plot(axisvec, obj.samples, symbol, value );
else
    plot(axisvec, obj.samples);
end

str = buildPlotTitle(obj);
title(str);


xlabel(obj.axisLabel);
xlabel( [ obj.axisLabel, '   (',num2str(obj.freqResolution), ' Hz resolution)' ] );
%ylabel(obj.axisLabel);
ylabel( [ obj.valueType, ' (', obj.valueUnit, ')' ] );
%[ obj.valueType, ' (', obj.valueUnit, ')' ]
grid on;

orient landscape;
