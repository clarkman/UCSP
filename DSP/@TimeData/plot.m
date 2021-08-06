function hndl = plot(varargin)
%
% hndl = plot(obj1)
% hndl = plot(obj1, symbol)
% hndl = plot(obj1, ..., objn)
% hndl = plot(obj1, ..., objn, symbol)
% Plots the Time Data objects versus time using their sample rates.
% Combines the title and source fields as the plot title.
%
% "symbol" is optional; it is a single character that indicates the MatLab
% marker symbol to use for each plotted point, as follows (from the Marker property):
%   + plus sign
%   o circle
%   * asterisk
%   . point
%   x cross
%   s square
%   d diamond
%   ^ upward pointing triangle
%   v downward pointing triangle
%   > right pointing triangle
%   < left pointing triangle
%   p five-pointed star (pentagram)
%   h six-pointed star (hexagram)
%
% Returns a handle to the figure, which can be used, for example, to save it as a file
%

%if( ~ishold )
%    hndl = figure;
%else
%    hndl = -1;
%end

useUTCscale = 0;



lastArg = varargin{nargin};
if ischar(lastArg) && length(lastArg) == 1
    % Last argument is a marker character
    symbol = lastArg;
    numobjs = nargin-1;
else
    symbol = 'none';
    numobjs = nargin;
end

corder = get(gca,'ColorOrder');     % use the standard color ordering matrix
ncolors = size(corder);
ncolors = ncolors(1,1);


xlab = [];
ylab = [];
legnd = cell(numobjs, 1);


if numobjs == 1
    obj = varargin{1};
    UTCref = abs(obj.DataCommon.UTCref);
    UTClast = abs(obj.DataCommon.UTCref) + obj.DataCommon.timeEnd/86400;
    % For only one object, use its full plot title
    titlestr = buildPlotTitle(obj);
else
    % Find the time range of all of the objects
    UTCref = inf;       %  plus infinity
    UTClast = 0;
    for iobj = 1 : numobjs
        obj = varargin{iobj};
        startTime = abs(obj.DataCommon.UTCref) + obj.DataCommon.timeOffset/86400;
        endTime   = abs(obj.DataCommon.UTCref) + obj.DataCommon.timeEnd/86400; 
        if  startTime < UTCref
            UTCref = startTime;
        end
        if endTime > UTClast
            UTClast = endTime;
        end
    end
    
    titlestr = ['Overlay', ' (', datenum2str(UTCref), ' UTC)'];
end

% More than 2 days, so shift to day units
scalefactor = 1;
dayDuration = UTClast - UTCref;
secsDuration = dayDuration * 86400;

if( useUTCscale )
    if dayDuration > 2
        scalefactor = 1 / 86400;
        daXLabel = 'Time (days)';
    elseif dayDuration > 1/4 % Greater than three hours
        scalefactor = 24 / 86400;
        daXLabel = 'Time (hours)';
    elseif dayDuration > 1/96 % Greater than fifteen minutes
        scalefactor = 24*60 / 86400;
        daXLabel = 'Time (mins)';
    end
else
    numTicksPlotted = 8;
end

icolor = 1;
for iobj = 1 : numobjs
    obj = varargin{iobj};
    %
    % Update plot legend, x-label, y-label, and title
    %
    if 0
	legnd{iobj} = obj.DataCommon.source;
	if obj.DataCommon.title
            legnd{iobj} = [legnd{iobj}, ', ', obj.DataCommon.title];
	end
	if obj.DataCommon.history
            legnd{iobj} = [legnd{iobj}, ', ', obj.DataCommon.history];
	end
    else
	legnd{iobj} = [ obj.DataCommon.network, obj.DataCommon.station, ' ' obj.DataCommon.channel ];
    end
        
    objxlab = obj.axisLabel;
    if length(findstr(xlab, objxlab)) == 0
        % Only add this label if it is not already present
        if length(xlab) > 0
            xlab = [xlab, ' / '];
        end
        xlab = [xlab, objxlab];
    end

    objylab = [obj.valueUnit];
    % XXX Clark ORIGINAL always crashes    objylab = [obj.valueType, ' (', obj.valueUnit, ')'];
    if length(findstr(ylab, objylab)) == 0
        % Only add this label if it is not already present
        if length(ylab) > 0
            ylab = [ylab, ' / '];
        end
        ylab = [ylab, objylab];
    end

    % Compute time indexes (in sec) relative to UTCref, the first point in the plot
    interval = 1 / obj.sampleRate;
    if( useUTCscale )
        error( 'Needs bedbug' )
        first = (obj.DataCommon.UTCref)*86400 + obj.DataCommon.timeOffset;
        last =  first + (length(obj.samples)-1)*interval;
        axisvec = first: interval: last;
        axisvec = axisvec * scalefactor;
        %axisvec = axisvec + UTCref ;   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        line(axisvec, obj.samples, 'Marker', symbol, 'Color', corder(icolor,:));
        datetick('x',2)
        set( gca, 'XLim', [axisvec(1), axisvec(end)] )

        ylabel(ylab);
        if scalefactor < 1
            xlabel(daXLabel);
        else
            xlabel(xlab); % seconds
        end
    else
        axisvec = interval/2 : interval : secsDuration + interval;
        axisvec = axisvec( 1:length(obj.samples) )';
        line(axisvec, obj.samples, 'Marker', symbol, 'Color', corder(icolor,:));

        set( gca, 'XLim', [axisvec(1)-interval, axisvec(end)] );

        span = axisvec(end) - axisvec(1) + interval;        
        [ xAxisLabel, tickMarks, tickMarkLabels ] = timeLabeler( span, numTicksPlotted );
        
        set( gca, 'XTick', tickMarks );
        xlabel( xAxisLabel );
        set( gca, 'XTickLabel', tickMarkLabels );

        ylabel(ylab);                      
    end
    
    % Rotate through the colors
    icolor = mod(icolor, ncolors);
    icolor = icolor + 1;
end

title(titlestr);

if numobjs > 1
    legend(char(legnd));
end

grid on;
orient landscape;

% Set Plot type code;
set( gcf,'UserData', Zoom_Types( 'SecsData' ) );


% Get tick values
%xt = get(gca,'XTick')

% Convert to time string
%xtl = datenum2str(xt, 'date')

% Set ticks to the time string
%set(gca,'XTickLabel',xtl);
