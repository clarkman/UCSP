function obj = loadSyslogdEvents( obj, fileName, siteNum )
%
%  Load qf.log file for analysis
%

FATAL_TYPE=0;
ERROR_TYPE=1;
WARNING_TYPE=2;
INFO_TYPE=3;


fid = fopen( fileName );
if fid == -1, error('File open failed');, end;


numLines = 0;
while 1
    daLine = fgetl( fid );
    if( daLine == -1 )
        break;
    end
    numLines = numLines + 1;
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
    if( length(spaces) < 5 )
        continue;
    end

   % Pluck and check datetime
    dateTimeStr = daLine(1:15);
    if( dateTimeStr(4) ~= ' ' || ...
        dateTimeStr(7) ~= ' ' || ...
        dateTimeStr(10) ~= ':' || ...
        dateTimeStr(13) ~= ':' )
            continue;
    end

   % Okay, it's an event.
   %
   % startTime, endTime, network, station, channel, type, subtype
   %
    numEvents = numEvents + 1;

   % Convert time.  (Year is not given)
   % Typ: 'May  6 23:24:48'
    mon=Mon2mm( dateTimeStr(1:3) );
    day=sprintf('%02d',sscanf( dateTimeStr(5:6), '%d') ); % changes ' 7' to '07'
    time=dateTimeStr(8:15);
    eventArray(numEvents,1) = str2datenum( [ '2011/', mon, '/', day, ' ', time ] );
    eventArray(numEvents,2) = eventArray(numEvents,1);
    eventArray(numEvents,3) = 1; % CalMagNet
    eventArray(numEvents,4) = sid; % Site number
    eventArray(numEvents,5) = 0; % 0 = All channels
    eventArray(numEvents,6) = WARNING_TYPE;
    eventArray(numEvents,7) = 0; % For now
    eventStrs{numEvents} = daLine(27:end);

end

fclose(fid);

obj.events=eventArray;

obj.strings=eventStrs;


