function success = clearFBDataBase(varargin)
% function success = clearFBDataBase(varargin)
% function success = clearFBDataBase([startTime],[endTime],[network], ...
%                                       [station],[band],[channel],[exact])
% 
% This function clears data from the database table "daily_FB_excursions".
% The data is cleared by calling the perl script "clearFBEvents.plx". The 
% directory for the perl script is "/home/matlab/QFDC/streams/CalMagNet".
% This function can be used in several ways based on the optional
% arguments input to the function. The arguments are described below. Note
% that the optional arguments can occur in any order and are input as 
% follows: 
% 
%   clearFBDataBase('argType1',argVal1, ... ,'argTypeN',argValN)
% 
% Optional Input Arguments:
%   'startTime' - Clear excursions that begin or end after startTime (UTC)
%   'endTime' - Clear excursions that begin or end before endTime (UTC)
%   'network' - Clear excursions on specified network
%   'station' - Clear excursions for specific station ID
%   'band' - Clear excursions for specific FB band
%   'channel' - Clear excursions for specific data channel
%   'EventType' - Clear excursions of specific event type
%   'SubEventType' - Clear excursions of specific subevent type
%   'LimitValue' - Clear excursions of specific limit value
%   'ExcurCriteriaOut' - Clear excursions with specific excur criteria out
%   'ExcurCriteriaIn' - Clear excursions with specific excur criteria in
%   'ExcurCriteriaRow' - Clear excursions with specific excur criteria row
% 

funcname = 'clearFBDataBase.m';
display(sprintf('Function: %s START',funcname))
fstart = now;

% Database table
DBname = '''data_products''';
DBtable = '''daily_FB_excursions''';
DBhost = '''quakedata''';

% Process Arguments
MINARGS = 0;
optargs = size(varargin,2);
stdargs = nargin - optargs;
if( stdargs < MINARGS )
    success = -1;
    display(sprintf('Not enough input arguments: min - %d used - %d',MINARGS,stdargs))
    display('USAGE')
    return
end

display(sprintf('\nINPUT ARGUMENTS:'))
startTimeSpec = false;
endTimeSpec = false;
networkSpec = false;
stationSpec = false;
bandSpec = false;
channelSpec = false;
EventTypeSpec = false;
SubEventTypeSpec = false;
LimitValueSpec = false;
ExcurOutSpec = false;
ExcurInSpec = false;
ExcurRowSpec = false;

k = 1;
while( k <= optargs )
    if( strcmpi(varargin{k}, 'startTime') )
        startTimeSpec = true;
        startTime = varargin{k+1};
        startTime = datestr(startTime,'yyyy-mm-dd HH:MM:SS');
        display(sprintf('%s option active, value: %s',varargin{k},varargin{k+1}))
        k = k + 1;
    elseif( strcmpi(varargin{k}, 'endTime') )
        endTimeSpec = true;
        endTime = varargin{k+1};
        endTime = datestr(endTime,'yyyy-mm-dd HH:MM:SS');
        display(sprintf('%s option active, value: %s',varargin{k},varargin{k+1}))
        k = k + 1;
    elseif( strcmpi(varargin{k}, 'network') )
        networkSpec = true;
        network = varargin{k+1};
        network = upper(network);
        display(sprintf('%s option active, value: %s',varargin{k},varargin{k+1}))
        k = k + 1;
    elseif( strcmpi(varargin{k}, 'station') )
        stationSpec = true;
        stations = varargin{k+1};
        stationStr = '';
        for isite = stations
            if( iscell(isite) )
                iSID = isite{:};
            else
                iSID = isite;
            end

            if( ischar(iSID) )
                stationStr = sprintf('%s%s ',stationStr,iSID);
            else
                stationStr = sprintf('%s%d ',stationStr,iSID);
            end
        end
        display(sprintf('%s option active, value: "%s"',varargin{k},stationStr))
        k = k + 1;
    elseif( strcmpi(varargin{k}, 'band') )
        bandSpec = true;
        bands = varargin{k+1};
        bandStr = '';
        for iband = bands
            bandStr = sprintf('%s%d ',bandStr,iband);
        end
        display(sprintf('%s option active, value: "%s"',varargin{k},bandStr))
        k = k + 1;
    elseif( strcmpi(varargin{k}, 'channel') )
        channelSpec = true;
        channels = varargin{k+1};
        channelStr = '';
        for ich = channels
            channelStr = sprintf('%s%d ',channelStr,ich);
        end
        display(sprintf('%s option active, value: "%s"',varargin{k},channelStr))
        k = k + 1;
    elseif( strcmpi(varargin{k}, 'EventType') )
        EventTypeSpec = true;
        EventType = varargin{k+1};
        display(sprintf('%s option active, value: %s',varargin{k},varargin{k+1}))
        k = k + 1;
    elseif( strcmpi(varargin{k}, 'SubEventType') )
        SubEventTypeSpec = true;
        SubEventType = varargin{k+1};
        display(sprintf('%s option active, value: %s',varargin{k},varargin{k+1}))
        k = k + 1;
    elseif( strcmpi(varargin{k}, 'LimitValue') )
        LimitValueSpec = true;
        LimitValue = varargin{k+1};
        display(sprintf('%s option active, value: %s',varargin{k},varargin{k+1}))
        k = k + 1;
    elseif( strcmpi(varargin{k}, 'ExcurCriteriaOut') )
        ExcurOutSpec = true;
        excurOuts = varargin{k+1};
        excurOutStr = '';
        for iex = excurOuts
            excurOutStr = sprintf('%s%d ',excurOutStr,iex);
        end
        display(sprintf('%s option active, value: "%s"',varargin{k},excurOutStr))
        k = k + 1;
    elseif( strcmpi(varargin{k}, 'ExcurCriteriaIn') )
        ExcurInSpec = true;
        excurIns = varargin{k+1};
        excurInStr = '';
        for iex = excurIns
            excurInStr = sprintf('%s%d ',excurInStr,iex);
        end
        display(sprintf('%s option active, value: "%s"',varargin{k},excurInStr))
        k = k + 1;
    elseif( strcmpi(varargin{k}, 'ExcurCriteriaRow') )
        ExcurRowSpec = true;
        excurRow = varargin{k+1};
        display(sprintf('%s option active, value: %s',varargin{k},varargin{k+1}))
        k = k + 1;
    else
        display(sprintf('Optional argument %s cannot be interpreted. Argument is ignored.', varargin{k}))
    end

    k = k + 1;
end
display(' ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get directory of perl script "clearFBEvents.plx"
[status, procDir] = system( 'echo -n $CMN_PROC_ROOT' );
if( isempty( procDir ) )
    display( 'env must contain CMN_PROC_ROOT variable' );
    display( 'found in CalMagNet/qfpaths.bash' );
    display( 'ENVIRONMENT' );
    success = status;
    return
end

% Form command statement for perl script
try
    cmd = sprintf('%s/clearFBEvents.plx %s %s %s',procDir,DBname,DBtable,DBhost);

    if( startTimeSpec )
        cmd = sprintf('%s startTime "%s"',cmd,startTime);
    end
    if( endTimeSpec )
        cmd = sprintf('%s endTime "%s"',cmd,endTime);
    end
    if( networkSpec )
        cmd = sprintf('%s network "%s"',cmd,network);
    end
    if( stationSpec )
        cmd = sprintf('%s station "%s"',cmd,stationStr);
    end
    if( bandSpec )
        cmd = sprintf('%s band "%s"',cmd,bandStr);
    end
    if( channelSpec )
        cmd = sprintf('%s channel "%s"',cmd,channelStr);
    end
    if( EventTypeSpec )
        cmd = sprintf('%s EventType "%s"',cmd,EventType);
    end
    if( SubEventTypeSpec )
        cmd = sprintf('%s SubEventType "%s"',cmd,SubEventType);
    end
    if( LimitValueSpec )
        cmd = sprintf('%s LimitValue "%s"',cmd,LimitValue);
    end
    if( ExcurOutSpec )
        cmd = sprintf('%s ExcurCriteriaOut "%s"',cmd,excurOutStr);
    end
    if( ExcurInSpec )
        cmd = sprintf('%s ExcurCriteriaIn "%s"',cmd,excurInStr);
    end
    if( ExcurRowSpec )
        cmd = sprintf('%s ExcurCriteriaRow "%s"',cmd,excurRow);
    end
catch
    display('Error forming command statement for perl script!')
    display('Check usage!!!')
    display('USAGE')
    success = -1;
    return
end

% Clear data using perl script
display(sprintf('Commmand to perl script: %s',cmd))
[status, cmdResult] = system(cmd);
if( status ~= 0 )
    success = status;
    display( ['Problem with ',procDir,'/clearFBEvents.plx'] );
    display( sprintf('Result: %s',cmdResult) );
    display( 'Problem clearing Database table "daily_FB_excursions"' );
    display( 'FAILURE' )
    return
end

success = 0;
fend = now;
delta = (fend - fstart)*86400; %#ok<NASGU>
% display(sprintf('Function: %s Start Time: %d',funcname,fstart))
% display(sprintf('Function: %s End Time: %d',funcname,fend))
% display(sprintf('Function: %s Run Time: %d',funcname,delta))
display(sprintf('Function: %s END',funcname))
display( 'SUCCESS' );
return
