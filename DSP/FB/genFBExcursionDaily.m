function success = genFBExcursionDaily(startDate,endDate,network,siteIDs,bands,channels,varargin)
% function success = genFBExcursionDaily(startDate,endDate,network,siteIDs,bands,channels,varargin)
%
% This function will count the number of excursions based on input
% criteria (# in a row, seen in # of stations, etc.) for a given start date
% and end date. For each date, limits and excursions will be determined and
% saved to a .mat file.
%
% =========================================================================
% =========================================================================
% 
% Required Input Arguments:
%   Date Range: 
%       startDate - Start Date as string 'yyyy/mm/dd' in PST
%       endDate - End Date as string 'yyyy/mm/dd' in PST
%   Network: 
%       network {'CMN','BK', or 'BKQ'} - only works with 'CMN' for now
%   Stations: 
%       siteIDs - list of station IDs - num (CMN) or char (BK) format
%   Data Range:
%       bands - [1:13] - bands to look for excursions on
%       channels - [1:4] - channels to look for excursions on
%       *NOTE: Other networks may have different data ranges!!!
% 
% Optional Input Arguments:
%   Limits: separate for High and Low
%       *NOTE: The below arguments are required if excursions are not
%           turned off ('excurHiOff','excurLoOff'). The default values are
%           baseline 'median', devHi [75], devLo [25], maxDevHi [Inf],
%           maxDevLo [-Inf] if the values are not specified.
%       Baseline - 'baseHi', 'baseLo'
%           Choices: 'mean' or 'median'
%           Usage: genFBExcursionDaily(...,'baseHi','median',...)
%       Deviations - 'devLo', 'devHi'
%           Values: scalar or vector of deviations that give percentile for
%               baseline 'median' or number of standard deviations for
%               baseline 'mean'.
%           Usage: genFBExcursionDaily(...,'devLo',[0:50]',...)
%       Max Deviations - 'maxDevLo','maxDevHi'
%           Deviations outside this value do not count as out of limit!
%           Values: same as 'Deviations' above except that values of Inf
%               and -Inf for Hi and Lo are used to ignore this option.
%           Usage: genFBExcursionDaily(...,'maxDevLo',10,...)
%   Excursions: separate for High and Low
%       *NOTE: The below arguments are required if excursions are not
%           turned off ('excurHiOff','excurLoOff'). The default values are
%           outLimHi [1], outLimLo [1], inLimHi [1], inLimLo [1], and
%           inLimRow 'off' for hi and lo if the values are not specified.
%       OutLimNumbers - 'outLimHi', 'outLimLo'
%           Values: scalar or vector of numbers that determine the number
%               of points in a row that must be out of limits for an
%               excursion to occur.
%           Usage: genFBExcursionDaily(...,'outLimLo',[1:10]',...)
%       InLimNumbers - 'inLimHi', 'inLimLo'
%           Values: scalar or vector of numbers that determine the number
%               of total points that must be within limits for an
%               excursion to end.
%           Usage: genFBExcursionDaily(...,'inLimHi',[1:10]',...)
%       InLimRow - 'inLimRowHi', 'inLimRowLo'
%           Values: string that specifies that the InLimNumbers must occur
%               in a row in order to end an excursion.
%           Usage: genFBExcursionDaily(...,'inLimRowHi',...)
%   Additional Options:
%       *NOTE: All optional input arguments are input as strings and 
%       correspond to a boolean in the script below. An input argument that
%       is one of the below optional arguments will enable the description
%       associated with the argument and set the boolean to true.
% 
%       'clearDB' - clears DB log of excursions - 
%           use for remaking entire DB - USE SPARINGLY!!!
%       'clearOverlapDBOff' - do not clear excursions that overlap with 
%           input arguments
%       'debugMode' - log excursions in text file - 
%           used to compare with plots
%       'excurHiOff' - do not check for hi excursions
%       'excurLoOff' - do not check for lo excursions
%       'loadLimits' - attempt to load limits from file - 
%           regenerate if file does not exist
%       'saveLimits' - save generated limits to file - 
%           separate file for hi/lo excursions
%       'loadExcursions' - attempts to load excursions points from 
%           previous day - for excursion on day overlap
%           *DOES NOT attempt to load excursions for current day - 
%               these are recalculated!
%       'saveExcursions' - saves excursion points to .mat file - 
%           for plotting of excursions
%       'logExcurDB' - excursions will be logged to DB - for alarms
%       'logExcurMAT' - logs excursion information to .mat file - 
%           used for correlating excursions and EQs
%           used by genFBExcurEQStats.m to determine optimal values for 
%               base, dev, outLim, inLim, inLimRow
%           should this be done as daily routine?
%       'removeExclusions' - remove excursions from contamintated data
%           times in stats calculation
%       'removePulses' - smooth data around pulse times
%
% =========================================================================
% =========================================================================
% 


funcname = 'genFBExcursionDaily.m';
display(sprintf('Function: %s START',funcname))
fstart = now;

% Turn off variable not found warning
warning off MATLAB:load:variableNotFound

% =========================================================================
% =========================================================================
% Constants
NCONDLOG = 20;  % If logging to DB, make new .txt file after so many excursion condition checks
[status, procDir] = system( 'echo -n $CMN_PROC_ROOT' );
if( isempty(procDir) )
    success = status;
    display( 'env must contain CMN_PROC_ROOT variable' );
    display( 'found in CalMagNet/qfpaths.bash' );
    display( 'ENVIRONMENT' );
    return
end

% Process arguments
MINARGS = 6;
optargs = size(varargin,2);
stdargs = nargin - optargs;
if( stdargs < MINARGS )
    success = -1;
    display(sprintf('Not enough input arguments: min - %d used - %d',MINARGS,stdargs))
    display('USAGE')
    return
end
display(sprintf('\nINPUT ARGUMENTS:'))

% Start and End Date
% Convert date to a Matlab format, and to a vector for file name generation
% Note: We want sd,ed in UTC - database will store times in UTC
try
    sdPST = str2datenum( startDate );  % PST
    edPST = str2datenum( endDate );    % PST
    nd = edPST - sdPST + 1;               % Total number of days
    sdUTC = sdPST + 8/24;                 % convert from PST to UTC
    edUTC = edPST + 8/24;                 % convert from PST to UTC
    % sT = datestr(startDate,'yyyymmdd');
    % eT = datestr(endDate,'yyyymmdd');
catch
    success = -1;
    display('Cannot interpret start and end dates')
    display('USAGE')
    return
end
display(sprintf('Date Range: %s - %s',startDate,endDate))

% Network
NETWORKS = {'BK' 'BKQ' 'CMN'};
network = upper(network);
if( isempty( find( strcmpi( NETWORKS, network ),1 ) ) )
    success = -1;
    display(sprintf('Unknown network: %s', network));
    display('USAGE')
    return
end
display(sprintf('Network: %s',network))

% Sites IDs
instr = '';
for jsite = siteIDs
    if( iscell(jsite) ) 
        jSID = jsite{:};
    else
        jSID = jsite;
    end

    if( ischar(jSID) )
        instr = sprintf('%s%s ',instr,jSID);
    else
        instr = sprintf('%s%d ',instr,jSID);
    end
end
display(sprintf('Site IDs: %s',instr))
sitesStr = instr;
% nSites = size(siteIDs,2);

% Bands
instr = '';
for jband = bands
    instr = sprintf('%s%d ',instr,jband);
end
display(sprintf('Bands: %s',instr))

% Channels
instr = '';
for jch = channels
    instr = sprintf('%s%d ',instr,jch);
end
display(sprintf('Channels: %s',instr))

polCh = 4;
if( ~(channels == polCh) )
    checkCh = channels;
else
    checkCh = 1:3;
end


% Optional Arguments
display(sprintf('\nOPTIONAL ARGUMENTS:'))
% NDAYSLOG = 10;
excurHiOff = false;
excurLoOff = false;
baseHi = 'median';
baseLo = 'median';
devHis = 75;
devLos = 25;
maxDevHi = Inf;
maxDevLo = -Inf;
outLimHis = 1;
outLimLos = 1;
inLimHis = 1;
inLimLos = 1;
inLimRowHi = false;
inLimRowLo = false;
clearDB = false;
clearOverlapDBOff = false;
debugMode = false;
loadLimits = false;
saveLimits = false;
loadExcursions = false;
saveExcursions = false;
logExcurDB = false;
logExcurMAT = false;
removeExclusions = false;
removePulses = false;

k = 1;
while( k <= optargs )
    if( strcmpi(varargin{k}, 'excurHiOff') )
        excurHiOff = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'excurLoOff') )
        excurLoOff = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'baseHi') )
        if( ischar( varargin{k+1} ) )
            switch lower( varargin{k+1} )
                case { 'median','mean' }
                    baseHi = lower( varargin{k+1} );
                    display(sprintf('%s option set to %s',varargin{k},varargin{k+1}))
                    k = k + 1;
                otherwise
                    display(sprintf('Invalid value for %s, setting to default',varargin{k}))
            end
        end
    elseif( strcmpi(varargin{k}, 'baseLo') )
        if( ischar( varargin{k+1} ) )
            switch lower( varargin{k+1} )
                case { 'median','mean' }
                    baseLo = lower( varargin{k+1} );
                    display(sprintf('%s option set to %s',varargin{k},varargin{k+1}))
                    k = k + 1;
                otherwise
                    display(sprintf('Invalid value for %s, setting to default',varargin{k}))
            end
        end
    elseif( strcmpi(varargin{k}, 'devHi') )
        if( isnumeric( varargin{k+1} ) )
            devHis = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'devLo') )
        if( isnumeric( varargin{k+1} ) )
            devLos = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'maxDevHi') )
        if( isnumeric( varargin{k+1} ) )
            maxDevHi = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'maxDevLo') )
        if( isnumeric( varargin{k+1} ) )
            maxDevLo = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'outLimHi') )
        if( isnumeric( varargin{k+1} ) )
            outLimHis = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'outLimLo') )
        if( isnumeric( varargin{k+1} ) )
            outLimLos = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'inLimHi') )
        if( isnumeric( varargin{k+1} ) )
            inLimHis = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'inLimLo') )
        if( isnumeric( varargin{k+1} ) )
            inLimLos = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'inLimRowHi') )
        inLimRowHi = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'inLimRowLo') )
        inLimRowLo = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'clearDB') )
        clearDB = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'clearOverlapDBOff') )
        clearOverlapDBOff = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'debugMode') )
        debugMode = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'loadLimits') )
        loadLimits = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'saveLimits') )
        saveLimits = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'loadExcursions') )
        loadExcursions = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'saveExcursions') )
        saveExcursions = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'logExcurDB') )
        logExcurDB = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'logExcurMAT') )
        logExcurMAT = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'removeExclusions') )
        removeExclusions = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'removePulses') )
        removePulses = true;
        display(sprintf('%s option active',varargin{k}))
    else
        display(sprintf('Optional argument %s cannot be interpreted. Argument is ignored.', varargin{k}))
    end
    
    k = k + 1;
end
display(' ')

% High Limits and Excursions
if( ~excurHiOff )
    display('High Excursions Calculation On')
    % Baseline
    display(sprintf('High Limit Baseline: %s',baseHi))
    % Deviations
    instr = '';
    for jDev = devHis
        instr = sprintf('%s%d ',instr,jDev);
    end
    display(sprintf('High Limit Deviations: %s',instr))
    % Max Deviation
    if( ~isfinite(maxDevHi) )
    elseif( (size(maxDevHi,2) ~= 1) || (size(maxDevHi,2) ~= size(devHis,2)) )
        maxDevHi = Inf; %#ok<NASGU>
    else
        instr = '';
        for jDev = maxDevHi
            instr = sprintf('%s%d ',instr,jDev);
        end
        display(sprintf('Max High Limit Deviations: %s',instr))
    end
    % Out Lim Numbers
    instr = '';
    for jo = outLimHis
        instr = sprintf('%s%d ',instr,jo);
    end
    display(sprintf('High Out of Limit Numbers: %s',instr))
    % In Lim Numbers
    instr = '';
    for ji = inLimHis
        instr = sprintf('%s%d ',instr,ji);
    end
    display(sprintf('High In Limit Numbers: %s',instr))
    % In Lim In A Row
    display(sprintf('High In Limit In A Row: %d',inLimRowHi))
end

% Low Limits and Excursions
if( ~excurLoOff )
    display('Low Excursions Calculation On')
    % Baseline
    display(sprintf('Low Limit Baseline: %s',baseLo))
    % Deviations
    instr = '';
    for jDev = devLos
        instr = sprintf('%s%d ',instr,jDev);
    end
    display(sprintf('Low Limit Deviations: %s',instr))
    % Max Deviation
    if( ~isfinite(maxDevLo) )
    elseif( (size(maxDevLo,2) ~= 1) || (size(maxDevLo,2) ~= size(devLos,2)) )
        maxDevLo = -Inf; %#ok<NASGU>
    else
        instr = '';
        for jDev = maxDevLo
            instr = sprintf('%s%d ',instr,jDev);
        end
        display(sprintf('Max Low Limit Deviations: %s',instr))
    end
    % Out Lim Numbers
    instr = '';
    for jo = outLimLos
        instr = sprintf('%s%d ',instr,jo);
    end
    display(sprintf('Low Out of Limit Numbers: %s',instr))
    % In Lim Numbers
    instr = '';
    for ji = inLimLos
        instr = sprintf('%s%d ',instr,ji);
    end
    display(sprintf('Low In Limit Numbers: %s',instr))
    % In Lim In A Row
    display(sprintf('Low In Limit In A Row: %d',inLimRowLo))
end

% Clear Input Argument display variables
clear instr* j*

% =========================================================================
% =========================================================================
display(' ')
display('FUNCTION BODY:')

% Success Check Variable
allExcurLogged = true;

% Load environment variables
[fbDir,fbStatDir,kpTxtFileName,kpMatFileName,fbExcurDir,fbExcurPointsDir,fbExcurPlotDir,fbExcurLogDir,fbLimitDir,fbSmoothDir] = fbLoadExcurEnv(network);
if( strcmpi(fbDir,'ERROR') )
    display('Problem loading environment variables')
    display('ENVIRONMENT')
    success = -1;
    return
end
if( removePulses )
    rootDir = fbSmoothDir;
else
    rootDir = fbDir;
end

% Exclusions
if( removeExclusions )
    try
        success = getFBExclusions(network);
        if( success )
            fileExclusion = sprintf('%s/FBExclusions.mat',fbExcurDir);
            cmd = sprintf('load %s exclusions',fileExclusion);
            eval(cmd)
            display('Exclusions loaded from file')
            % convert exclusion times to PST
            exclusions(:,[1,2,5,6]) = exclusions(:,[1,2,5,6]) - 8/24; %#ok<NODEF>
        else
            display('Error getting exclusion times. Exclusions will not be removed.')
            exclusions = [ ];
            removeExclusions = false;
        end
    catch
        display('Error getting exclusion times. Exclusions will not be removed.')
        exclusions = [ ];
        removeExclusions = false;
    end
end

% Clear overlapping entries
if( ~clearOverlapDBOff )
    display( 'Clearing Overlapping Entries from DB table "daily_FB_excursions"' )
    % Work in limit values!!!
    if( ~excurHiOff )
        SubEventType = 'ABOVE';
        if( strcmpi( baseHi, 'median' ) ) % make sure percentiles are integer values in range 0-100, devLo < devHi
            EventType = 'FB_MEDIAN';
            LimValStart = 'PERCENTILE';
        elseif( strcmpi( baseHi, 'mean' ) )
            EventType = 'FB_MEAN';
            LimValStart = 'SIGMA';
        else
            success = -1;
            display(sprintf('Invalid High baseline input argument: %s',baseHi))
            display('USAGE')
            return
        end
        
        for iDev = 1:size(devHis,1)
            devHi = devHis(iDev);
            if( strcmpi( baseHi, 'median' ) ) % make sure percentiles are integer values in range 0-100, devLo < devHi
                devHi = ceil(devHi);

                if( devHi < 0 )
                    display('WARNING: Percentile given for higher limit is less than 0. Setting to 0.')
                    devHi = 0;
                end

                if( devHi > 100 )
                    display('WARNING: Percentile given for higher limit is greater than 100. Setting to 100.')
                    devHi = 100;
                end
            end
            LimitValue = sprintf('%s_%d',LimValStart,devHi);
            
            success = clearFBDataBase('startTime',sdUTC,'endTime',edUTC,'network',network,'station',siteIDs, ...
                'band',bands,'channel',channels,'EventType',EventType,'SubEventType',SubEventType,'LimitValue',LimitValue);
            if( success ~= 0 )
                display( 'Unable to clear overlapping entries from database.')
                display( 'FAILURE' )
                return
            end
        end
    end
    
    if( ~excurLoOff )
        SubEventType = 'BELOW';
        if( strcmpi( baseLo, 'median' ) ) % make sure percentiles are integer values in range 0-100, devLo < devHi
            EventType = 'FB_MEDIAN';
            LimValStart = 'PERCENTILE';
        elseif( strcmpi( baseLo, 'mean' ) )
            EventType = 'FB_MEAN';
            LimValStart = 'SIGMA';
        else
            success = -1;
            display(sprintf('Invalid Low baseline input argument: %s',baseLo))
            display('USAGE')
            return
        end
        
        for iDev = 1:size(devLos,1)
            devLo = devLos(iDev);
            if( strcmpi( baseLo, 'median' ) ) % make sure percentiles are integer values in range 0-100, devLo < devHi
                devLo = floor(devLo);

                if( devLo < 0 )
                    display('WARNING: Percentile given for lower limit is less than 0. Setting to 0.')
                    devLo = 0;
                end

                if( devLo > 100 )
                    display('WARNING: Percentile given for lower limit is greater than 100. Setting to 100.')
                    devLo = 100;
                end
            end
            LimitValue = sprintf('%s_%d',LimValStart,devLo);
            
            success = clearFBDataBase('startTime',sdUTC,'endTime',edUTC,'network',network,'station',siteIDs, ...
                'band',bands,'channel',channels,'EventType',EventType,'SubEventType',SubEventType,'LimitValue',LimitValue);
            if( success ~= 0 )
                display( 'Unable to clear overlapping entries from database.')
                display( 'FAILURE' )
                return
            end
        end
    end
end % if( ~clearOverlapDBOff )

% Clear DB?
if( clearDB )
    display( 'Clearing DB table "daily_FB_excursions"' )
    success = clearFBDataBase();
    if( success ~= 0 )
        display( 'Problem with clearFBDataBase.m' )
        display( 'FAILURE' )
        return
    end
end

% Log Excursions to .mat file?
if( logExcurMAT )
    fbExcurMatLogDir = [fbExcurDir '/excursionLogs'];
    success = verifyEnvironment(fbExcurMatLogDir);
    dirExcurMatLogHi = [fbExcurMatLogDir sprintf('/%s',baseHi)];
    dirExcurMatLogLo = [fbExcurMatLogDir sprintf('/%s',baseLo)];
    success = success && verifyEnvironment(dirExcurMatLogHi) && verifyEnvironment(dirExcurMatLogLo);
    dirExcurMatLogHi = [dirExcurMatLogHi '/Hi'];
    dirExcurMatLogLo = [dirExcurMatLogLo '/Lo'];
    success = success && verifyEnvironment(dirExcurMatLogHi) && verifyEnvironment(dirExcurMatLogLo);
    if( ~success )
        display('Error creating Excursion .mat log directories');
        display('ENVIRONMENT');
        success = -1;
        return
    end
end

% Log Excursions to DB? Create temporary .txt file for transfer
if( logExcurDB )
    % Number of Conditions
    % nCond = nSites * nd;
    
    % Initialize dates and site string for log file
    sdr = sdPST;
    edr = edPST;
    sitestr = strrep(sitesStr, ' ', '');
    % if( nCond < NCONDLOG )
    %     edr = edPST;
    %     sitestr = strrep(sitesStr, ' ', '');
    % else
    %     edr = sdr + NDAYSLOG - 1;
    % end
    sdrStr = datestr(sdr,'yyyymmdd');
    edrStr = datestr(edr,'yyyymmdd');
    
    if( debugMode )
        % Will this file work with process queue? Is there problem with sharing
        % files among machines?
        outFile = [fbExcurLogDir '/' sitestr sprintf('.%s-%s.txt',sdrStr,edrStr)];
    else
        % Will this file work with process queue? Is there problem with sharing
        % files among machines?
        fbExcurTmpDir = [fbExcurLogDir '/tmp'];
        success = verifyEnvironment(fbExcurTmpDir);
        if( ~success )
            display(['Error creating Temporary directory: ' fbExcurTmpDir]);
            display('ENVIRONMENT');
            success = -1;
            return
        end
        outFile = [fbExcurTmpDir '/' sitestr sprintf('.%s-%s.txt',sdrStr,edrStr)];
    end

    % Create Log File
    display(['Excursion DB Log File: ' outFile])
    success = createFBExcurOutFile(outFile,sdrStr,edrStr,network,siteIDs,channels,bands,[outLimHis,0,outLimLos],[inLimHis,0,inLimLos],(inLimRowHi&&inLimRowLo));
    if( success ~= 0 )
        display('ERROR: Unable to create Excursion Log File')
        display('BAD_WRITE')
        return
    end
    display('Excursion Log File successfully created')
end
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% % Load Kp file
% try
%     startKp = now;
%     kp = [ ];
%     kpdtnum = [ ];
%     cmd = sprintf('load %s kp kpdtnum;', kpMatFileName );
%     eval( cmd );
%     kpdtnum = kpdtnum - 8/24; % adjust for 8 hr time difference in our analysis, PST
%     endKp = now;
%     deltaKp = (endKp - startKp)*86400;
%     display(sprintf('Time to Load Kp Values: %d', deltaKp));
% catch
%     display('ERROR: Unable to load Kp values')
%     display('BAD_LOAD')
%     success = -1;
%     return
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iS = 0;
for iSID = siteIDs
    iS = iS + 1;
    
    if( iscell(iSID) ) 
        isite = iSID{:};
    else
        isite = iSID;
    end
    
    if( ischar(isite) )
        isiteStr = isite;
    else
        isiteStr = sprintf('%d',isite);
    end
    
    % Get Station Name
    % Old method - new function called getStationInfo in streams/CalMagNet!
    %isiteCell = getStationInfoSLP({network},1,1,'SID',isite,'NAME');
    %isiteName = isiteCell{1};
    
    % New method - only works for CMN network!
    % Returns structure with:
    % sid, file_name, status, first_data_start, recent_data, latitude, longitude
    % Use getStationName.m to get siteName
    isiteInfo = getStationInfo(isiteStr);
    isiteFN = isiteInfo.file_name;
    isiteName = getStationName(isiteFN);
    
    disp(sprintf('Site: %s - %s',isiteName,isiteStr))
        
    % Create Excursion .mat log file station directory
    % Make sure it works with BK network!!!
    if( logExcurMAT )
        tmpExcurMatLogHi = sprintf( '%s/%s', ...
            dirExcurMatLogHi,isiteFN );
        tmpExcurMatLogLo = sprintf( '%s/%s', ...
            dirExcurMatLogLo,isiteFN );
        success = verifyEnvironment(tmpExcurMatLogHi) && verifyEnvironment(tmpExcurMatLogLo);
        if( ~success )
            display('Error creating Excursion .mat log directories');
            display('ENVIRONMENT');
            success = -1;
            return
        end
    end
    
    % Load stats here if we need to!
    
    % Check if data exists for day before start day - loop over channels!
    % Determine file name for day before start day's data
    dataPastExist = false;
    for ichannel = checkCh
        fbDataPast = sprintf( '%s/%s/CHANNEL%d/%s.%s.%s.%02d.fb',...
            rootDir,isiteFN,ichannel,datestr(sdPST-1,'yyyymmdd'),network,isiteStr,ichannel);
        
        if( exist(fbDataPast,'file') )
            dataPastExist = true;
        end
    end % for ichannel = checkCh
    
    % Is there data from the day before start day?
    display(sprintf('Day Number %d of %d, Date: %s',0,nd,datestr(sdPST-1,'yyyy/mm/dd')))
    if( dataPastExist )
        display(sprintf('Data exists for date: %s',datestr(sdPST-1,'yyyy/mm/dd')))
        
        % Get data from day before start day
        dataPast = loadFBDataMB( sdPST-1, sdPST-1, network, isite, channels, bands, false, removePulses);
        % Loop through time of day
        for it=1:96
            % Iterate over all desired bands
            for iband = bands
                % Get frequency range for band
                % Used to convert units to pT
                if( strcmpi( network, 'CMN' ) || strcmpi( network, 'BK' ) )
                    [freq1 freq2] = getUCBMAFreqs(iband);
                elseif( strcmp( network, 'BKQ' ) ),
                    [freq1 freq2] = getFBUpperFreqs(iband);
                end % if
                bw = freq2 - freq1;

                for ichannel = channels
                    % Convert units to pT
                    if( ichannel ~= polCh )
                        dataPast(it,iband+1,ichannel) = real(sqrt(dataPast(it,iband+1,ichannel))) * bw;
                    end
                end
            end
        end
    else
        dataPast = NaN(96,14,4);
        display(sprintf('Data not found for date: %s',datestr(sdPST-1,'yyyy/mm/dd')))
        display('Skipping day')
    end % if( exist(fbDataPast,'file') )
    
    % Iterate over each day
    for ind=1:nd
        % Figure out current day
        id = sdPST + ind - 1;
        % idStr = datestr(id,'yyyymmdd');
        % [y,m] = datevec(id);       % - Get date vector (month, day, etc)
        % season = ceil((mod(m+6,12)+1)/3);   % - Calculate season param
        
        % Display current day
        display(sprintf('Day Number %d of %d, Date: %s',ind,nd,datestr(id,'yyyy/mm/dd')))
        
        % Recreate Log File every NCONDLOG days so it is not too big
        if( logExcurDB )
            iCond = (iS - 1) * nd + ind;
            if( mod(iCond,NCONDLOG) == 0 )
                % First add entries to DB
                startDBTime = now;
                [status, cmdResult] = system( [procDir,'/addFBEvents.plx ',outFile] );
                endDBTime = now;
                deltaDB = (endDBTime - startDBTime)*86400;
                if( cmdResult ~= 0 )
                    allExcurLogged = false;
                    display( ['Problem with ',procDir,'/addFBEvents.plx ',outFile] )
                    display( sprintf('Site: %s_%s, Last Date: %s',isiteName,isiteStr,datestr(id-1,'yyyymmdd')) )
                    display( 'Failed to enter excursion into database table "daily_FB_excursions"' )
                else
                    display('Excursions entered into database table "daily_FB_excursions"')
                    display(sprintf('DB Entry Time: %d',deltaDB))
                end

                % Remove Temporary Excursion Log File
                if( ~debugMode )
                    [status, cmdResult] = system( ['rm ' outFile] );
                    if( status ~= 0 )
                        display(['Error Removing File: ' outFile] );
                        display(cmdResult);
                        display('Remove manually')
                    else
                        display('Temporary Excursion Log File deleted')
                    end
                end
                
                % Create Log File
                display(['Excursion DB Log File: ' outFile])
                success = createFBExcurOutFile(outFile,sdrStr,edrStr,network,siteIDs,channels,bands,[outLimHis,0,outLimLos],[inLimHis,0,inLimLos],(inLimRowHi&&inLimRowLo));
                if( success ~= 0 )
                    display('ERROR: Unable to create Excursion Log File')
                    display('BAD_WRITE')
                    return
                end
                display('Excursion Log File successfully created')
            end % if( mod(iCond,NCONDLOG) == 0 )
        end % if( logExcurDB )

        % Check if data exists for current day - loop over channels
        % Determine file name for current and previous day's data
        dataCurrExist = false;
        for ichannel = checkCh
            fbDataCurr = sprintf( '%s/%s/CHANNEL%d/%s.%s.%s.%02d.fb',...
                rootDir,isiteFN,ichannel,datestr(id,'yyyymmdd'),network,isiteStr,ichannel);
            
            if( exist(fbDataCurr,'file') )
                dataCurrExist = true;
            end
        end % for ichannel = checkCh
        
        % Is there data for current day?
        if( dataCurrExist )
            display(sprintf('Data exists for date: %s',datestr(id,'yyyy/mm/dd')))

            % Load data for current day
            dataCurr = loadFBDataMB( id, id, network, isite, channels, bands, false, removePulses);
            % Loop through time of day
            for it=1:96
                % Iterate over all desired bands
                for iband = bands
                    % Get frequency range for band
                    % Used to convert units to pT
                    if( strcmpi( network, 'CMN' ) || strcmpi( network, 'BK' ) )
                        [freq1 freq2] = getUCBMAFreqs(iband);
                    elseif( strcmp( network, 'BKQ' ) ),
                        [freq1 freq2] = getFBUpperFreqs(iband);
                    end % if
                    bw = freq2 - freq1;

                    for ichannel = channels
                        % Convert units to pT
                        if( ichannel ~= polCh )
                            dataCurr(it,iband+1,ichannel) = real(sqrt(dataCurr(it,iband+1,ichannel))) * bw;
                        end
                    end
                end
            end
            
            % High Limits and Excursions
            if( ~excurHiOff )
                allExcurSaved = true;
                for iDev = 1:size(devHis,1)
                    devHi = devHis(iDev);
                    if( strcmpi( baseHi, 'median' ) ) % make sure percentiles are integer values in range 0-100, devLo < devHi
                        devHi = ceil(devHi);

                        if( devHi < 0 )
                            display('WARNING: Percentile given for higher limit is less than 0. Setting to 0.')
                            devHi = 0;
                        end
                        
                        if( devHi > 100 )
                            display('WARNING: Percentile given for higher limit is greater than 100. Setting to 100.')
                            devHi = 100;
                        end
                    elseif( strcmpi( baseHi, 'mean' ) )
                    else
                        success = -1;
                        display(sprintf('Invalid High baseline input argument: %s',baseHi))
                        display('USAGE')
                        return
                    end
                    display(sprintf('High Limit Definition: Baseline - %s, Deviation - %d',baseHi,devHi))
                    
                    % Generate Limits
                    optLimArgs = '''pT''';
                    if( loadLimits ), optLimArgs = sprintf('''loadLimits'',%s',optLimArgs); end
                    if( saveLimits ), optLimArgs = sprintf('''saveLimits'',%s',optLimArgs); end
                    optLimArgs = sprintf('''baseHi'',baseHi,''devHi'',devHi,%s',optLimArgs);
                    try
                        limitCmd = sprintf('[limitPast,trash] = genFBLimits(''%s'',network,isite,bands,channels,%s);',datestr(id-1,'yyyy/mm/dd'),optLimArgs);
                        eval(limitCmd)
                        limitCmd = sprintf('[limitCurr,trash] = genFBLimits(''%s'',network,isite,bands,channels,%s);',datestr(id,'yyyy/mm/dd'),optLimArgs);
                        eval(limitCmd)
                        clear trash
                        display('High Limits Generated')
                    catch
                        display('Error Generating High Limits')
                        success = -1;
                        display('FAILURE')
                        return
                    end
                    
                    % Calculate Out Of Limits
                    outOfLimCurr = zeros(96,14,4);
                    outOfLimCurr(:,1,:) = dataCurr(:,1,:);
                    outOfLimPast = zeros(96,14,4);
                    outOfLimPast(:,1,:) = dataPast(:,1,:);
                    
                    % Loop through time of day
                    for it=1:96
                        % Calculate time stamp
                        % t = dataCurr(it,1,1);

%                         % Look up kp
%                         % For the current time, get the closest time with a known kp
%                         % For that time, get the kp value
%                         thisKp = kp( closest( kpdtnum,t ) );
%                         if ~isempty(thisKp)
%                             switch floor(thisKp),
%                                 case {0,1}
%                                     kp_tmp = 1;
%                                 case {2,3}
%                                     kp_tmp = 2;
%                                 case {4,5}
%                                     kp_tmp = 3;
%                                 case {6,7,8,9}
%                                     kp_tmp = 4;
%                             end % switch
%                         else
%                             kp_tmp = 1;
%                         end

                        % Iterate over all desired bands
                        for iband = bands
                            for ichannel = channels
                                % Exclusion Time?
                                cExcl = false;
                                pExcl = false;
                                if( removeExclusions )
                                    currTime = dataCurr(it,1,ichannel);
                                    pastTime = dataPast(it,1,ichannel);
                                    ctimeExcl = (exclusions(:,1) <= currTime) & (exclusions(:,2) >= currTime);
                                    ptimeExcl = (exclusions(:,1) <= pastTime) & (exclusions(:,2) >= pastTime);
                                    siteExcl = (exclusions(:,3) == isite);
                                    chExcl = (exclusions(:,4) == ichannel);
                                    
                                    crelExcl = exclusions( ctimeExcl & siteExcl & chExcl, : );
                                    prelExcl = exclusions( ptimeExcl & siteExcl & chExcl, : );
                                    if( ~isempty(crelExcl) ), cExcl = true; end
                                    if( ~isempty(prelExcl) ), pExcl = true; end
                                end % if( removeExclusions )
                                
                                % Mark Out-of-Limit
                                % Current Data
                                if( dataCurr(it,iband+1,ichannel) <= 0 )                    % Data is not available
                                    outOfLimCurr(it,iband+1,ichannel) = -1;
                                elseif( isnan(dataCurr(it,iband+1,ichannel)) )              % Data is NaN
                                    outOfLimCurr(it,iband+1,ichannel) = -2;
                                elseif( limitCurr(it,iband+1,ichannel) <= 0 )
                                    outOfLimCurr(it,iband+1,ichannel) = -3;
                                elseif( isnan(limitCurr(it,iband+1,ichannel)) )
                                    outOfLimCurr(it,iband+1,ichannel) = -4;
                                elseif( cExcl )
                                    outOfLimCurr(it,iband+1,ichannel) = -5;                 % Exclusion time
                                % Is the data out of limit?
                                elseif( (dataCurr(it,iband+1,ichannel) > limitCurr(it,iband+1,ichannel)) )      % Data is greater than Hi limit
                                    outOfLimCurr(it,iband+1,ichannel) = 1;
                                end

                                % Past Data
                                if( dataPast(it,iband+1,ichannel) <= 0 )                    % Data is not available
                                    outOfLimPast(it,iband+1,ichannel) = -1;
                                elseif( isnan(dataPast(it,iband+1,ichannel)) )              % Data is NaN
                                    outOfLimPast(it,iband+1,ichannel) = -2;
                                elseif( limitPast(it,iband+1,ichannel) <= 0 )
                                    outOfLimPast(it,iband+1,ichannel) = -3;
                                elseif( isnan(limitPast(it,iband+1,ichannel)) )
                                    outOfLimPast(it,iband+1,ichannel) = -4;
                                elseif( pExcl )
                                    outOfLimPast(it,iband+1,ichannel) = -5;                 % Exclusion time
                                % Is the data out of limit?
                                elseif( (dataPast(it,iband+1,ichannel) > limitPast(it,iband+1,ichannel)) )      % Data is greater than Hi limit
                                    outOfLimPast(it,iband+1,ichannel) = 1;
                                end
                            end % for ichannel = channels
                        end % for iband = bands
                    end % for it=1:96
                    
                    % Iterate over all outLimNumbers
                    inLimInARow = inLimRowHi;
                    for iOutLim = outLimHis
                        outLimNumber = iOutLim;
                        
                        % Iterate over all inLimNumbers
                        for iInLim = inLimHis
                            inLimNumber = iInLim;
                            display(sprintf('Out Lim Number: %d, In Lim Number: %d, In Lim In A Row: %d',outLimNumber,inLimNumber,inLimInARow))
                            
                            % Create Excursion .mat log files
                            % Make sure it works with BK network!!!
                            if( logExcurMAT )
                                excurLog = [ ];
                                
                                if( strcmpi( baseHi, 'mean' ) )
                                    if( devHi < 0 )
                                        fileExcurMatLog = sprintf( '%s/%s.%s.%s.fblog.n%02d.hi.%02d%02d%d.mat', ...
                                            tmpExcurMatLogHi,datestr(id,'yyyymmdd'),network,isiteStr,-devHi,outLimNumber,inLimNumber,inLimInARow );
                                    else
                                        fileExcurMatLog = sprintf( '%s/%s.%s.%s.fblog.p%02d.hi.%02d%02d%d.mat', ...
                                            tmpExcurMatLogHi,datestr(id,'yyyymmdd'),network,isiteStr,devHi,outLimNumber,inLimNumber,inLimInARow );
                                    end
                                else
                                    fileExcurMatLog = sprintf( '%s/%s.%s.%s.fblog.%03d.hi.%02d%02d%d.mat', ...
                                        tmpExcurMatLogHi,datestr(id,'yyyymmdd'),network,isiteStr,devHi,outLimNumber,inLimNumber,inLimInARow );
                                end
                            end % if( logExcurMAT )
                            
                            % Excursions count
                            for iband = bands
                                for ichannel = channels
                                    % Excursion Points
                                    % Generate File Names for excursion points
                                    if( loadExcursions || saveExcursions )
                                        if( strcmpi(network,'CMN') )
                                            currDir = fbExcurPointsDir;
                                            success = verifyEnvironment(currDir);
                                            currDir = [currDir sprintf('/%s',isiteFN)];
                                            success = success && verifyEnvironment(currDir);
                                            currDir = [currDir sprintf('/FB%02d',iband)];
                                            success = success && verifyEnvironment(currDir);
                                            currDir = [currDir sprintf('/CHANNEL%d',ichannel)];
                                            success = success && verifyEnvironment(currDir);
                                            if( ~success )
                                                display('Unable to create Excursion Directory')
                                                display('ENVIRONMENT')
                                                success = -1;
                                                return
                                            end

                                            % Different File Names for Hi & Lo
                                            if( strcmpi( baseHi, 'mean' ) )
                                                if( devHi < 0 )
                                                    excurFileCurr = [currDir ...
                                                        sprintf('/%s.%s.%s.%02d.%d.fbe.hi.n%02d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,-devHi)];
                                                    excurFilePast = [currDir ...
                                                        sprintf('/%s.%s.%s.%02d.%d.fbe.hi.n%02d.mat',datestr(id-1,'yyyymmdd'),network,isiteStr,iband,ichannel,-devHi)];
                                                else
                                                    excurFileCurr = [currDir ...
                                                        sprintf('/%s.%s.%s.%02d.%d.fbe.hi.p%02d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,devHi)];
                                                    excurFilePast = [currDir ...
                                                        sprintf('/%s.%s.%s.%02d.%d.fbe.hi.p%02d.mat',datestr(id-1,'yyyymmdd'),network,isiteStr,iband,ichannel,devHi)];
                                                end
                                            elseif( strcmpi( baseHi, 'median' ) )
                                                excurFileCurr = [currDir ...
                                                    sprintf('/%s.%s.%s.%02d.%d.fbe.hi.%03d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,devHi)];
                                                excurFilePast = [currDir ...
                                                    sprintf('/%s.%s.%s.%02d.%d.fbe.hi.%03d.mat',datestr(id-1,'yyyymmdd'),network,isiteStr,iband,ichannel,devHi)];
                                            end
                                        else
                                            % MODIFY TO WORK WITH OTHER NETWORKS!!!
                                        end % if( strcmpi(network,'CMN') )
                                    end % if( loadExcursions || saveExcursions )

                                    % Load .mat file for previous day excursion points
                                    try
                                        if( dataPastExist && loadExcursions )
                                            cmd = sprintf('load %s excurPoints%02d%02d%02d allExcurs%02d%02d%02d', ...
                                                excurFilePast, outLimNumber, inLimNumber, inLimInARow, outLimNumber, inLimNumber, inLimInARow );
                                            eval( cmd );
                                            cmd = sprintf('excurPtsPast = excurPoints%02d%02d%02d; allExcursPast = allExcurs%02d%02d%02d;', ...
                                                outLimNumber, inLimNumber, inLimInARow, outLimNumber, inLimNumber, inLimInARow );
                                            eval( cmd );
                                            % excurPtsPast = excurPoints;
                                            % allExcursPast = allExcurs;
                                        else
                                            excurPtsPast = [ ];
                                            allExcursPast = NaN;
                                        end
                                    catch
                                        excurPtsPast = [ ];   % Vector containing the timestamp and data value for all points in an excursion during the previous day
                                        allExcursPast = NaN;
                                    end
                                    excurPtsCurr = [ ];   % Vector containing the timestamp and data value for all points in an excursion during the current day
                                    allExcursCurr = false; %#ok<NASGU>

                                    % Excursion variables - reset every loop
                                    % Booleans
                                    pastExcur = false;          % Previous day ended with an excursion
                                    includePoints = false;      % Excursion is occurring - include points
                                    addEndCountOut = true;     % End of the previous day - count points out-of-limit that end the day
                                    addEndCountIn = true;      % End of the previous day - count points in-limit that end the day
                                    % Out-Of-Limits
                                    numPointsOut = 0;       % Number of points that are out-of-limit that are part of an excursion
                                    numPointsOutTemp = 0;   % The points are out-of-limit but not yet part of an excursion
                                    numPointsOutRow = 0;    % Number of points in the current stretch of out-of-limit - used to determine if an excursion occurred
                                    energyOut = 0;          % Sum of the "energy" for out-of-limit points that are part of an excursion
                                    energyOutTemp = 0;      % "Energy" for points that are out-of-limit but not yet part of an excursion
                                    % In-Limit
                                    numPointsIn = 0;        % Number of points that are in-limit that are part of an excursion
                                    numPointsInTemp = 0;    % Points are in-limit but not yet part of an excursion
                                    numEndPointsIn = 0;     % Number of points in-limit that ended the previous day - only necessary if there's an excursion overlap over two days
                                    energyIn = 0;           % Sum of the "energy" for in-limit points that are part of an excursion
                                    energyInTemp = 0;       % "Energy" for points that are in-limit but not yet part of an excursion
                                    countIn = inLimNumber;  % Count of the number of points that need to be in-limit to stop the current excursion
                                    % Data Integrity
                                    % excurAmbigStart = 0;    % At the start of an excursion, was there unusable data or limits? (Can't tell when the excursion started)
                                    excurAmbigEnd = 0;      % At the end of an excursion, was there unusable data or limits? (Can't tell when the excursion ended)

                                    % HIGH EXCURSIONS
                                    itPast = 96;
                                    while( dataPastExist && (itPast > 0) && (countIn > 0) && (outOfLimPast(itPast,iband+1,ichannel) >= 0) )
                                        if( outOfLimPast(itPast,iband+1,ichannel) == 1 )  % Is the point out-of-limits?
                                            numPointsOutRow = numPointsOutRow + 1;
                                            energyOutTemp = energyOutTemp + dataPast(itPast,iband+1,ichannel) - limitPast(itPast,iband+1,ichannel);
                                            if( addEndCountIn )
                                                numEndPointsIn = numPointsInTemp;
                                                numPointsIn = numPointsIn + numEndPointsIn;
                                                numPointsInTemp = 0;
                                                energyIn = energyIn + energyInTemp;
                                                energyInTemp = 0;
                                            end
                                            addEndCountIn = false;
                                            if( inLimInARow )
                                                countIn = inLimNumber;
                                            end % if
                                        else
                                            if( numPointsOutRow >= outLimNumber )
                                                includePoints = true;
                                                pastExcur = true;
                                            end
                                            numPointsOutTemp = numPointsOutTemp + numPointsOutRow;
                                            numPointsOutRow = 0;
                                            if( includePoints || addEndCountOut )
                                                numPointsOut = numPointsOut + numPointsOutTemp;
                                                numPointsOutTemp = 0;
                                                energyOut = energyOut + energyOutTemp;
                                                energyOutTemp = 0;
                                                numPointsIn = numPointsIn + numPointsInTemp;
                                                numPointsInTemp = 0;
                                                energyIn = energyIn + energyInTemp;
                                                energyInTemp = 0;
                                                includePoints = false;
                                            end
                                            addEndCountOut = false;
                                            numPointsInTemp = numPointsInTemp + 1;
                                            energyInTemp = energyInTemp - dataPast(itPast,iband+1,ichannel) + limitPast(itPast,iband+1,ichannel);
                                            countIn = countIn - 1;
                                        end % if
                                        itPast = itPast - 1;
                                    end % while

                                    if( ~dataPastExist )
                                        countIn = 0;
                                        includePoints = false;
                                        excurAmbigStart = -1;
                                    elseif( pastExcur )    % Did an excursion start at the end of previous day?
                                        if( inLimInARow )
                                            countIn = inLimNumber - numEndPointsIn;
                                        else
                                            countIn = inLimNumber - numPointsIn;
                                        end
                                        includePoints = true;
                                        if( itPast )
                                            excurAmbigStart = outOfLimPast(itPast,iband+1,ichannel); % Ambiguous start for current day?
                                        else
                                            excurAmbigStart = 0;    % The entire previous day was one long excursion! What to do?!
                                        end
                                    else
                                        countIn = 0;
                                        includePoints = false;
                                        numPointsOutRow = numPointsOut;
                                        excurAmbigStart = outOfLimPast(96,iband+1,ichannel); % Ambiguous start for current day?
                                    end % if
                                    % numPointsOutTemp = 0;
                                    energyOutTemp = 0;
                                    numPointsInTemp = 0;
                                    % numEndPointsIn = 0;
                                    energyInTemp = 0;

                                    % Determine excursions for current day
                                    for it = 1:96
                                        if( outOfLimCurr(it,iband+1,ichannel) == 1 ) % Out-of-limit, increment counter
                                            if( includePoints ) % Excursion already occurring
                                                numPointsOut = numPointsOut + 1;
                                                energyOut = energyOut + dataCurr(it,iband+1,ichannel) - limitCurr(it,iband+1,ichannel);
                                                numPointsIn = numPointsIn + numPointsInTemp;
                                                numPointsInTemp = 0;
                                                energyIn = energyIn + energyInTemp;
                                                energyInTemp = 0;
                                                if( inLimInARow )
                                                    countIn = inLimNumber;
                                                end
                                            else
                                                numPointsOutRow = numPointsOutRow + 1;
                                                energyOutTemp = energyOutTemp + dataCurr(it,iband+1,ichannel) - limitCurr(it,iband+1,ichannel);
                                                if( numPointsOutRow >= outLimNumber )
                                                    numPointsOut = numPointsOut + numPointsOutRow;
                                                    numPointsOutRow = 0;
                                                    energyOut = energyOut + energyOutTemp;
                                                    energyOutTemp = 0;
                                                    includePoints = true;
                                                    countIn = inLimNumber;
                                                end % if
                                            end % if
                                        elseif( outOfLimCurr(it,iband+1,ichannel) == 0 )
                                            numPointsOutRow = 0;
                                            if( includePoints ) % Excursion occurring
                                                numPointsInTemp = numPointsInTemp + 1;
                                                energyInTemp = energyInTemp - dataCurr(it,iband+1,ichannel) + limitCurr(it,iband+1,ichannel);
                                                countIn = countIn - 1;
                                                if( countIn == 0 )
                                                    % LOG EXCURSIONS HERE!!!!!!!!!!!!!!!!!!!!!
                                                    display(sprintf('HIGH EXCURSION: band - %d, channel - %d',iband,ichannel))
                                                    if( logExcurDB )
                                                        eT = id + (it - numPointsInTemp)/96 + 8/24;     % Time of last point out-of-limit, UTC
                                                        sT = eT - (numPointsOut + numPointsIn - 1)/96;  % Time of first point out-of-limit, UTC
                                                        success = logFBExcursionToFile(outFile,sT,eT,baseHi,'ABOVE',devHi,outLimNumber,inLimNumber,inLimInARow,network,isiteStr,ichannel,iband,numPointsOut,numPointsIn,energyOut,energyIn,excurAmbigStart,excurAmbigEnd);
                                                        if( success < 0 )
                                                            disp([sprintf('Failed to log excursion: %d | %d | ',sT,eT) baseHi sprintf(' | %d | ',devHi) network ...
                                                                sprintf(' | %s | %d | %d | ',isiteStr,ichannel,iband) sprintf('%d | %d | ',numPointsOut,numPointsIn) ...
                                                                sprintf('%d | %d | ',energyOut,energyIn) sprintf('%d | %d',excurAmbigStart,excurAmbigEnd)]);
                                                            allExcurLogged = false;
                                                        end
                                                    end

                                                    if( logExcurMAT )
                                                        eT = id + (it - numPointsInTemp)/96 + 8/24;     % Time of last point out-of-limit, UTC
                                                        sT = eT - (numPointsOut + numPointsIn - 1)/96;  % Time of first point out-of-limit, UTC
                                                        dur = (eT - sT)*86400;                          % Excursion duration, seconds
                                                        numPoints = numPointsOut + numPointsIn;         % Total number of points in excursion
                                                        energy = energyOut - energyIn;                  % Total "energy" in excursion
                                                        inferredStart = excurAmbigStart && true;        % inferred start due to bad data or limit
                                                        inferredEnd = excurAmbigEnd && true;            % inferred end due to bad data or limit

                                                        % elogsize = size(excurLog,1);
                                                        excurLog = [ excurLog; sT,eT,dur,iband,ichannel,numPoints,numPointsOut,numPointsIn,energy,energyOut,energyIn,inferredStart,inferredEnd ];
                                                        % display(sprintf('Excursion MAT Log Update: band - %d, channel - %d',iband,ichannel))
                                                        % display(sprintf('MAT Log rows: old - %d, new - %d',elogsize,size(excurLog,1)))
                                                    end

                                                    % Update excursion points
                                                    endPointTime = it - numPointsInTemp;
                                                    startPointTime = endPointTime - (numPointsOut + numPointsIn - 1);
                                                    if( endPointTime <= 0 )
                                                        excurPtsPast = [excurPtsPast;dataPast(96+startPointTime:96+endPointTime,1,ichannel),dataPast(96+startPointTime:96+endPointTime,iband+1,ichannel)];
                                                    elseif( startPointTime <= 0 )
                                                        excurPtsPast = [excurPtsPast;dataPast(96+startPointTime:96,1,ichannel),dataPast(96+startPointTime:96,iband+1,ichannel)];
                                                        excurPointsTemp = [dataCurr(1:endPointTime,1,ichannel),dataCurr(1:endPointTime,iband+1,ichannel)];
                                                        excurPtsCurr = [excurPtsCurr;excurPointsTemp];
                                                    else
                                                        excurPointsTemp = [dataCurr(startPointTime:endPointTime,1,ichannel),dataCurr(startPointTime:endPointTime,iband+1,ichannel)];
                                                        excurPtsCurr = [excurPtsCurr;excurPointsTemp];
                                                    end % if

                                                    % Reset variables
                                                    numPointsOut = 0;
                                                    energyOut = 0;
                                                    numPointsIn = 0;
                                                    energyIn = 0;
                                                    numPointsInTemp = 0;
                                                    energyInTemp = 0;
                                                    includePoints = false;
                                                    excurAmbigStart = 0;
                                                    excurAmbigEnd = 0;
                                                end
                                            else
                                                excurAmbigStart = 0;
                                            end % if( includePoints )
                                        else % Bad Data or Limits
                                            numPointsOutRow = 0;
                                            if( includePoints ) % Excursion occurring
                                                excurAmbigEnd = outOfLimCurr(it,iband+1,ichannel); % Ambiguous end to excursion
                                                
                                                % NOTE: We do not update number of points in here!!!

                                                % LOG EXCURSIONS HERE!!!!!!!!!!!!!!!!!!!!!!!
                                                display(sprintf('HIGH EXCURSION: band - %d, channel - %d',iband,ichannel))
                                                if( logExcurDB )
                                                    eT = id + (it - numPointsInTemp - 1)/96 + 8/24; % Time of last point out-of-limit, UTC
                                                    sT = eT - (numPointsOut + numPointsIn - 1)/96;  % Time of first point out-of-limit, UTC
                                                    success = logFBExcursionToFile(outFile,sT,eT,baseHi,'ABOVE',devHi,outLimNumber,inLimNumber,inLimInARow,network,isiteStr,ichannel,iband,numPointsOut,numPointsIn,energyOut,energyIn,excurAmbigStart,excurAmbigEnd);
                                                    if( success < 0 )
                                                        disp([sprintf('Failed to log excursion: %d | %d | ',sT,eT) baseHi sprintf(' | %d | ',devHi) network ...
                                                            sprintf(' | %s | %d | %d | ',isiteStr,ichannel,iband) sprintf('%d | %d | ',numPointsOut,numPointsIn) ...
                                                            sprintf('%d | %d | ',energyOut,energyIn) sprintf('%d | %d',excurAmbigStart,excurAmbigEnd)]);
                                                        allExcurLogged = false;
                                                    end
                                                end

                                                if( logExcurMAT )
                                                    eT = id + (it - numPointsInTemp - 1)/96 + 8/24;     % Time of last point out-of-limit, UTC
                                                    sT = eT - (numPointsOut + numPointsIn - 1)/96;  % Time of first point out-of-limit, UTC
                                                    dur = (eT - sT)*86400;                          % Excursion duration, seconds
                                                    numPoints = numPointsOut + numPointsIn;         % Total number of points in excursion
                                                    energy = energyOut - energyIn;                  % Total "energy" in excursion
                                                    inferredStart = excurAmbigStart && true;        % inferred start due to bad data or limit
                                                    inferredEnd = excurAmbigEnd && true;            % inferred end due to bad data or limit

                                                    % elogsize = size(excurLog,1);
                                                    excurLog = [ excurLog; sT,eT,dur,iband,ichannel,numPoints,numPointsOut,numPointsIn,energy,energyOut,energyIn,inferredStart,inferredEnd ];
                                                    % display(sprintf('Excursion MAT Log Update: band - %d, channel - %d',iband,ichannel))
                                                    % display(sprintf('MAT Log rows: old - %d, new - %d',elogsize,size(excurLog,1)))
                                                end

                                                % Update excursion points
                                                endPointTime = it - numPointsInTemp - 1;
                                                startPointTime = endPointTime - (numPointsOut + numPointsIn - 1);
                                                if( endPointTime <= 0 )
                                                    excurPtsPast = [excurPtsPast;dataPast(96+startPointTime:96+endPointTime,1,ichannel),dataPast(96+startPointTime:96+endPointTime,iband+1,ichannel)];
                                                elseif( startPointTime <= 0 )
                                                    excurPtsPast = [excurPtsPast;dataPast(96+startPointTime:96,1,ichannel),dataPast(96+startPointTime:96,iband+1,ichannel)];
                                                    excurPointsTemp = [dataCurr(1:endPointTime,1,ichannel),dataCurr(1:endPointTime,iband+1,ichannel)];
                                                    excurPtsCurr = [excurPtsCurr;excurPointsTemp];
                                                else
                                                    excurPointsTemp = [dataCurr(startPointTime:endPointTime,1,ichannel),dataCurr(startPointTime:endPointTime,iband+1,ichannel)];
                                                    excurPtsCurr = [excurPtsCurr;excurPointsTemp];
                                                end % if

                                                % Reset variables
                                                numPointsOut = 0;
                                                energyOut = 0;
                                                numPointsIn = 0;
                                                energyIn = 0;
                                                numPointsInTemp = 0;
                                                energyInTemp = 0;
                                                includePoints = false;
                                                countIn = 0;
                                                excurAmbigEnd = 0;
                                            end % if
                                            excurAmbigStart = outOfLimCurr(it,iband+1,ichannel); % Ambiguous start to next excursion
                                        end % if
                                    end % for it = 1:96
                                    
                                    if( isnan(allExcursPast) || ~allExcursPast )
                                    else
                                        excurPtsPast = [ ];
                                    end

                                    % Save excurPoints to a .mat file
                                    % Use similar file structure as data
                                    if( saveExcursions )
                                        try
                                            if( ~isempty( excurPtsPast ) && dataPastExist )
                                                % excurPoints = excurPtsPast;  %#ok<NASGU> - used in sprintf statement
                                                % allExcurs = true;                  %#ok<NASGU> - used in sprintf statement
                                                % cmd = sprintf('save %s excurPoints allExcurs;', excurFilePast );
                                                % eval( cmd );
                                                cmd = sprintf('excurPoints%02d%02d%02d = excurPtsPast; allExcurs%02d%02d%02d = allExcursPast;', ...
                                                    outLimNumber, inLimNumber, inLimInARow, outLimNumber, inLimNumber, inLimInARow );
                                                eval( cmd );
                                                cmd = sprintf('save %s excurPoints%02d%02d%02d allExcurs%02d%02d%02d', ...
                                                    excurFilePast, outLimNumber, inLimNumber, inLimInARow, outLimNumber, inLimNumber, inLimInARow );
                                                if( exist( excurFilePast, 'file' ) )
                                                    cmd = sprintf('%s -append',cmd);
                                                end
                                                eval( cmd );
                                                % display(sprintf('Past Excursion Points saved to file: %s', excurFileOffPast ))
                                            end % if( ~isempty( excurPointsPast ) )
                                            % excurPoints = excurPtsCurr;
                                            % allExcurs = allExcursCurr;
                                            % cmd = sprintf('save %s excurPoints allExcurs;', excurFileCurr );
                                            % eval( cmd );
                                            cmd = sprintf('excurPoints%02d%02d%02d = excurPtsCurr; allExcurs%02d%02d%02d = allExcursCurr;', ...
                                                outLimNumber, inLimNumber, inLimInARow, outLimNumber, inLimNumber, inLimInARow );
                                            eval( cmd );
                                            cmd = sprintf('save %s excurPoints%02d%02d%02d allExcurs%02d%02d%02d', ...
                                                excurFileCurr, outLimNumber, inLimNumber, inLimInARow, outLimNumber, inLimNumber, inLimInARow );
                                            if( exist( excurFileCurr, 'file' ) )
                                                cmd = sprintf('%s -append',cmd);
                                            end
                                            eval( cmd );
                                            % display(sprintf('Current Excursion Points saved to file: %s', excurFileOffCurr ))
                                        catch
                                            display('Error saving excursion points to file')
                                            display('Excursion Files:')
                                            display(['Current Day: ' datestr(id,'yyyy-mm-dd') ' File: ' excurFileCurr])
                                            display(['Previous Day: ' datestr(id-1,'yyyy-mm-dd') ' File: ' excurFilePast])
                                            allExcurSaved = false;
                                            % display('BAD_WRITE')
                                            % success = -1;
                                            % return
                                        end
                                    end
                                end % for ichannel = channels
                            end % for iband = bands
                            
                            % Save excursion .mat log if created
                            if( logExcurMAT )
                                try
                                    siteName = isiteName;   %#ok<NASGU> - used in sprintf statement
                                    siteNum = isiteStr;     %#ok<NASGU> - used in sprintf statement

                                    if( ~isempty(excurLog) )
                                        baseline = baseHi; %#ok<NASGU>
                                        dev = devHi;            %#ok<NASGU> - used in sprintf statement

                                        cmd = sprintf('save %s excurLog siteName siteNum network baseline dev outLimNumber inLimNumber inLimInARow', fileExcurMatLog);
                                        eval(cmd);
                                        display(sprintf('High Excursions logged to file: %s', fileExcurMatLog ))
                                    end
                                catch
                                    display('Failed to save excursion .mat log')
                                    display(sprintf('.mat log file hi: %s',fileExcurMatLog))
                                    display('BAD_WRITE')
                                    success = -1;
                                    return
                                end
                            end % if( logExcurMAT )
                        end % for iInLim = inLimHis
                    end % for iOutLim = outLimHis
                end % for iDev = 1:size(devHis,1)
                
                % If we got here, all excursion files have been saved, notify
                if( saveExcursions )
                    if( allExcurSaved )
                        display(['High Excursions updated for day: ' datestr(id-1,'yyyy-mm-dd')])
                        display(['High Excursions saved for day: ' datestr(id,'yyyy-mm-dd')])
                    else
                        display(sprintf('WARNING: Not all high excursions saved for days %s - %s',datestr(id-1,'yyyy-mm-dd'),datestr(id,'yyyy-mm-dd')))
                    end
                end
            end % if( ~excurHiOff )
            
            % Low Limits and Excursions
            if( ~excurLoOff )
                allExcurSaved = true;
                for iDev = 1:size(devLos,1)
                    devLo = devLos(iDev);
                    if( strcmpi( baseLo, 'median' ) ) % make sure percentiles are integer values in range 0-100
                        devLo = floor(devLo);

                        if( devLo < 0 )
                            display('WARNING: Percentile given for lower limit is less than 0. Setting to 0.')
                            devLo = 0;
                        end
                        
                        if( devLo > 100 )
                            display('WARNING: Percentile given for lower limit is greater than 100. Setting to 100.')
                            devLo = 100;
                        end
                    elseif( strcmpi( baseLo, 'mean' ) )
                    else
                        success = -1;
                        display(sprintf('Invalid Low baseline input argument: %s',baseLo))
                        display('USAGE')
                        return
                    end
                    display(sprintf('Low Limit Definition: Baseline - %s, Deviation - %d',baseLo,devLo))
                    
                    % Generate Limits
                    optLimArgs = '''pT''';
                    if( loadLimits ), optLimArgs = sprintf('''loadLimits'',%s',optLimArgs); end
                    if( saveLimits ), optLimArgs = sprintf('''saveLimits'',%s',optLimArgs); end
                    optLimArgs = sprintf('''baseLo'',baseLo,''devLo'',devLo,%s',optLimArgs);
                    try
                        limitCmd = sprintf('[trash,limitPast] = genFBLimits(''%s'',network,isite,bands,channels,%s);',datestr(id-1,'yyyy/mm/dd'),optLimArgs);
                        eval(limitCmd)
                        limitCmd = sprintf('[trash,limitCurr] = genFBLimits(''%s'',network,isite,bands,channels,%s);',datestr(id,'yyyy/mm/dd'),optLimArgs);
                        eval(limitCmd)
                        clear trash
                        display('Low Limits Generated')
                    catch
                        display('Error Generating Low Limits')
                        success = -1;
                        display('FAILURE')
                        return
                    end
                    
                    % Calculate Out Of Limits
                    outOfLimCurr = zeros(96,14,4);
                    outOfLimCurr(:,1,:) = dataCurr(:,1,:);
                    outOfLimPast = zeros(96,14,4);
                    outOfLimPast(:,1,:) = dataPast(:,1,:);
                    
                    % Loop through time of day
                    for it=1:96
                        % Calculate time stamp
                        % t = dataCurr(it,1,1);

%                         % Look up kp
%                         % For the current time, get the closest time with a known kp
%                         % For that time, get the kp value
%                         thisKp = kp( closest( kpdtnum,t ) );
%                         if ~isempty(thisKp)
%                             switch floor(thisKp),
%                                 case {0,1}
%                                     kp_tmp = 1;
%                                 case {2,3}
%                                     kp_tmp = 2;
%                                 case {4,5}
%                                     kp_tmp = 3;
%                                 case {6,7,8,9}
%                                     kp_tmp = 4;
%                             end % switch
%                         else
%                             kp_tmp = 1;
%                         end

                        % Iterate over all desired bands
                        for iband = bands
                            for ichannel = channels
                                % Exclusion Time?
                                cExcl = false;
                                pExcl = false;
                                if( removeExclusions )
                                    currTime = dataCurr(it,1,ichannel);
                                    pastTime = dataPast(it,1,ichannel);
                                    ctimeExcl = (exclusions(:,1) <= currTime) & (exclusions(:,2) >= currTime);
                                    ptimeExcl = (exclusions(:,1) <= pastTime) & (exclusions(:,2) >= pastTime);
                                    siteExcl = (exclusions(:,3) == isite);
                                    chExcl = (exclusions(:,4) == ichannel);
                                    
                                    crelExcl = exclusions( ctimeExcl & siteExcl & chExcl, : );
                                    prelExcl = exclusions( ptimeExcl & siteExcl & chExcl, : );
                                    if( ~isempty(crelExcl) ), cExcl = true; end
                                    if( ~isempty(prelExcl) ), pExcl = true; end
                                end % if( removeExclusions )
                                
                                % Mark Out-of-Limit
                                % Current Data
                                if( dataCurr(it,iband+1,ichannel) <= 0 )                    % Data is not available
                                    outOfLimCurr(it,iband+1,ichannel) = -1;
                                elseif( isnan(dataCurr(it,iband+1,ichannel)) )              % Data is NaN
                                    outOfLimCurr(it,iband+1,ichannel) = -2;
                                elseif( limitCurr(it,iband+1,ichannel) <= 0 )
                                    outOfLimCurr(it,iband+1,ichannel) = -3;
                                elseif( isnan(limitCurr(it,iband+1,ichannel)) )
                                    outOfLimCurr(it,iband+1,ichannel) = -4;
                                elseif( cExcl )
                                    outOfLimCurr(it,iband+1,ichannel) = -5;                 % Exclusion time
                                % Is the data out of limit?
                                elseif( (dataCurr(it,iband+1,ichannel) < limitCurr(it,iband+1,ichannel)) )      % Data is greater than Lo limit
                                    outOfLimCurr(it,iband+1,ichannel) = 1;
                                end

                                % Past Data
                                if( dataPast(it,iband+1,ichannel) <= 0 )                    % Data is not available
                                    outOfLimPast(it,iband+1,ichannel) = -1;
                                elseif( isnan(dataPast(it,iband+1,ichannel)) )              % Data is NaN
                                    outOfLimPast(it,iband+1,ichannel) = -2;
                                elseif( limitPast(it,iband+1,ichannel) <= 0 )
                                    outOfLimPast(it,iband+1,ichannel) = -3;
                                elseif( isnan(limitPast(it,iband+1,ichannel)) )
                                    outOfLimPast(it,iband+1,ichannel) = -4;
                                elseif( pExcl )
                                    outOfLimPast(it,iband+1,ichannel) = -5;                 % Exclusion time
                                % Is the data out of limit?
                                elseif( (dataPast(it,iband+1,ichannel) < limitPast(it,iband+1,ichannel)) )      % Data is greater than Lo limit
                                    outOfLimPast(it,iband+1,ichannel) = 1;
                                end
                            end % for ichannel = channels
                        end % for iband = bands
                    end % for it=1:96
                    
                    % Iterate over all outLimNumbers
                    inLimInARow = inLimRowLo;
                    for iOutLim = outLimLos
                        outLimNumber = iOutLim;
                        
                        % Iterate over all inLimNumbers
                        for iInLim = inLimLos
                            inLimNumber = iInLim;
                            display(sprintf('Out Lim Number: %d, In Lim Number: %d, In Lim In A Row: %d',outLimNumber,inLimNumber,inLimInARow))
                            
                            % Create Excursion .mat log files
                            % Make sure it works with BK network!!!
                            if( logExcurMAT )
                                excurLog = [ ];
                                
                                if( strcmpi( baseLo, 'mean' ) )
                                    if( devLo <= 0 )
                                        fileExcurMatLog = sprintf( '%s/%s.%s.%s.fblog.p%02d.lo.%02d%02d%d.mat', ...
                                            tmpExcurMatLogLo,datestr(id,'yyyymmdd'),network,isiteStr,-devLo,outLimNumber,inLimNumber,inLimInARow );
                                    else
                                        fileExcurMatLog = sprintf( '%s/%s.%s.%s.fblog.n%02d.lo.%02d%02d%d.mat', ...
                                            tmpExcurMatLogLo,datestr(id,'yyyymmdd'),network,isiteStr,devLo,outLimNumber,inLimNumber,inLimInARow );
                                    end
                                else
                                    fileExcurMatLog = sprintf( '%s/%s.%s.%s.fblog.%03d.lo.%02d%02d%d.mat', ...
                                        tmpExcurMatLogLo,datestr(id,'yyyymmdd'),network,isiteStr,devLo,outLimNumber,inLimNumber,inLimInARow );
                                end
                            end % if( logExcurMAT )
                            
                            % Excursions count
                            for iband = bands
                                for ichannel = channels
                                    % Excursion Points
                                    % Generate File Names for excursion points
                                    if( loadExcursions || saveExcursions )
                                        if( strcmpi(network,'CMN') )
                                            currDir = fbExcurPointsDir;
                                            success = verifyEnvironment(currDir);
                                            currDir = [currDir sprintf('/%s',isiteFN)];
                                            success = success && verifyEnvironment(currDir);
                                            currDir = [currDir sprintf('/FB%02d',iband)];
                                            success = success && verifyEnvironment(currDir);
                                            currDir = [currDir sprintf('/CHANNEL%d',ichannel)];
                                            success = success && verifyEnvironment(currDir);
                                            if( ~success )
                                                display('Unable to create Excursion Directory')
                                                display('ENVIRONMENT')
                                                success = -1;
                                                return
                                            end

                                            % Different File Names for Hi & Lo
                                            if( strcmpi( baseLo, 'mean' ) )
                                                if( devLo <= 0 )
                                                    excurFileCurr = [currDir ...
                                                        sprintf('/%s.%s.%s.%02d.%d.fbe.lo.p%02d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,-devLo)];
                                                    excurFilePast = [currDir ...
                                                        sprintf('/%s.%s.%s.%02d.%d.fbe.lo.p%02d.mat',datestr(id-1,'yyyymmdd'),network,isiteStr,iband,ichannel,-devLo)];
                                                else
                                                    excurFileCurr = [currDir ...
                                                        sprintf('/%s.%s.%s.%02d.%d.fbe.lo.n%02d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,devLo)];
                                                    excurFilePast = [currDir ...
                                                        sprintf('/%s.%s.%s.%02d.%d.fbe.lo.n%02d.mat',datestr(id-1,'yyyymmdd'),network,isiteStr,iband,ichannel,devLo)];
                                                end
                                            elseif( strcmpi( baseLo, 'median' ) )
                                                excurFileCurr = [currDir ...
                                                    sprintf('/%s.%s.%s.%02d.%d.fbe.lo.%03d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,devLo)];
                                                excurFilePast = [currDir ...
                                                    sprintf('/%s.%s.%s.%02d.%d.fbe.lo.%03d.mat',datestr(id-1,'yyyymmdd'),network,isiteStr,iband,ichannel,devLo)];
                                            end
                                        else
                                            % MODIFY TO WORK WITH OTHER NETWORKS!!!
                                        end % if( strcmpi(network,'CMN') )
                                    end % if( loadExcursions || saveExcursions )

                                    % Load .mat file for previous day excursion points
                                    try
                                        if( dataPastExist && loadExcursions )
                                            cmd = sprintf('load %s excurPoints%02d%02d%02d allExcurs%02d%02d%02d', ...
                                                excurFilePast, outLimNumber, inLimNumber, inLimInARow, outLimNumber, inLimNumber, inLimInARow );
                                            eval( cmd );
                                            cmd = sprintf('excurPtsPast = excurPoints%02d%02d%02d; allExcursPast = allExcurs%02d%02d%02d;', ...
                                                outLimNumber, inLimNumber, inLimInARow, outLimNumber, inLimNumber, inLimInARow );
                                            eval( cmd );
                                            % excurPtsPast = excurPoints;
                                            % allExcursPast = allExcurs;
                                        else
                                            excurPtsPast = [ ];
                                            allExcursPast = NaN;
                                        end
                                    catch
                                        excurPtsPast = [ ];   % Vector containing the timestamp and data value for all points in an excursion during the previous day
                                        allExcursPast = NaN;
                                    end
                                    excurPtsCurr = [ ];   % Vector containing the timestamp and data value for all points in an excursion during the current day
                                    allExcursCurr = false; %#ok<NASGU>

                                    % Excursion variables - reset every loop
                                    % Booleans
                                    pastExcur = false;          % Previous day ended with an excursion
                                    includePoints = false;      % Excursion is occurring - include points
                                    addEndCountOut = true;     % End of the previous day - count points out-of-limit that end the day
                                    addEndCountIn = true;      % End of the previous day - count points in-limit that end the day
                                    % Out-Of-Limits
                                    numPointsOut = 0;       % Number of points that are out-of-limit that are part of an excursion
                                    numPointsOutTemp = 0;   % The points are out-of-limit but not yet part of an excursion
                                    numPointsOutRow = 0;    % Number of points in the current stretch of out-of-limit - used to determine if an excursion occurred
                                    energyOut = 0;          % Sum of the "energy" for out-of-limit points that are part of an excursion
                                    energyOutTemp = 0;      % "Energy" for points that are out-of-limit but not yet part of an excursion
                                    % In-Limit
                                    numPointsIn = 0;        % Number of points that are in-limit that are part of an excursion
                                    numPointsInTemp = 0;    % Points are in-limit but not yet part of an excursion
                                    numEndPointsIn = 0;     % Number of points in-limit that ended the previous day - only necessary if there's an excursion overlap over two days
                                    energyIn = 0;           % Sum of the "energy" for in-limit points that are part of an excursion
                                    energyInTemp = 0;       % "Energy" for points that are in-limit but not yet part of an excursion
                                    countIn = inLimNumber;  % Count of the number of points that need to be in-limit to stop the current excursion
                                    % Data Integrity
                                    % excurAmbigStart = 0;    % At the start of an excursion, was there unusable data or limits? (Can't tell when the excursion started)
                                    excurAmbigEnd = 0;      % At the end of an excursion, was there unusable data or limits? (Can't tell when the excursion ended)

                                    % LOW EXCURSIONS
                                    itPast = 96;
                                    while( dataPastExist && (itPast > 0) && (countIn > 0) && (outOfLimPast(itPast,iband+1,ichannel) >= 0) )
                                        if( outOfLimPast(itPast,iband+1,ichannel) == 1 )  % Is the point out-of-limits?
                                            numPointsOutRow = numPointsOutRow + 1;
                                            energyOutTemp = energyOutTemp - dataPast(itPast,iband+1,ichannel) + limitPast(itPast,iband+1,ichannel);
                                            if( addEndCountIn )
                                                numEndPointsIn = numPointsInTemp;
                                                numPointsIn = numPointsIn + numEndPointsIn;
                                                numPointsInTemp = 0;
                                                energyIn = energyIn + energyInTemp;
                                                energyInTemp = 0;
                                            end
                                            addEndCountIn = false;
                                            if( inLimInARow )
                                                countIn = inLimNumber;
                                            end % if
                                        else
                                            if( numPointsOutRow >= outLimNumber )
                                                includePoints = true;
                                                pastExcur = true;
                                            end
                                            numPointsOutTemp = numPointsOutTemp + numPointsOutRow;
                                            numPointsOutRow = 0;
                                            if( includePoints || addEndCountOut )
                                                numPointsOut = numPointsOut + numPointsOutTemp;
                                                numPointsOutTemp = 0;
                                                energyOut = energyOut + energyOutTemp;
                                                energyOutTemp = 0;
                                                numPointsIn = numPointsIn + numPointsInTemp;
                                                numPointsInTemp = 0;
                                                energyIn = energyIn + energyInTemp;
                                                energyInTemp = 0;
                                                includePoints = false;
                                            end
                                            addEndCountOut = false;
                                            numPointsInTemp = numPointsInTemp + 1;
                                            energyInTemp = energyInTemp + dataPast(itPast,iband+1,ichannel) - limitPast(itPast,iband+1,ichannel);
                                            countIn = countIn - 1;
                                        end % if
                                        itPast = itPast - 1;
                                    end % while

                                    if( ~dataPastExist )
                                        countIn = 0;
                                        includePoints = false;
                                        excurAmbigStart = -1;
                                    elseif( pastExcur )    % Did an excursion start at the end of previous day?
                                        if( inLimInARow )
                                            countIn = inLimNumber - numEndPointsIn;
                                        else
                                            countIn = inLimNumber - numPointsIn;
                                        end
                                        includePoints = true;
                                        if( itPast )
                                            excurAmbigStart = outOfLimPast(itPast,iband+1,ichannel); % Ambiguous start for current day?
                                        else
                                            excurAmbigStart = 0;    % The entire previous day was one long excursion! What to do?!
                                        end
                                    else
                                        countIn = 0;
                                        includePoints = false;
                                        numPointsOutRow = numPointsOut;
                                        excurAmbigStart = outOfLimPast(96,iband+1,ichannel); % Ambiguous start for current day?
                                    end % if
                                    % numPointsOutTemp = 0;
                                    energyOutTemp = 0;
                                    numPointsInTemp = 0;
                                    % numEndPointsIn = 0;
                                    energyInTemp = 0;

                                    % Determine excursions for current day
                                    for it = 1:96
                                        if( outOfLimCurr(it,iband+1,ichannel) == 1 ) % Out-of-limit, increment counter
                                            if( includePoints ) % Excursion already occurring
                                                numPointsOut = numPointsOut + 1;
                                                energyOut = energyOut - dataCurr(it,iband+1,ichannel) + limitCurr(it,iband+1,ichannel);
                                                numPointsIn = numPointsIn + numPointsInTemp;
                                                numPointsInTemp = 0;
                                                energyIn = energyIn + energyInTemp;
                                                energyInTemp = 0;
                                                if( inLimInARow )
                                                    countIn = inLimNumber;
                                                end
                                            else
                                                numPointsOutRow = numPointsOutRow + 1;
                                                energyOutTemp = energyOutTemp - dataCurr(it,iband+1,ichannel) + limitCurr(it,iband+1,ichannel);
                                                if( numPointsOutRow >= outLimNumber )
                                                    numPointsOut = numPointsOut + numPointsOutRow;
                                                    numPointsOutRow = 0;
                                                    energyOut = energyOut + energyOutTemp;
                                                    energyOutTemp = 0;
                                                    includePoints = true;
                                                    countIn = inLimNumber;
                                                end % if
                                            end % if
                                        elseif( outOfLimCurr(it,iband+1,ichannel) == 0 )
                                            numPointsOutRow = 0;
                                            if( includePoints ) % Excursion occurring
                                                numPointsInTemp = numPointsInTemp + 1;
                                                energyInTemp = energyInTemp + dataCurr(it,iband+1,ichannel) - limitCurr(it,iband+1,ichannel);
                                                countIn = countIn - 1;
                                                if( countIn == 0 )
                                                    % LOG EXCURSIONS HERE!!!!!!!!!!!!!!!!!!!!!
                                                    display(sprintf('LOW EXCURSION: band - %d, channel - %d',iband,ichannel))
                                                    if( logExcurDB )
                                                        eT = id + (it - numPointsInTemp)/96 + 8/24;     % Time of last point out-of-limit, UTC
                                                        sT = eT - (numPointsOut + numPointsIn - 1)/96;  % Time of first point out-of-limit, UTC
                                                        success = logFBExcursionToFile(outFile,sT,eT,baseLo,'BELOW',devLo,outLimNumber,inLimNumber,inLimInARow,network,isiteStr,ichannel,iband,numPointsOut,numPointsIn,energyOut,energyIn,excurAmbigStart,excurAmbigEnd);
                                                        if( success < 0 )
                                                            disp([sprintf('Failed to log excursion: %d | %d | ',sT,eT) baseLo sprintf(' | %d | ',devLo) network ...
                                                                sprintf(' | %s | %d | %d | ',isiteStr,ichannel,iband) sprintf('%d | %d | ',numPointsOut,numPointsIn) ...
                                                                sprintf('%d | %d | ',energyOut,energyIn) sprintf('%d | %d',excurAmbigStart,excurAmbigEnd)]);
                                                            allExcurLogged = false;
                                                        end
                                                    end

                                                    if( logExcurMAT )
                                                        eT = id + (it - numPointsInTemp)/96 + 8/24;     % Time of last point out-of-limit, UTC
                                                        sT = eT - (numPointsOut + numPointsIn - 1)/96;  % Time of first point out-of-limit, UTC
                                                        dur = (eT - sT)*86400;                          % Excursion duration, seconds
                                                        numPoints = numPointsOut + numPointsIn;         % Total number of points in excursion
                                                        energy = energyOut - energyIn;                  % Total "energy" in excursion
                                                        inferredStart = excurAmbigStart && true;        % inferred start due to bad data or limit
                                                        inferredEnd = excurAmbigEnd && true;            % inferred end due to bad data or limit

                                                        % elogsize = size(excurLog,1);
                                                        excurLog = [ excurLog; sT,eT,dur,iband,ichannel,numPoints,numPointsOut,numPointsIn,energy,energyOut,energyIn,inferredStart,inferredEnd ];
                                                        % display(sprintf('Excursion MAT Log Update: band - %d, channel - %d',iband,ichannel))
                                                        % display(sprintf('MAT Log rows: old - %d, new - %d',elogsize,size(excurLog,1)))
                                                    end

                                                    % Update excursion points
                                                    endPointTime = it - numPointsInTemp;
                                                    startPointTime = endPointTime - (numPointsOut + numPointsIn - 1);
                                                    if( endPointTime <= 0 )
                                                        excurPtsPast = [excurPtsPast;dataPast(96+startPointTime:96+endPointTime,1,ichannel),dataPast(96+startPointTime:96+endPointTime,iband+1,ichannel)];
                                                    elseif( startPointTime <= 0 )
                                                        excurPtsPast = [excurPtsPast;dataPast(96+startPointTime:96,1,ichannel),dataPast(96+startPointTime:96,iband+1,ichannel)];
                                                        excurPointsTemp = [dataCurr(1:endPointTime,1,ichannel),dataCurr(1:endPointTime,iband+1,ichannel)];
                                                        excurPtsCurr = [excurPtsCurr;excurPointsTemp];
                                                    else
                                                        excurPointsTemp = [dataCurr(startPointTime:endPointTime,1,ichannel),dataCurr(startPointTime:endPointTime,iband+1,ichannel)];
                                                        excurPtsCurr = [excurPtsCurr;excurPointsTemp];
                                                    end % if

                                                    % Reset variables
                                                    numPointsOut = 0;
                                                    energyOut = 0;
                                                    numPointsIn = 0;
                                                    energyIn = 0;
                                                    numPointsInTemp = 0;
                                                    energyInTemp = 0;
                                                    includePoints = false;
                                                    excurAmbigStart = 0;
                                                    excurAmbigEnd = 0;
                                                end
                                            else
                                                excurAmbigStart = 0;
                                            end % if( includePoints )
                                        else % Bad Data or Limits
                                            numPointsOutRow = 0;
                                            if( includePoints ) % Excursion occurring
                                                excurAmbigEnd = outOfLimCurr(it,iband+1,ichannel); % Ambiguous end to excursion

                                                % LOG EXCURSIONS HERE!!!!!!!!!!!!!!!!!!!!!!!
                                                display(sprintf('LOW EXCURSION: band - %d, channel - %d',iband,ichannel))
                                                if( logExcurDB )
                                                    eT = id + (it - numPointsInTemp - 1)/96 + 8/24; % Time of last point out-of-limit, UTC
                                                    sT = eT - (numPointsOut + numPointsIn - 1)/96;  % Time of first point out-of-limit, UTC
                                                    success = logFBExcursionToFile(outFile,sT,eT,baseLo,'BELOW',devLo,outLimNumber,inLimNumber,inLimInARow,network,isiteStr,ichannel,iband,numPointsOut,numPointsIn,energyOut,energyIn,excurAmbigStart,excurAmbigEnd);
                                                    if( success < 0 )
                                                        disp([sprintf('Failed to log excursion: %d | %d | ',sT,eT) baseLo sprintf(' | %d | ',devLo) network ...
                                                            sprintf(' | %s | %d | %d | ',isiteStr,ichannel,iband) sprintf('%d | %d | ',numPointsOut,numPointsIn) ...
                                                            sprintf('%d | %d | ',energyOut,energyIn) sprintf('%d | %d',excurAmbigStart,excurAmbigEnd)]);
                                                        allExcurLogged = false;
                                                    end
                                                end

                                                if( logExcurMAT )
                                                    eT = id + (it - numPointsInTemp - 1)/96 + 8/24;     % Time of last point out-of-limit, UTC
                                                    sT = eT - (numPointsOut + numPointsIn - 1)/96;  % Time of first point out-of-limit, UTC
                                                    dur = (eT - sT)*86400;                          % Excursion duration, seconds
                                                    numPoints = numPointsOut + numPointsIn;         % Total number of points in excursion
                                                    energy = energyOut - energyIn;                  % Total "energy" in excursion
                                                    inferredStart = excurAmbigStart && true;        % inferred start due to bad data or limit
                                                    inferredEnd = excurAmbigEnd && true;            % inferred end due to bad data or limit

                                                    % elogsize = size(excurLog,1);
                                                    excurLog = [ excurLog; sT,eT,dur,iband,ichannel,numPoints,numPointsOut,numPointsIn,energy,energyOut,energyIn,inferredStart,inferredEnd ];
                                                    % display(sprintf('Excursion MAT Log Update: band - %d, channel - %d',iband,ichannel))
                                                    % display(sprintf('MAT Log rows: old - %d, new - %d',elogsize,size(excurLog,1)))
                                                end

                                                % Update excursion points
                                                endPointTime = it - numPointsInTemp - 1;
                                                startPointTime = endPointTime - (numPointsOut + numPointsIn - 1);
                                                if( endPointTime <= 0 )
                                                    excurPtsPast = [excurPtsPast;dataPast(96+startPointTime:96+endPointTime,1,ichannel),dataPast(96+startPointTime:96+endPointTime,iband+1,ichannel)];
                                                elseif( startPointTime <= 0 )
                                                    excurPtsPast = [excurPtsPast;dataPast(96+startPointTime:96,1,ichannel),dataPast(96+startPointTime:96,iband+1,ichannel)];
                                                    excurPointsTemp = [dataCurr(1:endPointTime,1,ichannel),dataCurr(1:endPointTime,iband+1,ichannel)];
                                                    excurPtsCurr = [excurPtsCurr;excurPointsTemp];
                                                else
                                                    excurPointsTemp = [dataCurr(startPointTime:endPointTime,1,ichannel),dataCurr(startPointTime:endPointTime,iband+1,ichannel)];
                                                    excurPtsCurr = [excurPtsCurr;excurPointsTemp];
                                                end % if

                                                % Reset variables
                                                numPointsOut = 0;
                                                energyOut = 0;
                                                numPointsIn = 0;
                                                energyIn = 0;
                                                numPointsInTemp = 0;
                                                energyInTemp = 0;
                                                includePoints = false;
                                                countIn = 0;
                                                excurAmbigEnd = 0;
                                            end % if
                                            excurAmbigStart = outOfLimCurr(it,iband+1,ichannel); % Ambiguous start to next excursion
                                        end % if
                                    end % for it = 1:96
                                    
                                    if( isnan(allExcursPast) || ~allExcursPast )
                                    else
                                        excurPtsPast = [ ];
                                    end

                                    % Save excurPoints to a .mat file
                                    % Use similar file structure as data
                                    if( saveExcursions )
                                        try
                                            if( ~isempty( excurPtsPast ) && dataPastExist )
                                                % excurPoints = excurPtsPast;  %#ok<NASGU> - used in sprintf statement
                                                % allExcurs = true;                  %#ok<NASGU> - used in sprintf statement
                                                % cmd = sprintf('save %s excurPoints allExcurs;', excurFilePast );
                                                % eval( cmd );
                                                cmd = sprintf('excurPoints%02d%02d%02d = excurPtsPast; allExcurs%02d%02d%02d = allExcursPast;', ...
                                                    outLimNumber, inLimNumber, inLimInARow, outLimNumber, inLimNumber, inLimInARow );
                                                eval( cmd );
                                                cmd = sprintf('save %s excurPoints%02d%02d%02d allExcurs%02d%02d%02d', ...
                                                    excurFilePast, outLimNumber, inLimNumber, inLimInARow, outLimNumber, inLimNumber, inLimInARow );
                                                if( exist( excurFilePast, 'file' ) )
                                                    cmd = sprintf('%s -append',cmd);
                                                end
                                                eval( cmd );
                                                % display(sprintf('Past Excursion Points saved to file: %s', excurFileOffPast ))
                                            end % if( ~isempty( excurPointsPast ) )
                                            % excurPoints = excurPtsCurr;
                                            % allExcurs = allExcursCurr;
                                            % cmd = sprintf('save %s excurPoints allExcurs;', excurFileCurr );
                                            % eval( cmd );
                                            cmd = sprintf('excurPoints%02d%02d%02d = excurPtsCurr; allExcurs%02d%02d%02d = allExcursCurr;', ...
                                                outLimNumber, inLimNumber, inLimInARow, outLimNumber, inLimNumber, inLimInARow );
                                            eval( cmd );
                                            cmd = sprintf('save %s excurPoints%02d%02d%02d allExcurs%02d%02d%02d', ...
                                                excurFileCurr, outLimNumber, inLimNumber, inLimInARow, outLimNumber, inLimNumber, inLimInARow );
                                            if( exist( excurFileCurr, 'file' ) )
                                                cmd = sprintf('%s -append',cmd);
                                            end
                                            eval( cmd );
                                        catch
                                            display('Error saving excursion points to file')
                                            display('Excursion Files:')
                                            display(['Current Day: ' datestr(id,'yyyy-mm-dd') ' File: ' excurFileCurr])
                                            display(['Previous Day: ' datestr(id-1,'yyyy-mm-dd') ' File: ' excurFilePast])
                                            allExcurSaved = false;
                                            % display('BAD_WRITE')
                                            % success = -1;
                                            % return
                                        end
                                    end
                                end % for ichannel = channels
                            end % for iband = bands
                            
                            % Save excursion .mat log if created
                            if( logExcurMAT )
                                try
                                    siteName = isiteName;   %#ok<NASGU> - used in sprintf statement
                                    siteNum = isiteStr;     %#ok<NASGU> - used in sprintf statement

                                    if( ~isempty(excurLog) )
                                        baseline = baseLo; %#ok<NASGU>
                                        dev = devLo;            %#ok<NASGU> - used in sprintf statement

                                        cmd = sprintf('save %s excurLog siteName siteNum network baseline dev outLimNumber inLimNumber inLimInARow', fileExcurMatLog);
                                        eval(cmd);
                                        display(sprintf('Low Excursions logged to file: %s', fileExcurMatLog ))
                                    end
                                catch
                                    display('Failed to save excursion .mat log')
                                    display(sprintf('.mat log file hi: %s',fileExcurMatLog))
                                    display('BAD_WRITE')
                                    success = -1;
                                    return
                                end
                            end % if( logExcurMAT )
                        end % for iInLim = inLimLos
                    end % for iOutLim = outLimLos
                end % for iDev = 1:size(devLos,1)
                
                % If we got here, all excursion files have been saved, notify
                if( saveExcursions )
                    if( allExcurSaved )
                        display(['Low Excursions updated for day: ' datestr(id-1,'yyyy-mm-dd')])
                        display(['Low Excursions saved for day: ' datestr(id,'yyyy-mm-dd')])
                    else
                        display(sprintf('WARNING: Not all low excursions saved for days %s - %s',datestr(id-1,'yyyy-mm-dd'),datestr(id,'yyyy-mm-dd')))
                    end
                end
            end % if( ~excurLoOff )
            
            % Update dataPast, limitsPast
            dataPastExist = true;
            dataPast = dataCurr;
        else
            display(sprintf('Data not found for date: %s',datestr(id,'yyyy/mm/dd')))
            display('Skipping day')
            dataPastExist = false;
        end % if( exist(fbDataCurr,'file') )
    end % for ind = 1:nd
end % for iSID = siteIDs

% All excursions have been logged to text file
% Use Clark's perl script to log to database
% QFDC/streams/CalMagNet/addFBevents.plx
if( logExcurDB )
    startDBTime = now;
    [status, cmdResult] = system( [procDir,'/addFBEvents.plx ',outFile] );
    endDBTime = now;
    deltaDB = (endDBTime - startDBTime)*86400;
    if( cmdResult ~= 0 )
        allExcurLogged = false;
        display( ['Problem with ',procDir,'/addFBEvents.plx ',outFile] )
        display( sprintf('Site: %s - %s, Last Date: %s',isiteName,isiteStr,datestr(edPST,'yyyymmdd')) )
        display( 'Failed to enter excursion into database table "daily_FB_excursions"' )
    else
        display('Excursions entered into database table "daily_FB_excursions"')
        display(sprintf('DB Entry Time: %d',deltaDB))
    end
    
    % Remove Temporary Excursion Log File
    if( ~debugMode )
        [status, cmdResult] = system( ['rm ' outFile] );
        if( status ~= 0 )
            display(['Error Removing File: ' outFile] );
            display(cmdResult);
            display('Remove manually')
        else
            display('Temporary Excursion Log File successfully removed')
        end
    end
end % if( logExcurDB )

% Turn on variable not found warning
warning on MATLAB:load:variableNotFound

fend = now;
delta = (fend - fstart)*86400;
display(sprintf('Function: %s Start Time: %d',funcname,fstart))
display(sprintf('Function: %s End Time: %d',funcname,fend))
display(sprintf('Function: %s Run Time: %d',funcname,delta))
display(sprintf('Function: %s END',funcname))

if( ~logExcurDB || allExcurLogged )
    display('SUCCESS')
    success = 0;
else
    success = -1;
    display('ERROR: Not all excursions logged into DB')
    display('BAD_WRITE')
end
return
