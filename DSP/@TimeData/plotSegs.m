function hndl = plotSegs(varargin)
%
%
% 
% hndl = plot( timeDataObj );
% hndl = plot( timeDataObjCellArray );
%

if( nargin ~= 2 )
    display( 'DSP/@TimeData/plotSegs()' );
    display( 'This routine expects either a single TimeData object or a cell array of them as a first argument.  The second argument must either be cmn or bk' );
end

if( iscell( varargin{1} ) )
    numObjs  = length(objArray);
    objArray = varargin{1};
    for ith = 1 : numObjs
        if( ~isa( objArray{ith}, 'TimeData' ) )
	    error( 'All objects must be in the form of TimeData objects' );	    
	end
    end
else
    numObjs = 1;
    objs{1} = varargin{1};    
end

typeString = varargin{2};
type = 0;
if( strcmp( typeString, 'cmn' ) )
    type = 1;
end
if( strcmp( typeString, 'bk' ) )
    type = 2;
end
if( type == 0 )
    error( '' )
end


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
if UTClast - UTCref > 2
    scalefactor = 1 / 86400;
    daXLabel = 'Time (days)';
elseif UTClast - UTCref > 1/4 % Greater than three hours
    scalefactor = 24 / 86400;
    daXLabel = 'Time (hours)';
elseif UTClast - UTCref > 1/96 % Greater than fifteen minutes
    scalefactor = 24*60 / 86400;
    daXLabel = 'Time (mins)';
end


icolor = 1;
for iobj = 1 : numobjs
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
% XXX Clark ORIGINAL always crashes    objylab = [obj.valueType, ' (', obj.valueUnit, ')'];
    if length(findstr(ylab, objylab)) == 0
        % Only add this label if it is not already present
        if length(ylab) > 0
            ylab = [ylab, ' / '];
        end
        ylab = [ylab, objylab]
    end
    
    % Compute time indexes (in sec) relative to UTCref, the first point in the plot
    if( obj.DataCommon.UTCref < 0 )
        display('Hello Kitty');
	line(obj.samples(:,1), obj.samples(:,2), 'Marker', symbol, 'Color', corder(icolor,:));
    else
	first = (obj.DataCommon.UTCref - UTCref)*86400 + obj.DataCommon.timeOffset;
	interval = 1 / obj.sampleRate;
	last =  first + (length(obj.samples)-1)*interval;

	axisvec = first: interval: last;

	axisvec = axisvec * scalefactor;

	% axisvec = axisvec + UTCref ;   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	line(axisvec, obj.samples, 'Marker', symbol, 'Color', corder(icolor,:));
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

ylabel(ylab);

if scalefactor < 1
    xlabel(daXLabel);
else
    xlabel(xlab); % seconds
end



% Get tick values
%xt = get(gca,'XTick')

% Convert to time string
%xtl = datenum2str(xt, 'date')

% Set ticks to the time string
%set(gca,'XTickLabel',xtl);
