function obj = loadLogEvents( obj, fileName, level, siteNum )
%
%  Load qf.log file for analysis
%

FATAL_TYPE=0;
ERROR_TYPE=1;
WARNING_TYPE=2;
INFO_TYPE=3;

if nargin < 3
    level = 3;
end

fid = fopen( fileName );
if fid == -1, error('File open failed');, end;


numLines = 0;
while 1
    daLine = fgetl( fid );
    if( daLine == -1 )
        break;
    end
    numLines = numLines + 1;
    
    if( strfind( daLine, 'Modem name found:' ) )
        tags=strfind(daLine,'cmn');
        siteNum=daLine(tags(end)+3:tags(end)+5);
    end

end
frewind(fid);
numLines

if( ischar(siteNum) )
    sid = sscanf( siteNum, '%d' );
else
    sid = siteNum;
end
if( sid < 700 || sid > 1000 )
    error( 'Bad site number' );
end
sid

eventArray = zeros( numLines, 7 );
eventStrs = cell( numLines, 1 );
numEvents = 0;
for evt = 1 : numLines
    daLine = fgetl( fid );
    numChars = length(daLine);

   % Filter out obvious charlatans
    if( numChars < 27 )
        continue;
    end
    spaces = strfind( daLine, ' ' );
    if( length(spaces) < 4 )
        continue;
    end

   % Filter out ununsed for level
    type = daLine(1:spaces(1)-1);
    if( level < 3 && ~isempty(findstr(type,'INFO')) )
        continue;
    end
    if( level < 2 && ~isempty(findstr(type,'WARNING')) )
        continue;
    end
    if( level < 1 && ~isempty(findstr(type,'ERROR')) )
        continue;
    end

   % Pluck and check datetime
    dateTimeStr = [ daLine(spaces(2)+1:spaces(3)-1), ' ', daLine(spaces(3)+1:spaces(4)-1)];
    if( dateTimeStr(5) ~= '-' || ...
        dateTimeStr(8) ~= '-' || ...
        dateTimeStr(14) ~= ':' || ...
        dateTimeStr(17) ~= ':' )
            continue;
    end

   % Okay, it's an event.
   %
   % startTime, endTime, network, station, channel, type, subtype
   %
    numEvents = numEvents + 1;
    eventArray(numEvents,1) = str2datenum(sql2stdDate(dateTimeStr));
    eventArray(numEvents,2) = eventArray(numEvents,1);
    eventArray(numEvents,3) = 1; % CalMagNet
    eventArray(numEvents,4) = sid; % Site number
    eventArray(numEvents,5) = 0; % 0 = All channels
    if( ~isempty(findstr(type,'INFO')) )
        eventArray(numEvents,6) = INFO_TYPE;
    elseif( ~isempty(findstr(type,'WARNING')) )
        eventArray(numEvents,6) = WARNING_TYPE;
    elseif( ~isempty(findstr(type,'ERROR')) )
        eventArray(numEvents,6) = ERROR_TYPE;
    elseif( ~isempty(findstr(type,'FATAL')) )
        eventArray(numEvents,6) = FATAL_TYPE;
    end
    eventArray(numEvents,7) = 0; % For now
    eventStrs{numEvents} = [ daLine(spaces(1)+1:spaces(1)), daLine(spaces(4)+1:end) ];


end

fclose(fid);

obj.events=eventArray;

obj.strings=eventStrs;


