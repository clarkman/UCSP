function hndl = plot(inObj)
%
% hndl = plot(obj, plotType)
%
% Plot amplitude as colors (omit plotType)
% plotType -- optional; if = 'mesh', then plot using a 3D mesh
%
% Returns a handle to the figure, which can be used to save it as a file
%

obj = offset( inObj );

siz = size( obj.samples );

UTCref = obj.DataCommon.UTCref;
UTClast = obj.DataCommon.UTCref + obj.DataCommon.timeEnd/86400;

% More than 2 days, so shift to day units
scalefactor = 1;
if UTClast - UTCref > 2
    %scalefactor = 1 / 86400;
    daXLabel = 'Time (days)';
    dateForm = 19;
elseif UTClast - UTCref > 1/4 % Greater than three hours
    %scalefactor = 24 / 86400;
    daXLabel = 'Time (hours)';
    dateForm = 13;
elseif UTClast - UTCref > 1/96 % Greater than fifteen minutes
    %scalefactor = 24*60 / 86400;
    daXLabel = 'Time (mins)';
    dateForm = 13;
else % Default
    %scalefactor = 1;
    daXLabel = 'Time (secs)';
    dateForm = 13;
end


if 0 % Do PST
    daXLabel = [daXLabel, ' PST'];
    timeZoneOff = -1/3;
else
    daXLabel = [daXLabel, ' UTC'];
    timeZoneOff = 0;
end    



timefirst = obj.DataCommon.timeOffset;  % zeroed by offset, but left intact deliberately
interval = 1 / obj.sampleRate;
timelast =  timefirst + (siz(2)-1)*interval;
timeaxisvec = timefirst: interval: timelast;
timeaxisvec = timeaxisvec ./ 86400;

timeaxisvec = timeaxisvec + UTCref + timeZoneOff;


freqfirst = 0;
interval = obj.freqResolution;
freqlast =  (siz(1)-1)*interval;
freqaxisvec = freqfirst: interval: freqlast;


hndl = figure;
% Save the obj in the figure's handle, so we can get back to the data
setappdata(hndl, 'sourceData', obj);

imagesc(timeaxisvec, freqaxisvec, obj.samples);
axis xy;

str = buildPlotTitle(obj);
title(str);


xlabel([daXLabel, '   (', num2str(1/obj.sampleRate), ' sec resolution)']);
ylabel([obj.freqAxisLabel, '   (', num2str(obj.freqResolution), ' Hz resolution)']);
zlabel([obj.valueType, ' (', obj.valueUnit, ')']);

colormap(jet(256));

cRange = obj.colorRange;
if( cRange(1) == -1 && cRange(2) == -1 )
    % Allow auto color default
    display( 'Color range values are auto color' );
else
    if( cRange(1) == cRange(2) )
        % Allow auto color
        warning( 'Color range values are equal, defaulting to auto color' );
    else
        if( cRange(1) > cRange(2) )
            error( 'Color range min greater than max' );
        else
            caxis( cRange );
        end
    end
end

datetick('x', dateForm, 'keeplimits' );

%colorbar

grid on;

orient landscape;
