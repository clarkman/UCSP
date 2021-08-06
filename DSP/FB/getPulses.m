function pulses = getPulses(varargin)
% function pulses = getPulses(varargin)
% 
% This file creates FBExculsions.mat located in fbs/excursions
% 
% The output matrix is created from the data table "pulseCounter"
% located under data_products. The matrix gives start and end times of the
% FB window for the pulse and the pulse direction.
% 
% This function can be used in several ways based on the optional
% arguments input to the function. The arguments are described below. Note
% that the optional arguments can occur in any order and are input as 
% follows: 
% 
%   getPulses('argType1',argVal1, ... ,'argTypeN',argValN)
% 
% Optional Input Arguments:
%   'startTime' - Get pulses that begin or end after startTime (UTC)
%   'endTime' - Get pulses that begin or end before endTime (UTC)
%   'network' - Get pulses on specified network
%   'station' - Get pulses for specific station ID
%   'channel' - Get pulses for specific data channel
%   'direction' - Get pulses in the specific direction
% 

funcname = 'getPulses.m';
display(sprintf('Function: %s START',funcname))
fstart = now;

NEWLINE = char(10);

pulses = [ ];

% Database table
DBname = 'data_products';
DBtable = 'pulseCounter';
DBhost = 'quakedata';
DBuser = 'matlab';

% Input Arguments
% Process Arguments
MINARGS = 0;
optargs = size(varargin,2);
stdargs = nargin - optargs;
if( stdargs < MINARGS )
    display(sprintf('Not enough input arguments: min - %d used - %d',MINARGS,stdargs))
    display('USAGE')
    return
end

display(sprintf('\nINPUT ARGUMENTS:'))
startTimeSpec = false;
endTimeSpec = false;
networkSpec = false;
stationSpec = false;
channelSpec = false;
directionSpec = false;
network = 'CMN';

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
        station = varargin{k+1};
        
        if( iscell(station) )
            iSID = station{:};
        else
            iSID = station;
        end

        if( ischar(iSID) )
            stationStr = sprintf('%s',iSID);
        else
            stationStr = sprintf('%d',iSID);
        end
        display(sprintf('%s option active, value: "%s"',varargin{k},stationStr))
        k = k + 1;
    elseif( strcmpi(varargin{k}, 'channel') )
        channelSpec = true;
        channel = varargin{k+1};
        channelStr = sprintf('%d',channel);
        display(sprintf('%s option active, value: "%s"',varargin{k},channelStr))
        k = k + 1;
    elseif( strcmpi(varargin{k}, 'SubEventType') )
        directionSpec = true;
        direction = varargin{k+1};
        direction = upper(direction);
        display(sprintf('%s option active, value: %s',varargin{k},varargin{k+1}))
        k = k + 1;
    else
        display(sprintf('Optional argument %s cannot be interpreted. Argument is ignored.', varargin{k}))
    end

    k = k + 1;
end
display(' ')

% Form query string
try
    queryString = ...
        ['use ', DBname, ';', NEWLINE, ...
         'select ', DBtable, '.SubEventType AS pulseDir,', NEWLINE, ...
         DBtable, '.DataSourceChannel AS pulseCh,', NEWLINE, ...
         'DATE_FORMAT(', DBtable, '.StartTime,"%Y/%m/%d %H:%i:%S") AS pulseStart,', NEWLINE, ...
         'DATE_FORMAT(', DBtable, '.EndTime,"%Y/%m/%d %H:%i:%S") AS pulseEnd,', NEWLINE, ...
         DBtable, '.StartTimeMS AS pStartMS,', NEWLINE, ...
         DBtable, '.EndTimeMS AS pEndMS', NEWLINE, ...
         'FROM ', DBtable, NEWLINE ];
    subQueryStart = 'WHERE';
    queryString = sprintf('%s%s %s.EventType = "TS_PULSE"%s', ...
        queryString,subQueryStart,DBtable,NEWLINE);
    subQueryStart = 'AND';
    
    if( startTimeSpec )
        queryString = sprintf('%s%s (%s.StartTime >= "%s" OR %s.EndTime >= "%s")%s', ...
            queryString,subQueryStart,DBtable,startTime,DBtable,startTime,NEWLINE);
        subQueryStart = 'AND';
    end
    if( endTimeSpec )
        queryString = sprintf('%s%s (%s.StartTime <= "%s" OR %s.EndTime <= "%s")%s', ...
            queryString,subQueryStart,DBtable,endTime,DBtable,endTime,NEWLINE);
        subQueryStart = 'AND';
    end
    if( networkSpec )
        queryString = sprintf('%s%s %s.DataSourceNetwork = "%s"%s', ...
            queryString,subQueryStart,DBtable,network,NEWLINE);
        subQueryStart = 'AND';
    end
    if( stationSpec )
        queryString = sprintf('%s%s %s.DataSourceStation = "%s"%s', ...
            queryString,subQueryStart,DBtable,stationStr,NEWLINE);
        subQueryStart = 'AND';
    end
    if( channelSpec )
        queryString = sprintf('%s%s %s.DataSourceChannel = "%s"%s', ...
            queryString,subQueryStart,DBtable,channelStr,NEWLINE);
        subQueryStart = 'AND';
    end
    if( directionSpec )
        queryString = sprintf('%s%s %s.SubEventType = "%s"%s', ...
            queryString,subQueryStart,DBtable,direction,NEWLINE);
        % subQueryStart = 'AND';
    end
catch
    display('Error forming command statement for query!')
    display('Check usage!!!')
    display('USAGE')
    return
end

% Load environment variables
[fbDir,fbStatDir,kpTxtFileName,kpMatFileName,fbExcurDir] = fbLoadExcurEnv(network);
if( strcmpi(fbDir,'ERROR') )
    display('Problem loading environment variables')
    display('ENVIRONMENT')
    return
end

% Run SQL Query to get additional earthquakes
display('Running SQL Query for Exclusions:')
display(sprintf('%sSQL Query String:%s%s',NEWLINE,NEWLINE,queryString))
try
    pulseObjects = SQLrunQuery( queryString, DBhost, DBuser );
catch
    try
        pulseObjects = SQLrunQuery( queryString, DBhost, DBuser, fbExcurDir );
    catch
        display('Error with SQLrunQuery')
        return
    end
end

% Process Exclusions
if( iscell(pulseObjects) )
    nPulses = length(pulseObjects);
    display(sprintf('%d Pulses found',nPulses))
    for ip = 1:nPulses
        currPulse = pulseObjects{ip};
        pulseST = datenum(currPulse.pulseStart) + (currPulse.pStartMS)/(86400*1000);
        pulseET = datenum(currPulse.pulseEnd) + (currPulse.pEndMS)/(86400*1000);
        % Adjust start and end time to fit with FB intervals
        stDay = floor(pulseST);    % day of start time
        etDay = floor(pulseET);    % day of end time
        stFrac = pulseST - stDay;  % fraction of day of start time
        etFrac = pulseET - etDay;  % fraction of day of end time
        stFB = 1/96 * floor( 96*stFrac ); % latest 15 min period before exclusion
        etFB = 1/96 * ceil( 96*etFrac ); % first 15 min period after exclusion
        pulseSTFB = stDay + stFB;
        pulseETFB = etDay + etFB;
        
        % Check pulse direction
        pdir = currPulse.pulseDir;
        if( strcmpi(pdir,'UP') )
            pulseDirection = 1;
        elseif( strcmpi(pdir,'DOWN') )
            pulseDirection = -1;
        else
            pulseDirection = 0;
        end
        
        pulses = [ pulses; pulseSTFB, pulseETFB, pulseDirection, currPulse.pulseCh, pulseST, pulseET ];
    end % 
    pulses = sortrows(pulses,[1,2,5,6,4,3]); %#ok<NASGU>
    
%     try
%         cmd = sprintf('save %s exclusions',fileExclusion);
%         eval(cmd)
%         display('Exclusion data updated')
%     catch
%         display('Exclusion data failed to save')
%         success = false;
%         return
%     end
else
    display('No Pulses found')
end % end: if( iscell(pulseObjects) )

try
    cmd = sprintf('delete %s/tmp/SQLResult*',fbExcurDir);
    eval(cmd)
    display('Temporary files removed')
catch
    display('Failed to remove temporary files')
end

fend = now;
delta = (fend - fstart)*86400;
display(sprintf('%s Run Time: %d',funcname,delta))
display(sprintf('Function: %s END',funcname))

return
