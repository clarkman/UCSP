function hndl = plot2(varargin)
%
% hndl = plot(obj1)
% hndl = plot(obj1, symbol)
% hndl = plot(obj1, ..., objn)
% hndl = plot(obj1, ..., objn, symbol)
% Plots the Time Data objects versus time using their sample rates.
% Combines the title and source fields as the plot's title.
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


%hndl = figure( 'KeyPressFcn', @relabelAxes );
%hndl = figure( 'WindowButtonUpFcn', @relabelAxes );


for jth = 1 : nargin 
    if( ~isa( varargin{jth}, 'TimeData' ) )
        error( 'plot2 accepts TimeData objects only!!' );
    end
end


symbol = 'none';
numobjs = nargin;


corder = get(gca,'ColorOrder');     % use the standard color ordering matrix
ncolors = size(corder);
ncolors = ncolors(1,1);


xlab = [];
ylab = [];
legnd = cell(numobjs, 1);


if numobjs == 1
    obj = varargin{1};
    obj = offset(obj);
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
        obj = offset(obj);
        startTime = abs(obj.DataCommon.UTCref);
        endTime   = startTime + obj.DataCommon.timeEnd/86400; 
        if  startTime < UTCref
            UTCref = startTime;
        end
        if endTime > UTClast
            UTClast = endTime;
        end
    end
    
    titlestr = ['Overlay', ' (', datenum2str(UTCref), ' to ',datenum2str(UTClast),' UTC )'];
end



% More than 2 days, so shift to day units
scalefactor = 1;
if( UTClast - UTCref > 2 )
    scalefactor = 1 / 86400;
    daXLabel = 'Time (days)';
    dateTickCode = 16;
elseif( UTClast - UTCref > 1/4 ) % Greater than three hours
    scalefactor = 24 / 86400;
    daXLabel = 'Time (hours)';
    dateTickCode = 16;
elseif( UTClast - UTCref > 1/96 )% Greater than fifteen minutes
    scalefactor = 24*60 / 86400;
    daXLabel = 'Time (mins)';
    dateTickCode = 16;
else % Greater than fifteen minutes
    scalefactor = 24*3600 / 86400;
    daXLabel = 'Time (secs)'
    dateTickCode = 13;
end

if 1 % Do PST
    daXLabel = [daXLabel, ' PST'];
    timeZoneOff = -1/3;
else
    daXLabel = [daXLabel, ' UTC'];
    timeZoneOff = 0;
end    


icolor = 1;
for iobj = 1 : numobjs
    hold on;
    
    obj = varargin{iobj};
    %
    % Update plot legend, x-label, y-label, and title
    %
    legnd{iobj} = obj.DataCommon.source;
    if obj.DataCommon.title
        legnd{iobj} = [legnd{iobj}, ', ', obj.DataCommon.title];
    end
    if obj.DataCommon.history
        legnd{iobj} = [legnd{iobj}, ', ', obj.DataCommon.history];
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
    if length(findstr(ylab, objylab)) == 0
        % Only add this label if it is not already present
        if length(ylab) > 0
            ylab = [ylab, ' / '];
        end
        ylab = [ylab, objylab];
    end
    
    
    
    % Compute time indexes (in sec) relative to UTCref, the first point in the plot
    if( obj.DataCommon.UTCref < 0 )
	line(obj.samples(:,1)+obj.timeOffset, obj.samples(:,2), 'Marker', symbol, 'Color', corder(icolor,:));
    else
	%first = (obj.DataCommon.UTCref - UTCref)*86400 + obj.DataCommon.timeOffset;
	%interval = 1 / obj.sampleRate;
	%last =  first + (length(obj.samples)-1)*interval;
	%axisvec = first: interval: last;
	%axisvec = axisvec * scalefactor;
	% axisvec = axisvec + UTCref ;   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        first=obj.DataCommon.UTCref + timeZoneOff;
        interval = (1 / obj.sampleRate) / 86400;
        last =  first + ((length(obj.samples)-1)*interval);
        axisvec = first: interval: last;

	%line(axisvec, obj.samples, 'Marker', symbol, 'Color', corder(icolor,:));
	%plot(axisvec, obj.samples, 'Marker', symbol, 'Color', corder(icolor,:));
        ts = timeseries(obj.samples,axisvec,'IsDatenum',true)
        
        tstool( ts )
    end
    
    % Rotate through the colors
    icolor = mod(icolor, ncolors);
    icolor = icolor + 1;
    
    hold off;
end

return

%datenum2str(UTCref);
%datenum2str(UTClast);
%set(gca,'XLim',[axisvec(1) axisvec(end)]);
%datetick( 'x', dateTickCode, 'keeplimits' )
%set(get(gcf,'CurrentAxes'),'XLim',[UTCref UTClast]);

title(titlestr);

if numobjs > 1
    legend(char(legnd));
end

grid on;

orient landscape;

ylabel(ylab);

if scalefactor < 1
    xlabel(daXLabel);
else
    xlabel(xlab); % seconds
end

% Set Plot type code;
set(gcf,'UserData',Zoom_Types( 'TimeDataAbsolute' ));


% Get tick values
%xt = get(gca,'XTick')

% Convert to time string
%xtl = datenum2str(xt, 'date')

% Set ticks to the time string
%set(gca,'XTickLabel',xtl);
