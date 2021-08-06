function success = genFBExcursionStats(startDate,endDate,network,siteIDs,bands,channels,varargin)
% function success = genFBExcursionStats(startDate,endDate,network,siteIDs,bands,channels,varargin)
%
% This function determines excursion statistics.
%
% =========================================================================
% =========================================================================
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
%       'excurHiOff' - do not check for hi excursions
%       'excurLoOff' - do not check for lo excursions
%       'calcExcurs' - do not check if excursion .mat file exists
%       'plotStats' - create plots for stats
%       'viewPlots' - view created plots
%       'plotEQ' - view EQs of interest on plots
%       'logplotEng' - view Energy plot as logplot
%       'debugMode' - display number of excursions to screen for debugging
%       'removeExclusions' - remove excursions from contamintated data
%           times in stats calculation
%
% =========================================================================
% =========================================================================
% 

funcname = 'genFBExcursionStats.m';
display(sprintf('Function: %s START',funcname))
fstart = now;

% =========================================================================
% =========================================================================
% Constants
NBANDS = 13;
NCH = 4;
NEXCUR = 3;
NSTATS = 3;
exTotal = 1;    % Excursion Types
exHigh = 2;
exLow = 3;
sNum = 1;    % Stats
sDur = 2;
sEng = 3;

% Output (to file) column descriptions
% Replace with column descriptions of excursion data
statsDescription = { ...
      ' dimensions: time, bands, channels, excursion type, stats' ;
      '   1 - time: day, week, month number' ;
      '   2 - interval start, interval end, bands: 1-13, 14?' ;
      '   3 - channels: 1-4' ;
      '   4 - excursion type: Total, High, Low' ;
      '   5 - stats: number, avg duration (points), avg energy (pT*points)' }; %#ok<NASGU> - used in save cmd

% Process arguments
MINARGS = 6;
optargs = size(varargin,2);
stdargs = nargin - optargs;
if( stdargs < MINARGS )
    success = false;
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
    % sdUTC = sdPST + 8/24;                 % convert from PST to UTC
    % edUTC = edPST + 8/24;                 % convert from PST to UTC
    % sT = datestr(startDate,'yyyymmdd');
    % eT = datestr(endDate,'yyyymmdd');
catch
    success = false;
    display('Cannot interpret start and end dates')
    display('USAGE')
    return
end
display(sprintf('Date Range: %s - %s',startDate,endDate))

% Weeks
id = sdPST;
while( ~strcmpi( datestr(id,'ddd'), 'Sun' ) )
    id = id - 1;
end
wsd = id;                   % Current week start date
wed = id + 7;               % Current week end date
iw = 1;                     % Current week number
nw = ceil( (edPST-wsd)/7 ); % Number of weeks

% Months
[syr,smo] = datevec( sdPST );
[eyr,emo] = datevec( edPST );
msd = datenum( sprintf('%04d/%02d/01',syr,smo), 'yyyy/mm/dd' ); % Current month start date
im = 1;                             % Current month number
cmo = smo;                          % Current month
nm = (eyr-syr)*12 + emo - smo + 1;  % Number of months

% Network
NETWORKS = {'BK' 'BKQ' 'CMN'};
network = upper(network);
if( isempty( find( strcmpi( NETWORKS, network ),1 ) ) )
    success = false;
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
% sitesStr = instr;
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
calcExcurs = false;
plotStats = false;
viewPlots = false;
plotEQ = false;
logplotEng = false;
debugMode = false;
removeExclusions = false;

k = 1;
while( k <= optargs )
    if( strcmpi(varargin{k}, 'baseHi') )
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
    elseif( strcmpi(varargin{k}, 'excurHiOff') )
        excurHiOff = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'excurLoOff') )
        excurLoOff = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'calcExcurs') )
        calcExcurs = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'plotStats') )
        plotStats = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'viewPlots') )
        viewPlots = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'plotEQ') )
        plotEQ = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'logplotEng') )
        logplotEng = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'debugMode') )
        debugMode = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'removeExclusions') )
        removeExclusions = true;
        display(sprintf('%s option active',varargin{k}))
    else
        display(sprintf('Optional argument %s cannot be interpreted. Argument is ignored.', varargin{k}))
    end
    
    k = k + 1;
end
display(' ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% CAN ONLY HANDLE ONE VALUE FOR OUTLIM & INLIM, DEV
outLimHi = outLimHis(1);
inLimHi = inLimHis(1);
outLimLo = outLimLos(1);
inLimLo = inLimLos(1);
devHi = devHis(1);
devLo = devLos(1);

% Clear Input Argument display variables
clear instr* j*

% =========================================================================
% =========================================================================
display(' ')
display('FUNCTION BODY:')

% % Determine if warnings should be kept on
% if( warningsOn )
%     warning on all
% else
%     warning off all
% end

% Load environment variables
[fbDir,fbStatDir,kpTxtFileName,kpMatFileName,fbExcurDir] = fbLoadExcurEnv(network);
if( strcmpi(fbDir,'ERROR') )
    display('Problem loading environment variables')
    display('ENVIRONMENT')
    success = false;
    return
end

% Excursion Log Directory
dirExcurMatLogHi = sprintf('%s/excursionLogs/%s/Hi',fbExcurDir,baseHi);
dirExcurMatLogLo = sprintf('%s/excursionLogs/%s/Lo',fbExcurDir,baseLo);

% Excursion Stats Directory
dirExcurStats = sprintf('%s/excursionStats',fbExcurDir);
success = verifyEnvironment(dirExcurStats);
if( ~success )
    display('Error creating Excursion Stats directories');
    display('ENVIRONMENT');
    success = false;
    return
end

% Calculate Excursions?
if( calcExcurs )
    try
        cmd = sprintf('success = genFBExcursionDaily(startDate,endDate,network,siteIDs,bands,channels');
        cmd = sprintf('%s,''baseHi'',baseHi,''baseLo'',baseLo,''devHi'',devHi,''devLo'',devLo',cmd);
        cmd = sprintf('%s,''outLimHi'',outLimHi,''outLimLo'',outLimLo,''inLimHi'',inLimHi,''inLimLo'',inLimLo',cmd);
        if( inLimRowHi ), cmd = sprintf('%s,''inLimRowHi''',cmd); end
        if( inLimRowLo ), cmd = sprintf('%s,''inLimRowLo''',cmd); end
        if( removeExclusions ), cmd = sprintf('%s,''removeExclusions''',cmd); end
        cmd = sprintf('%s,''loadLimits'',''saveLimits'',''loadExcursions'',''saveExcursions'',''logExcurMAT'',''clearOverlapDBOff'');',cmd);
        display('Calculating Excursions:')
        display(cmd)
        eval(cmd)
    catch
        display('Error calculating excursions!')
        success = false;
        return
    end
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
        else
            display('Error getting exclusion times. Exclusions will not be removed.')
            exclusions = [ ]; %#ok<NASGU>
        end
    catch
        display('Error getting exclusion times. Exclusions will not be removed.')
        exclusions = [ ]; %#ok<NASGU>
    end
end

for iSID = siteIDs
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
        
    % Initialize stats variables
    statsDay = NaN(nd,NBANDS+2,NCH,NEXCUR,NSTATS);
    statsWeek = NaN(nw,NBANDS+2,NCH,NEXCUR,NSTATS);
    statsMonth = NaN(nm,NBANDS+2,NCH,NEXCUR,NSTATS);
    statsRun7 = NaN(nd,NBANDS+2,NCH,NEXCUR,NSTATS); % stats for last 7 days
    statsRun30 = NaN(nd,NBANDS+2,NCH,NEXCUR,NSTATS); % stats for last 30 days
    
    % Initialize tally variables
    tallyDay = NaN(1,NBANDS+2,NCH,NEXCUR,NSTATS);
    tallyDay(:,1,:,:,:) = sdPST;
    tallyDay(:,2,:,:,:) = sdPST;
    tallyWeek = NaN(1,NBANDS+2,NCH,NEXCUR,NSTATS);
    tallyWeek(:,1,:,:,:) = wsd;
    tallyWeek(:,2,:,:,:) = wed;
    tallyMonth = NaN(1,NBANDS+2,NCH,NEXCUR,NSTATS);
    tallyMonth(:,1,:,:,:) = msd;
    tallyRun7 = NaN(7,NBANDS+2,NCH,NEXCUR,NSTATS);
    tallyRun30 = NaN(30,NBANDS+2,NCH,NEXCUR,NSTATS);
    
    % Excursion .mat log file station directory
    tmpExcurMatLogHi = sprintf( '%s/%s', ...
        dirExcurMatLogHi,isiteFN );
    tmpExcurMatLogLo = sprintf( '%s/%s', ...
        dirExcurMatLogLo,isiteFN );
    
    % Data Vector Filenames
    % Work in dev, inLim, outLim for filenames?
    fileExcurStats = sprintf('%s/excurStats.%s%s.mat',dirExcurStats,network,isiteStr);
    
    % Load data vectors for appending?
    
    % Iterate over each day
    for ind=1:nd
        % Figure out current day
        id = sdPST + ind - 1;
        iDate = datestr(id,'yyyy/mm/dd'); 
        if( ind > 1 )
            % RECORD DAY DATA
            for iband = bands
                for ich = channels
                    tallyDay(:,iband+2,ich,exHigh,sDur) = tallyDay(:,iband+2,ich,exHigh,sDur) / tallyDay(:,iband+2,ich,exHigh,sNum);
                    tallyDay(:,iband+2,ich,exLow,sDur) = tallyDay(:,iband+2,ich,exLow,sDur) / tallyDay(:,iband+2,ich,exLow,sNum);
                    tallyDay(:,iband+2,ich,exTotal,sDur) = tallyDay(:,iband+2,ich,exTotal,sDur) / tallyDay(:,iband+2,ich,exTotal,sNum);
                    tallyDay(:,iband+2,ich,exHigh,sEng) = tallyDay(:,iband+2,ich,exHigh,sEng) / tallyDay(:,iband+2,ich,exHigh,sNum);
                    tallyDay(:,iband+2,ich,exLow,sEng) = tallyDay(:,iband+2,ich,exLow,sEng) / tallyDay(:,iband+2,ich,exLow,sNum);
                    tallyDay(:,iband+2,ich,exTotal,sEng) = tallyDay(:,iband+2,ich,exTotal,sEng) / tallyDay(:,iband+2,ich,exTotal,sNum);
                end
            end
            statsDay(ind-1,:,:,:,:) = tallyDay;
            % RESET DAY DATA TALLY
            tallyDay = NaN(1,NBANDS+2,NCH,NEXCUR,NSTATS);
            tallyDay(:,1,:,:,:) = id;
            tallyDay(:,2,:,:,:) = id;
        end
        
        % Figure out current week
        dow = id - wsd + 1;     % Day of week
        if( dow > 7 )
            % RECORD WEEK DATA
            for iband = bands
                for ich = channels
                    tallyWeek(:,iband+2,ich,exHigh,sDur) = tallyWeek(:,iband+2,ich,exHigh,sDur) / tallyWeek(:,iband+2,ich,exHigh,sNum);
                    tallyWeek(:,iband+2,ich,exLow,sDur) = tallyWeek(:,iband+2,ich,exLow,sDur) / tallyWeek(:,iband+2,ich,exLow,sNum);
                    tallyWeek(:,iband+2,ich,exTotal,sDur) = tallyWeek(:,iband+2,ich,exTotal,sDur) / tallyWeek(:,iband+2,ich,exTotal,sNum);
                    tallyWeek(:,iband+2,ich,exHigh,sEng) = tallyWeek(:,iband+2,ich,exHigh,sEng) / tallyWeek(:,iband+2,ich,exHigh,sNum);
                    tallyWeek(:,iband+2,ich,exLow,sEng) = tallyWeek(:,iband+2,ich,exLow,sEng) / tallyWeek(:,iband+2,ich,exLow,sNum);
                    tallyWeek(:,iband+2,ich,exTotal,sEng) = tallyWeek(:,iband+2,ich,exTotal,sEng) / tallyWeek(:,iband+2,ich,exTotal,sNum);
                end
            end
            statsWeek(iw,:,:,:,:) = tallyWeek;
            % RESET WEEK DATA TALLY
            iw = iw + 1;        % Week number
            wsd = id;           % Week start date
            wed = id + 7;       % Week end date
            dow = id - wsd + 1; % Day of week
            tallyWeek = NaN(1,NBANDS+2,NCH,NEXCUR,NSTATS);
            tallyWeek(:,1,:,:,:) = wsd;
            tallyWeek(:,2,:,:,:) = wed;
        end
        
        % Figure out current month
        [iyr,imo,dom] = datevec(id);
        if( imo ~= cmo )
            med = id - 1;   % Month end date
            % RECORD MONTH DATA
            tallyMonth(:,2,:,:,:) = med;
            for iband = bands
                for ich = channels
                    tallyMonth(:,iband+2,ich,exHigh,sDur) = tallyMonth(:,iband+2,ich,exHigh,sDur) / tallyMonth(:,iband+2,ich,exHigh,sNum);
                    tallyMonth(:,iband+2,ich,exLow,sDur) = tallyMonth(:,iband+2,ich,exLow,sDur) / tallyMonth(:,iband+2,ich,exLow,sNum);
                    tallyMonth(:,iband+2,ich,exTotal,sDur) = tallyMonth(:,iband+2,ich,exTotal,sDur) / tallyMonth(:,iband+2,ich,exTotal,sNum);
                    tallyMonth(:,iband+2,ich,exHigh,sEng) = tallyMonth(:,iband+2,ich,exHigh,sEng) / tallyMonth(:,iband+2,ich,exHigh,sNum);
                    tallyMonth(:,iband+2,ich,exLow,sEng) = tallyMonth(:,iband+2,ich,exLow,sEng) / tallyMonth(:,iband+2,ich,exLow,sNum);
                    tallyMonth(:,iband+2,ich,exTotal,sEng) = tallyMonth(:,iband+2,ich,exTotal,sEng) / tallyMonth(:,iband+2,ich,exTotal,sNum);
                end
            end
            statsMonth(im,:,:,:,:) = tallyMonth;
            % RESET MONTH DATA TALLY
            msd = id;       % Month start date
            cmo = imo;      % Current month
            im = im + 1;    % Current month number
            tallyMonth = NaN(1,NBANDS+2,NCH,NEXCUR,NSTATS);
            tallyMonth(:,1,:,:,:) = msd;
        end
        
        % Figure out last 7 days
        ced7 = id;
        csd7 = id - 7;
        if( csd7 < sdPST ), csd7 = sdPST; end
        if( ind > 1 )
            % RECORD 7 DAY DATA
            for iband = bands
                for ich = channels
                    for iex = 1:NEXCUR
                        currTallyNum = tallyRun7(:,iband+2,ich,iex,sNum);
                        totalNum = sum( currTallyNum( ~isnan(currTallyNum) ) );
                        currTallyDur = tallyRun7(:,iband+2,ich,iex,sDur);
                        totalDur = sum( currTallyDur( ~isnan(currTallyDur) ) );
                        currTallyEng = tallyRun7(:,iband+2,ich,iex,sEng);
                        totalEng = sum( currTallyEng( ~isnan(currTallyEng) ) );
                        
                        statsRun7(ind-1,iband+2,ich,iex,sNum) = totalNum;
                        statsRun7(ind-1,iband+2,ich,iex,sDur) = totalDur/totalNum;
                        statsRun7(ind-1,iband+2,ich,iex,sEng) = totalEng/totalNum;
                    end
                end
            end
            % RESET 7 DAY DATA TALLY
            for ich = 1:NCH
                for iex = 1:NEXCUR
                    for ist = 1:NSTATS
                        tallyRun7(:,:,ich,iex,ist) = [ NaN(1,NBANDS+2); tallyRun7(1:end-1,:,ich,iex,ist) ];
                    end
                end
            end
            tallyRun7(1,1,:,:,:) = csd7;
            tallyRun7(1,2,:,:,:) = ced7;
        end
        statsRun7(ind,1,:,:,:) = csd7;
        statsRun7(ind,2,:,:,:) = ced7;
        
        % Figure out last 30 days
        ced30 = id;
        csd30 = id - 30;
        if( csd30 < sdPST ), csd30 = sdPST; end
        if( ind > 1 )
            % RECORD 30 DAY DATA
            for iband = bands
                for ich = channels
                    for iex = 1:NEXCUR
                        currTallyNum = tallyRun30(:,iband+2,ich,iex,sNum);
                        totalNum = sum( currTallyNum( ~isnan(currTallyNum) ) );
                        currTallyDur = tallyRun30(:,iband+2,ich,iex,sDur);
                        totalDur = sum( currTallyDur( ~isnan(currTallyDur) ) );
                        currTallyEng = tallyRun30(:,iband+2,ich,iex,sEng);
                        totalEng = sum( currTallyEng( ~isnan(currTallyEng) ) );
                        
                        statsRun30(ind-1,iband+2,ich,iex,sNum) = totalNum;
                        statsRun30(ind-1,iband+2,ich,iex,sDur) = totalDur/totalNum;
                        statsRun30(ind-1,iband+2,ich,iex,sEng) = totalEng/totalNum;
                    end
                end
            end
            % RESET 30 DAY DATA TALLY
            for ich = 1:NCH
                for iex = 1:NEXCUR
                    for ist = 1:NSTATS
                        tallyRun30(:,:,ich,iex,ist) = [ NaN(1,NBANDS+2); tallyRun30(1:end-1,:,ich,iex,ist) ];
                    end
                end
            end
            tallyRun30(1,1,:,:,:) = csd30;
            tallyRun30(1,2,:,:,:) = ced30;
        end
        statsRun30(ind,1,:,:,:) = csd30;
        statsRun30(ind,2,:,:,:) = ced30;
        
        % Display current day, week, month
        display(sprintf('Day Number %d of %d, Date: %s',ind,nd,iDate))
        display(sprintf('Day %d of Week Number %d of %d, Week Start Date: %s',dow,iw,nw,datestr(wsd,'yyyy/mm/dd')))
        display(sprintf('Day %d of Month Number %d of %d, Month Start Date: %s',dom,im,nm,datestr(msd,'yyyy/mm/dd')))
        
        % Check if data exists for current day - loop over channels
        dataExist = false;
        for ichannel = checkCh
            fbDataCurr = sprintf( '%s/%s/CHANNEL%d/%s.%s.%s.%02d.fb',...
                fbDir,isiteFN,ichannel,datestr(id,'yyyymmdd'),network,isiteStr,ichannel);
            
            if( exist(fbDataCurr,'file') )
                dataExist = true;
            end
        end % for ichannel = checkCh
        
        % Is there data for current day?
        if( dataExist )
            display(sprintf('Data exists for date: %s',iDate))
            
            % High Limits and Excursions
            if( ~excurHiOff )
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
                    success = false;
                    display(sprintf('Invalid High baseline input argument: %s',baseHi))
                    display('USAGE')
                    return
                end
                display(sprintf('High Limit Definition: Baseline - %s, Deviation - %d',baseHi,devHi))
                
                % Create Excursion .mat log files
                % Make sure it works with BK network!!!
                if( strcmpi( baseHi, 'mean' ) )
                    if( devHi < 0 )
                        fileExcurMatHi = sprintf( '%s/%s.%s.%s.fblog.n%02d.hi.%02d%02d%d.mat', ...
                            tmpExcurMatLogHi,datestr(id,'yyyymmdd'),network,isiteStr,-devHi,outLimHi,inLimHi,inLimRowHi );
                    else
                        fileExcurMatHi = sprintf( '%s/%s.%s.%s.fblog.p%02d.hi.%02d%02d%d.mat', ...
                            tmpExcurMatLogHi,datestr(id,'yyyymmdd'),network,isiteStr,devHi,outLimHi,inLimHi,inLimRowHi );
                    end
                else
                    fileExcurMatHi = sprintf( '%s/%s.%s.%s.fblog.%03d.hi.%02d%02d%d.mat', ...
                        tmpExcurMatLogHi,datestr(id,'yyyymmdd'),network,isiteStr,devHi,outLimHi,inLimHi,inLimRowHi );
                end
                
                % Does .MAT file exist?
                if( exist(fileExcurMatHi,'file') )
                    try
                        cmd = sprintf('load %s excurLog',fileExcurMatHi);
                        eval( cmd )
                    catch
                        try
                            cmd = sprintf('success = genFBExcursionDaily(iDate,iDate,network,siteIDs,bands,channels');
                            cmd = sprintf('%s,''excurLoOff'',''baseHi'',baseHi,''devHi'',devHi',cmd);
                            cmd = sprintf('%s,''outLimHi'',outLimHi,''inLimHi'',inLimHi',cmd);
                            if( inLimRowHi ), cmd = sprintf('%s,''inLimRowHi''',cmd); end
                            if( removeExclusions ), cmd = sprintf('%s,''removeExclusions''',cmd); end
                            cmd = sprintf('%s,''loadLimits'',''saveLimits'',''loadExcursions'',''saveExcursions'',''logExcurMAT'',''clearOverlapDBOff'');',cmd);
                            display(sprintf('Calculating High Excursions for day %s:',iDate))
                            display(cmd)
                            eval(cmd)
                            cmd = sprintf('load %s excurLog',fileExcurMatHi);
                            eval( cmd )
                        catch
                            display('Error Calculating High Excursions for day')
                            excurLog = NaN;
                        end
                    end
                else
                    try
                        cmd = sprintf('success = genFBExcursionDaily(iDate,iDate,network,siteIDs,bands,channels');
                        cmd = sprintf('%s,''excurLoOff'',''baseHi'',baseHi,''devHi'',devHi',cmd);
                        cmd = sprintf('%s,''outLimHi'',outLimHi,''inLimHi'',inLimHi',cmd);
                        if( inLimRowHi ), cmd = sprintf('%s,''inLimRowHi''',cmd); end
                        if( removeExclusions ), cmd = sprintf('%s,''removeExclusions''',cmd); end
                        cmd = sprintf('%s,''loadLimits'',''saveLimits'',''loadExcursions'',''saveExcursions'',''logExcurMAT'',''clearOverlapDBOff'');',cmd);
                        display(sprintf('Calculating High Excursions for day %s:',iDate))
                        display(cmd)
                        eval(cmd)
                        cmd = sprintf('load %s excurLog',fileExcurMatHi);
                        eval( cmd )
                    catch
                        display('Error Calculating High Excursions for day')
                        excurLog = NaN;
                    end
                end % if( exist(fileExcurMatHi,'file') )
                
                % Update tallyDay, tallyWeek, tallyMonth
                if( isnan(excurLog) )
                    for iband = bands
                        for ich = channels
                            % Day Tally
                            tallyDay(:,iband+2,ich,exHigh,sNum) = NaN;
                            tallyDay(:,iband+2,ich,exTotal,sNum) = tallyDay(:,iband+2,ich,exTotal,sNum) + 0;
                            tallyDay(:,iband+2,ich,exHigh,sDur) = NaN;
                            tallyDay(:,iband+2,ich,exTotal,sDur) = tallyDay(:,iband+2,ich,exTotal,sDur) + 0;
                            tallyDay(:,iband+2,ich,exHigh,sEng) = NaN;
                            tallyDay(:,iband+2,ich,exTotal,sEng) = tallyDay(:,iband+2,ich,exTotal,sEng) + 0;
                            % Week Tally
                            tallyWeek(:,iband+2,ich,exHigh,sNum) = tallyWeek(:,iband+2,ich,exHigh,sNum) + 0;
                            tallyWeek(:,iband+2,ich,exTotal,sNum) = tallyWeek(:,iband+2,ich,exTotal,sNum) + 0;
                            tallyWeek(:,iband+2,ich,exHigh,sDur) = tallyWeek(:,iband+2,ich,exHigh,sDur) + 0;
                            tallyWeek(:,iband+2,ich,exTotal,sDur) = tallyWeek(:,iband+2,ich,exTotal,sDur) + 0;
                            tallyWeek(:,iband+2,ich,exHigh,sEng) = tallyWeek(:,iband+2,ich,exHigh,sEng) + 0;
                            tallyWeek(:,iband+2,ich,exTotal,sEng) = tallyWeek(:,iband+2,ich,exTotal,sEng) + 0;
                            % Month Tally
                            tallyMonth(:,iband+2,ich,exHigh,sNum) = tallyMonth(:,iband+2,ich,exHigh,sNum) + 0;
                            tallyMonth(:,iband+2,ich,exTotal,sNum) = tallyMonth(:,iband+2,ich,exTotal,sNum) + 0;
                            tallyMonth(:,iband+2,ich,exHigh,sDur) = tallyMonth(:,iband+2,ich,exHigh,sDur) + 0;
                            tallyMonth(:,iband+2,ich,exTotal,sDur) = tallyMonth(:,iband+2,ich,exTotal,sDur) + 0;
                            tallyMonth(:,iband+2,ich,exHigh,sEng) = tallyMonth(:,iband+2,ich,exHigh,sEng) + 0;
                            tallyMonth(:,iband+2,ich,exTotal,sEng) = tallyMonth(:,iband+2,ich,exTotal,sEng) + 0;
                            % Run7 Tally
                            tallyRun7(1,iband+2,ich,exHigh,sNum) = NaN;
                            tallyRun7(1,iband+2,ich,exTotal,sNum) = tallyRun7(1,iband+2,ich,exTotal,sNum) + 0;
                            tallyRun7(1,iband+2,ich,exHigh,sDur) = NaN;
                            tallyRun7(1,iband+2,ich,exTotal,sDur) = tallyRun7(1,iband+2,ich,exTotal,sDur) + 0;
                            tallyRun7(1,iband+2,ich,exHigh,sEng) = NaN;
                            tallyRun7(1,iband+2,ich,exTotal,sEng) = tallyRun7(1,iband+2,ich,exTotal,sEng) + 0;
                            % Run30 Tally
                            tallyRun30(1,iband+2,ich,exHigh,sNum) = NaN;
                            tallyRun30(1,iband+2,ich,exTotal,sNum) = tallyRun30(1,iband+2,ich,exTotal,sNum) + 0;
                            tallyRun30(1,iband+2,ich,exHigh,sDur) = NaN;
                            tallyRun30(1,iband+2,ich,exTotal,sDur) = tallyRun30(1,iband+2,ich,exTotal,sDur) + 0;
                            tallyRun30(1,iband+2,ich,exHigh,sEng) = NaN;
                            tallyRun30(1,iband+2,ich,exTotal,sEng) = tallyRun30(1,iband+2,ich,exTotal,sEng) + 0;
                        end % for ich = channels
                    end % for iband = bands
                else
%                     % Remove exclusion times from excursions
%                     if( removeExclusions )
%                         siteExcl = (exclusions(:,3) == isite);
%                         dayExcl = (exclusions(:,1) >= id) & (exclusions(:,2) < (id + 1));
%                         chExcl = (exclusions(:,4) <= 4);
%                         relExcl = exclusions( siteExcl & dayExcl & chExcl, : );
%                         for iexcl = 1:size(relExcl,1)
%                             currExcl = relExcl(iexcl,:);
%                             for iexcur = 1:size(excurLog,1)
%                                 currExcur = excurLog(iexcur,:);
%                                 % same channel?
%                                 if( currExcl(:,4) == currExcur(:,5) )
%                                     % remove excursion if overlapping exclusion
%                                     eST = currExcur(:,1);
%                                     eET = currExcur(:,2);
%                                     fST = currExcl(:,1);
%                                     fET = currExcl(:,2);
%                                     if( ((eST >= fST) || (eET >= fST)) && ((eST <= fET) || (eET <= fET)) )
%                                         excurLog(iexcur,5) = NaN;
%                                     end
%                                 end
%                             end % for iexcur = 1:size(excurLog,1)
%                         end % for iexcl = 1:size(relExcl,1)
%                     end % if( removeExclusions )
                    
                    for iband = bands
                        for ich = channels
                            relExcurs = excurLog( (excurLog(:,4) == iband & excurLog(:,5) == ich) , : );
                            if( debugMode )
                                display(sprintf('High Excursions - Band: %d, Channel: %d, Number: %d',iband,ich,size(relExcurs,1)));
                            end
                            % Day Tally
                            tallyDay(:,iband+2,ich,exHigh,sNum) = size(relExcurs,1);
                            if( isnan(tallyDay(:,iband+2,ich,exTotal,sNum)) )
                                tallyDay(:,iband+2,ich,exTotal,sNum) = size(relExcurs,1);
                            else
                                tallyDay(:,iband+2,ich,exTotal,sNum) = tallyDay(:,iband+2,ich,exTotal,sNum) + size(relExcurs,1);
                            end
                            tallyDay(:,iband+2,ich,exHigh,sDur) = sum(relExcurs(:,6));
                            if( isnan(tallyDay(:,iband+2,ich,exTotal,sDur)) )
                                tallyDay(:,iband+2,ich,exTotal,sDur) = sum(relExcurs(:,6));
                            else
                                tallyDay(:,iband+2,ich,exTotal,sDur) = tallyDay(:,iband+2,ich,exTotal,sDur) + sum(relExcurs(:,6));
                            end
                            tallyDay(:,iband+2,ich,exHigh,sEng) = sum(relExcurs(:,9));
                            if( isnan(tallyDay(:,iband+2,ich,exTotal,sEng)) )
                                tallyDay(:,iband+2,ich,exTotal,sEng) = sum(relExcurs(:,9));
                            else
                                tallyDay(:,iband+2,ich,exTotal,sEng) = tallyDay(:,iband+2,ich,exTotal,sEng) + sum(relExcurs(:,9));
                            end
                            % Week Tally
                            if( isnan(tallyWeek(:,iband+2,ich,exHigh,sNum)) )
                                tallyWeek(:,iband+2,ich,exHigh,sNum) = size(relExcurs,1);
                            else
                                tallyWeek(:,iband+2,ich,exHigh,sNum) = tallyWeek(:,iband+2,ich,exHigh,sNum) + size(relExcurs,1);
                            end
                            if( isnan(tallyWeek(:,iband+2,ich,exTotal,sNum)) )
                                tallyWeek(:,iband+2,ich,exTotal,sNum) = size(relExcurs,1);
                            else
                                tallyWeek(:,iband+2,ich,exTotal,sNum) = tallyWeek(:,iband+2,ich,exTotal,sNum) + size(relExcurs,1);
                            end
                            if( isnan(tallyWeek(:,iband+2,ich,exHigh,sDur)) )
                                tallyWeek(:,iband+2,ich,exHigh,sDur) = sum(relExcurs(:,6));
                            else
                                tallyWeek(:,iband+2,ich,exHigh,sDur) = tallyWeek(:,iband+2,ich,exHigh,sDur) + sum(relExcurs(:,6));
                            end
                            if( isnan(tallyWeek(:,iband+2,ich,exTotal,sDur)) )
                                tallyWeek(:,iband+2,ich,exTotal,sDur) = sum(relExcurs(:,6));
                            else
                                tallyWeek(:,iband+2,ich,exTotal,sDur) = tallyWeek(:,iband+2,ich,exTotal,sDur) + sum(relExcurs(:,6));
                            end
                            if( isnan(tallyWeek(:,iband+2,ich,exHigh,sEng)) )
                                tallyWeek(:,iband+2,ich,exHigh,sEng) = sum(relExcurs(:,9));
                            else
                                tallyWeek(:,iband+2,ich,exHigh,sEng) = tallyWeek(:,iband+2,ich,exHigh,sEng) + sum(relExcurs(:,9));
                            end
                            if( isnan(tallyWeek(:,iband+2,ich,exTotal,sEng)) )
                                tallyWeek(:,iband+2,ich,exTotal,sEng) = sum(relExcurs(:,9));
                            else
                                tallyWeek(:,iband+2,ich,exTotal,sEng) = tallyWeek(:,iband+2,ich,exTotal,sEng) + sum(relExcurs(:,9));
                            end
                            % Month Tally
                            if( isnan(tallyMonth(:,iband+2,ich,exHigh,sNum)) )
                                tallyMonth(:,iband+2,ich,exHigh,sNum) = size(relExcurs,1);
                            else
                                tallyMonth(:,iband+2,ich,exHigh,sNum) = tallyMonth(:,iband+2,ich,exHigh,sNum) + size(relExcurs,1);
                            end
                            if( isnan(tallyMonth(:,iband+2,ich,exTotal,sNum)) )
                                tallyMonth(:,iband+2,ich,exTotal,sNum) = size(relExcurs,1);
                            else
                                tallyMonth(:,iband+2,ich,exTotal,sNum) = tallyMonth(:,iband+2,ich,exTotal,sNum) + size(relExcurs,1);
                            end
                            if( isnan(tallyMonth(:,iband+2,ich,exHigh,sDur)) )
                                tallyMonth(:,iband+2,ich,exHigh,sDur) = sum(relExcurs(:,6));
                            else
                                tallyMonth(:,iband+2,ich,exHigh,sDur) = tallyMonth(:,iband+2,ich,exHigh,sDur) + sum(relExcurs(:,6));
                            end
                            if( isnan(tallyMonth(:,iband+2,ich,exTotal,sDur)) )
                                tallyMonth(:,iband+2,ich,exTotal,sDur) = sum(relExcurs(:,6));
                            else
                                tallyMonth(:,iband+2,ich,exTotal,sDur) = tallyMonth(:,iband+2,ich,exTotal,sDur) + sum(relExcurs(:,6));
                            end
                            if( isnan(tallyMonth(:,iband+2,ich,exHigh,sEng)) )
                                tallyMonth(:,iband+2,ich,exHigh,sEng) = sum(relExcurs(:,9));
                            else
                                tallyMonth(:,iband+2,ich,exHigh,sEng) = tallyMonth(:,iband+2,ich,exHigh,sEng) + sum(relExcurs(:,9));
                            end
                            if( isnan(tallyMonth(:,iband+2,ich,exTotal,sEng)) )
                                tallyMonth(:,iband+2,ich,exTotal,sEng) = sum(relExcurs(:,9));
                            else
                                tallyMonth(:,iband+2,ich,exTotal,sEng) = tallyMonth(:,iband+2,ich,exTotal,sEng) + sum(relExcurs(:,9));
                            end
                            % Run7 Tally
                            tallyRun7(1,iband+2,ich,exHigh,sNum) = size(relExcurs,1);
                            if( isnan(tallyRun7(1,iband+2,ich,exTotal,sNum)) )
                                tallyRun7(1,iband+2,ich,exTotal,sNum) = size(relExcurs,1);
                            else
                                tallyRun7(1,iband+2,ich,exTotal,sNum) = tallyRun7(1,iband+2,ich,exTotal,sNum) + size(relExcurs,1);
                            end
                            tallyRun7(1,iband+2,ich,exHigh,sDur) = sum(relExcurs(:,6));
                            if( isnan(tallyRun7(1,iband+2,ich,exTotal,sDur)) )
                                tallyRun7(1,iband+2,ich,exTotal,sDur) = sum(relExcurs(:,6));
                            else
                                tallyRun7(1,iband+2,ich,exTotal,sDur) = tallyRun7(1,iband+2,ich,exTotal,sDur) + sum(relExcurs(:,6));
                            end
                            tallyRun7(1,iband+2,ich,exHigh,sEng) = sum(relExcurs(:,9));
                            if( isnan(tallyRun7(1,iband+2,ich,exTotal,sEng)) )
                                tallyRun7(1,iband+2,ich,exTotal,sEng) = sum(relExcurs(:,9));
                            else
                                tallyRun7(1,iband+2,ich,exTotal,sEng) = tallyRun7(1,iband+2,ich,exTotal,sEng) + sum(relExcurs(:,9));
                            end
                            % Run30 Tally
                            tallyRun30(1,iband+2,ich,exHigh,sNum) = size(relExcurs,1);
                            if( isnan(tallyRun30(1,iband+2,ich,exTotal,sNum)) )
                                tallyRun30(1,iband+2,ich,exTotal,sNum) = size(relExcurs,1);
                            else
                                tallyRun30(1,iband+2,ich,exTotal,sNum) = tallyRun30(1,iband+2,ich,exTotal,sNum) + size(relExcurs,1);
                            end
                            tallyRun30(1,iband+2,ich,exHigh,sDur) = sum(relExcurs(:,6));
                            if( isnan(tallyRun30(1,iband+2,ich,exTotal,sDur)) )
                                tallyRun30(1,iband+2,ich,exTotal,sDur) = sum(relExcurs(:,6));
                            else
                                tallyRun30(1,iband+2,ich,exTotal,sDur) = tallyRun30(1,iband+2,ich,exTotal,sDur) + sum(relExcurs(:,6));
                            end
                            tallyRun30(1,iband+2,ich,exHigh,sEng) = sum(relExcurs(:,9));
                            if( isnan(tallyRun30(1,iband+2,ich,exTotal,sEng)) )
                                tallyRun30(1,iband+2,ich,exTotal,sEng) = sum(relExcurs(:,9));
                            else
                                tallyRun30(1,iband+2,ich,exTotal,sEng) = tallyRun30(1,iband+2,ich,exTotal,sEng) + sum(relExcurs(:,9));
                            end
                        end % for ich = channels
                    end % for iband = bands
                end % if( isnan(excurLog) )
            end % if( ~excurHiOff )
            
            % Low Limits and Excursions
            if( ~excurLoOff )
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
                    success = false;
                    display(sprintf('Invalid Low baseline input argument: %s',baseLo))
                    display('USAGE')
                    return
                end
                display(sprintf('Low Limit Definition: Baseline - %s, Deviation - %d',baseLo,devLo))
                
                % Create Excursion .mat log files
                % Make sure it works with BK network!!!
                if( strcmpi( baseLo, 'mean' ) )
                    if( devLo <= 0 )
                        fileExcurMatLo = sprintf( '%s/%s.%s.%s.fblog.p%02d.lo.%02d%02d%d.mat', ...
                            tmpExcurMatLogLo,datestr(id,'yyyymmdd'),network,isiteStr,-devLo,outLimLo,inLimLo,inLimRowLo );
                    else
                        fileExcurMatLo = sprintf( '%s/%s.%s.%s.fblog.n%02d.lo.%02d%02d%d.mat', ...
                            tmpExcurMatLogLo,datestr(id,'yyyymmdd'),network,isiteStr,devLo,outLimLo,inLimLo,inLimRowLo );
                    end
                else
                    fileExcurMatLo = sprintf( '%s/%s.%s.%s.fblog.%03d.lo.%02d%02d%d.mat', ...
                        tmpExcurMatLogLo,datestr(id,'yyyymmdd'),network,isiteStr,devLo,outLimLo,inLimLo,inLimRowLo );
                end
                
                % Does .MAT file exist?
                if( exist(fileExcurMatLo,'file') )
                    try
                        cmd = sprintf('load %s excurLog',fileExcurMatLo);
                        eval( cmd )
                    catch
                        try
                            cmd = sprintf('success = genFBExcursionDaily(iDate,iDate,network,siteIDs,bands,channels');
                            cmd = sprintf('%s,''excurHiOff'',''baseLo'',baseLo,''devLo'',devLo',cmd);
                            cmd = sprintf('%s,''outLimLo'',outLimLo,''inLimLo'',inLimLo',cmd);
                            if( inLimRowLo ), cmd = sprintf('%s,''inLimRowLo''',cmd); end
                            if( removeExclusions ), cmd = sprintf('%s,''removeExclusions''',cmd); end
                            cmd = sprintf('%s,''loadLimits'',''saveLimits'',''loadExcursions'',''saveExcursions'',''logExcurMAT'',''clearOverlapDBOff'');',cmd);
                            display(sprintf('Calculating Low Excursions for day %s:',iDate))
                            display(cmd)
                            eval(cmd)
                            cmd = sprintf('load %s excurLog',fileExcurMatLo);
                            eval( cmd )
                        catch
                            display('Error Calculating Low Excursions for day')
                            excurLog = NaN;
                        end
                    end
                else
                    try
                        cmd = sprintf('success = genFBExcursionDaily(iDate,iDate,network,siteIDs,bands,channels');
                        cmd = sprintf('%s,''excurHiOff'',''baseLo'',baseLo,''devLo'',devLo',cmd);
                        cmd = sprintf('%s,''outLimLo'',outLimLo,''inLimLo'',inLimLo',cmd);
                        if( inLimRowLo ), cmd = sprintf('%s,''inLimRowLo''',cmd); end
                        if( removeExclusions ), cmd = sprintf('%s,''removeExclusions''',cmd); end
                        cmd = sprintf('%s,''loadLimits'',''saveLimits'',''loadExcursions'',''saveExcursions'',''logExcurMAT'',''clearOverlapDBOff'');',cmd);
                        display(sprintf('Calculating Low Excursions for day %s:',iDate))
                        display(cmd)
                        eval(cmd)
                        cmd = sprintf('load %s excurLog',fileExcurMatLo);
                        eval( cmd )
                    catch
                        display('Error Calculating Low Excursions for day')
                        excurLog = NaN;
                    end
                end % if( exist(fileExcurMatLo,'file') )
                
                % Update tallyDay, tallyWeek, tallyMonth
                if( isnan(excurLog) )
                    for iband = bands
                        for ich = channels
                            % Day Tally
                            tallyDay(:,iband+2,ich,exLow,sNum) = NaN;
                            tallyDay(:,iband+2,ich,exTotal,sNum) = tallyDay(:,iband+2,ich,exTotal,sNum) + 0;
                            tallyDay(:,iband+2,ich,exLow,sDur) = NaN;
                            tallyDay(:,iband+2,ich,exTotal,sDur) = tallyDay(:,iband+2,ich,exTotal,sDur) + 0;
                            tallyDay(:,iband+2,ich,exLow,sEng) = NaN;
                            tallyDay(:,iband+2,ich,exTotal,sEng) = tallyDay(:,iband+2,ich,exTotal,sEng) + 0;
                            % Week Tally
                            tallyWeek(:,iband+2,ich,exLow,sNum) = tallyWeek(:,iband+2,ich,exLow,sNum) + 0;
                            tallyWeek(:,iband+2,ich,exTotal,sNum) = tallyWeek(:,iband+2,ich,exTotal,sNum) + 0;
                            tallyWeek(:,iband+2,ich,exLow,sDur) = tallyWeek(:,iband+2,ich,exLow,sDur) + 0;
                            tallyWeek(:,iband+2,ich,exTotal,sDur) = tallyWeek(:,iband+2,ich,exTotal,sDur) + 0;
                            tallyWeek(:,iband+2,ich,exLow,sEng) = tallyWeek(:,iband+2,ich,exLow,sEng) + 0;
                            tallyWeek(:,iband+2,ich,exTotal,sEng) = tallyWeek(:,iband+2,ich,exTotal,sEng) + 0;
                            % Month Tally
                            tallyMonth(:,iband+2,ich,exLow,sNum) = tallyMonth(:,iband+2,ich,exLow,sNum) + 0;
                            tallyMonth(:,iband+2,ich,exTotal,sNum) = tallyMonth(:,iband+2,ich,exTotal,sNum) + 0;
                            tallyMonth(:,iband+2,ich,exLow,sDur) = tallyMonth(:,iband+2,ich,exLow,sDur) + 0;
                            tallyMonth(:,iband+2,ich,exTotal,sDur) = tallyMonth(:,iband+2,ich,exTotal,sDur) + 0;
                            tallyMonth(:,iband+2,ich,exLow,sEng) = tallyMonth(:,iband+2,ich,exLow,sEng) + 0;
                            tallyMonth(:,iband+2,ich,exTotal,sEng) = tallyMonth(:,iband+2,ich,exTotal,sEng) + 0;
                            % Run7 Tally
                            tallyRun7(1,iband+2,ich,exLow,sNum) = NaN;
                            tallyRun7(1,iband+2,ich,exTotal,sNum) = tallyRun7(1,iband+2,ich,exTotal,sNum) + 0;
                            tallyRun7(1,iband+2,ich,exLow,sDur) = NaN;
                            tallyRun7(1,iband+2,ich,exTotal,sDur) = tallyRun7(1,iband+2,ich,exTotal,sDur) + 0;
                            tallyRun7(1,iband+2,ich,exLow,sEng) = NaN;
                            tallyRun7(1,iband+2,ich,exTotal,sEng) = tallyRun7(1,iband+2,ich,exTotal,sEng) + 0;
                            % Run30 Tally
                            tallyRun30(1,iband+2,ich,exLow,sNum) = NaN;
                            tallyRun30(1,iband+2,ich,exTotal,sNum) = tallyRun30(1,iband+2,ich,exTotal,sNum) + 0;
                            tallyRun30(1,iband+2,ich,exLow,sDur) = NaN;
                            tallyRun30(1,iband+2,ich,exTotal,sDur) = tallyRun30(1,iband+2,ich,exTotal,sDur) + 0;
                            tallyRun30(1,iband+2,ich,exLow,sEng) = NaN;
                            tallyRun30(1,iband+2,ich,exTotal,sEng) = tallyRun30(1,iband+2,ich,exTotal,sEng) + 0;
                        end % for ich = channels
                    end % for iband = bands
                else
%                     % Remove exclusion times from excursions
%                     if( removeExclusions )
%                         siteExcl = (exclusions(:,3) == isite);
%                         dayExcl = (exclusions(:,1) >= id) & (exclusions(:,2) < (id + 1));
%                         chExcl = (exclusions(:,4) <= 4);
%                         relExcl = exclusions( siteExcl & dayExcl & chExcl, : );
%                         for iexcl = 1:size(relExcl,1)
%                             currExcl = relExcl(iexcl,:);
%                             for iexcur = 1:size(excurLog,1)
%                                 currExcur = excurLog(iexcur,:);
%                                 % same channel?
%                                 if( currExcl(:,4) == currExcur(:,5) )
%                                     % remove excursion if overlapping exclusion
%                                     eST = currExcur(:,1);
%                                     eET = currExcur(:,2);
%                                     fST = currExcl(:,1);
%                                     fET = currExcl(:,2);
%                                     if( ((eST >= fST) || (eET >= fST)) && ((eST <= fET) || (eET <= fET)) )
%                                         excurLog(iexcur,5) = NaN;
%                                     end
%                                 end
%                             end % for iexcur = 1:size(excurLog,1)
%                         end % for iexcl = 1:size(relExcl,1)
%                     end % if( removeExclusions )
                    
                    for iband = bands
                        for ich = channels
                            relExcurs = excurLog( (excurLog(:,4) == iband & excurLog(:,5) == ich) , : );
                            if( debugMode )
                                display(sprintf('Low Excursions - Band: %d, Channel: %d, Number: %d',iband,ich,size(relExcurs,1)));
                            end
                            % Day Tally
                            tallyDay(:,iband+2,ich,exLow,sNum) = size(relExcurs,1);
                            if( isnan(tallyDay(:,iband+2,ich,exTotal,sNum)) )
                                tallyDay(:,iband+2,ich,exTotal,sNum) = size(relExcurs,1);
                            else
                                tallyDay(:,iband+2,ich,exTotal,sNum) = tallyDay(:,iband+2,ich,exTotal,sNum) + size(relExcurs,1);
                            end
                            tallyDay(:,iband+2,ich,exLow,sDur) = sum(relExcurs(:,6));
                            if( isnan(tallyDay(:,iband+2,ich,exTotal,sDur)) )
                                tallyDay(:,iband+2,ich,exTotal,sDur) = sum(relExcurs(:,6));
                            else
                                tallyDay(:,iband+2,ich,exTotal,sDur) = tallyDay(:,iband+2,ich,exTotal,sDur) + sum(relExcurs(:,6));
                            end
                            tallyDay(:,iband+2,ich,exLow,sEng) = sum(relExcurs(:,9));
                            if( isnan(tallyDay(:,iband+2,ich,exTotal,sEng)) )
                                tallyDay(:,iband+2,ich,exTotal,sEng) = sum(relExcurs(:,9));
                            else
                                tallyDay(:,iband+2,ich,exTotal,sEng) = tallyDay(:,iband+2,ich,exTotal,sEng) + sum(relExcurs(:,9));
                            end
                            % Week Tally
                            if( isnan(tallyWeek(:,iband+2,ich,exLow,sNum)) )
                                tallyWeek(:,iband+2,ich,exLow,sNum) = size(relExcurs,1);
                            else
                                tallyWeek(:,iband+2,ich,exLow,sNum) = tallyWeek(:,iband+2,ich,exLow,sNum) + size(relExcurs,1);
                            end
                            if( isnan(tallyWeek(:,iband+2,ich,exTotal,sNum)) )
                                tallyWeek(:,iband+2,ich,exTotal,sNum) = size(relExcurs,1);
                            else
                                tallyWeek(:,iband+2,ich,exTotal,sNum) = tallyWeek(:,iband+2,ich,exTotal,sNum) + size(relExcurs,1);
                            end
                            if( isnan(tallyWeek(:,iband+2,ich,exLow,sDur)) )
                                tallyWeek(:,iband+2,ich,exLow,sDur) = sum(relExcurs(:,6));
                            else
                                tallyWeek(:,iband+2,ich,exLow,sDur) = tallyWeek(:,iband+2,ich,exLow,sDur) + sum(relExcurs(:,6));
                            end
                            if( isnan(tallyWeek(:,iband+2,ich,exTotal,sDur)) )
                                tallyWeek(:,iband+2,ich,exTotal,sDur) = sum(relExcurs(:,6));
                            else
                                tallyWeek(:,iband+2,ich,exTotal,sDur) = tallyWeek(:,iband+2,ich,exTotal,sDur) + sum(relExcurs(:,6));
                            end
                            if( isnan(tallyWeek(:,iband+2,ich,exLow,sEng)) )
                                tallyWeek(:,iband+2,ich,exLow,sEng) = sum(relExcurs(:,9));
                            else
                                tallyWeek(:,iband+2,ich,exLow,sEng) = tallyWeek(:,iband+2,ich,exLow,sEng) + sum(relExcurs(:,9));
                            end
                            if( isnan(tallyWeek(:,iband+2,ich,exTotal,sEng)) )
                                tallyWeek(:,iband+2,ich,exTotal,sEng) = sum(relExcurs(:,9));
                            else
                                tallyWeek(:,iband+2,ich,exTotal,sEng) = tallyWeek(:,iband+2,ich,exTotal,sEng) + sum(relExcurs(:,9));
                            end
                            % Month Tally
                            if( isnan(tallyMonth(:,iband+2,ich,exLow,sNum)) )
                                tallyMonth(:,iband+2,ich,exLow,sNum) = size(relExcurs,1);
                            else
                                tallyMonth(:,iband+2,ich,exLow,sNum) = tallyMonth(:,iband+2,ich,exLow,sNum) + size(relExcurs,1);
                            end
                            if( isnan(tallyMonth(:,iband+2,ich,exTotal,sNum)) )
                                tallyMonth(:,iband+2,ich,exTotal,sNum) = size(relExcurs,1);
                            else
                                tallyMonth(:,iband+2,ich,exTotal,sNum) = tallyMonth(:,iband+2,ich,exTotal,sNum) + size(relExcurs,1);
                            end
                            if( isnan(tallyMonth(:,iband+2,ich,exLow,sDur)) )
                                tallyMonth(:,iband+2,ich,exLow,sDur) = sum(relExcurs(:,6));
                            else
                                tallyMonth(:,iband+2,ich,exLow,sDur) = tallyMonth(:,iband+2,ich,exLow,sDur) + sum(relExcurs(:,6));
                            end
                            if( isnan(tallyMonth(:,iband+2,ich,exTotal,sDur)) )
                                tallyMonth(:,iband+2,ich,exTotal,sDur) = sum(relExcurs(:,6));
                            else
                                tallyMonth(:,iband+2,ich,exTotal,sDur) = tallyMonth(:,iband+2,ich,exTotal,sDur) + sum(relExcurs(:,6));
                            end
                            if( isnan(tallyMonth(:,iband+2,ich,exLow,sEng)) )
                                tallyMonth(:,iband+2,ich,exLow,sEng) = sum(relExcurs(:,9));
                            else
                                tallyMonth(:,iband+2,ich,exLow,sEng) = tallyMonth(:,iband+2,ich,exLow,sEng) + sum(relExcurs(:,9));
                            end
                            if( isnan(tallyMonth(:,iband+2,ich,exTotal,sEng)) )
                                tallyMonth(:,iband+2,ich,exTotal,sEng) = sum(relExcurs(:,9));
                            else
                                tallyMonth(:,iband+2,ich,exTotal,sEng) = tallyMonth(:,iband+2,ich,exTotal,sEng) + sum(relExcurs(:,9));
                            end
                            % Run7 Tally
                            tallyRun7(1,iband+2,ich,exLow,sNum) = size(relExcurs,1);
                            if( isnan(tallyRun7(1,iband+2,ich,exTotal,sNum)) )
                                tallyRun7(1,iband+2,ich,exTotal,sNum) = size(relExcurs,1);
                            else
                                tallyRun7(1,iband+2,ich,exTotal,sNum) = tallyRun7(1,iband+2,ich,exTotal,sNum) + size(relExcurs,1);
                            end
                            tallyRun7(1,iband+2,ich,exLow,sDur) = sum(relExcurs(:,6));
                            if( isnan(tallyRun7(1,iband+2,ich,exTotal,sDur)) )
                                tallyRun7(1,iband+2,ich,exTotal,sDur) = sum(relExcurs(:,6));
                            else
                                tallyRun7(1,iband+2,ich,exTotal,sDur) = tallyRun7(1,iband+2,ich,exTotal,sDur) + sum(relExcurs(:,6));
                            end
                            tallyRun7(1,iband+2,ich,exLow,sEng) = sum(relExcurs(:,9));
                            if( isnan(tallyRun7(1,iband+2,ich,exTotal,sEng)) )
                                tallyRun7(1,iband+2,ich,exTotal,sEng) = sum(relExcurs(:,9));
                            else
                                tallyRun7(1,iband+2,ich,exTotal,sEng) = tallyRun7(1,iband+2,ich,exTotal,sEng) + sum(relExcurs(:,9));
                            end
                            % Run30 Tally
                            tallyRun30(1,iband+2,ich,exLow,sNum) = size(relExcurs,1);
                            if( isnan(tallyRun30(1,iband+2,ich,exTotal,sNum)) )
                                tallyRun30(1,iband+2,ich,exTotal,sNum) = size(relExcurs,1);
                            else
                                tallyRun30(1,iband+2,ich,exTotal,sNum) = tallyRun30(1,iband+2,ich,exTotal,sNum) + size(relExcurs,1);
                            end
                            tallyRun30(1,iband+2,ich,exLow,sDur) = sum(relExcurs(:,6));
                            if( isnan(tallyRun30(1,iband+2,ich,exTotal,sDur)) )
                                tallyRun30(1,iband+2,ich,exTotal,sDur) = sum(relExcurs(:,6));
                            else
                                tallyRun30(1,iband+2,ich,exTotal,sDur) = tallyRun30(1,iband+2,ich,exTotal,sDur) + sum(relExcurs(:,6));
                            end
                            tallyRun30(1,iband+2,ich,exLow,sEng) = sum(relExcurs(:,9));
                            if( isnan(tallyRun30(1,iband+2,ich,exTotal,sEng)) )
                                tallyRun30(1,iband+2,ich,exTotal,sEng) = sum(relExcurs(:,9));
                            else
                                tallyRun30(1,iband+2,ich,exTotal,sEng) = tallyRun30(1,iband+2,ich,exTotal,sEng) + sum(relExcurs(:,9));
                            end
                        end % for ich = channels
                    end % for iband = bands
                end % if( isnan(excurLog) )
            end % if( ~excurLoOff )
        end % if( dataExist )
    end % for ind = 1:nd
    
    % Final stats
    % RECORD DAY DATA
    for iband = bands
        for ich = channels
            tallyDay(:,iband+2,ich,exHigh,sDur) = tallyDay(:,iband+2,ich,exHigh,sDur) / tallyDay(:,iband+2,ich,exHigh,sNum);
            tallyDay(:,iband+2,ich,exLow,sDur) = tallyDay(:,iband+2,ich,exLow,sDur) / tallyDay(:,iband+2,ich,exLow,sNum);
            tallyDay(:,iband+2,ich,exTotal,sDur) = tallyDay(:,iband+2,ich,exTotal,sDur) / tallyDay(:,iband+2,ich,exTotal,sNum);
            tallyDay(:,iband+2,ich,exHigh,sEng) = tallyDay(:,iband+2,ich,exHigh,sEng) / tallyDay(:,iband+2,ich,exHigh,sNum);
            tallyDay(:,iband+2,ich,exLow,sEng) = tallyDay(:,iband+2,ich,exLow,sEng) / tallyDay(:,iband+2,ich,exLow,sNum);
            tallyDay(:,iband+2,ich,exTotal,sEng) = tallyDay(:,iband+2,ich,exTotal,sEng) / tallyDay(:,iband+2,ich,exTotal,sNum);
        end
    end
    statsDay(nd,:,:,:,:) = tallyDay; %#ok<NASGU> - saved to file
    
    % RECORD WEEK DATA
    wed = edPST;
    tallyWeek(:,2,:,:,:) = wed;
    for iband = bands
        for ich = channels
            tallyWeek(:,iband+2,ich,exHigh,sDur) = tallyWeek(:,iband+2,ich,exHigh,sDur) / tallyWeek(:,iband+2,ich,exHigh,sNum);
            tallyWeek(:,iband+2,ich,exLow,sDur) = tallyWeek(:,iband+2,ich,exLow,sDur) / tallyWeek(:,iband+2,ich,exLow,sNum);
            tallyWeek(:,iband+2,ich,exTotal,sDur) = tallyWeek(:,iband+2,ich,exTotal,sDur) / tallyWeek(:,iband+2,ich,exTotal,sNum);
            tallyWeek(:,iband+2,ich,exHigh,sEng) = tallyWeek(:,iband+2,ich,exHigh,sEng) / tallyWeek(:,iband+2,ich,exHigh,sNum);
            tallyWeek(:,iband+2,ich,exLow,sEng) = tallyWeek(:,iband+2,ich,exLow,sEng) / tallyWeek(:,iband+2,ich,exLow,sNum);
            tallyWeek(:,iband+2,ich,exTotal,sEng) = tallyWeek(:,iband+2,ich,exTotal,sEng) / tallyWeek(:,iband+2,ich,exTotal,sNum);
        end
    end
    statsWeek(nw,:,:,:,:) = tallyWeek; %#ok<NASGU> - saved to file
    
    % RECORD MONTH DATA
    med = edPST;   % Month end date
    tallyMonth(:,2,:,:,:) = med;
    for iband = bands
        for ich = channels
            tallyMonth(:,iband+2,ich,exHigh,sDur) = tallyMonth(:,iband+2,ich,exHigh,sDur) / tallyMonth(:,iband+2,ich,exHigh,sNum);
            tallyMonth(:,iband+2,ich,exLow,sDur) = tallyMonth(:,iband+2,ich,exLow,sDur) / tallyMonth(:,iband+2,ich,exLow,sNum);
            tallyMonth(:,iband+2,ich,exTotal,sDur) = tallyMonth(:,iband+2,ich,exTotal,sDur) / tallyMonth(:,iband+2,ich,exTotal,sNum);
            tallyMonth(:,iband+2,ich,exHigh,sEng) = tallyMonth(:,iband+2,ich,exHigh,sEng) / tallyMonth(:,iband+2,ich,exHigh,sNum);
            tallyMonth(:,iband+2,ich,exLow,sEng) = tallyMonth(:,iband+2,ich,exLow,sEng) / tallyMonth(:,iband+2,ich,exLow,sNum);
            tallyMonth(:,iband+2,ich,exTotal,sEng) = tallyMonth(:,iband+2,ich,exTotal,sEng) / tallyMonth(:,iband+2,ich,exTotal,sNum);
        end
    end
    statsMonth(nm,:,:,:,:) = tallyMonth; %#ok<NASGU> - saved to file
    
    % RECORD 7 DAY DATA
    for iband = bands
        for ich = channels
            for iex = 1:NEXCUR
                currTallyNum = tallyRun7(:,iband+2,ich,iex,sNum);
                totalNum = sum( currTallyNum( ~isnan(currTallyNum) ) );
                currTallyDur = tallyRun7(:,iband+2,ich,iex,sDur);
                totalDur = sum( currTallyDur( ~isnan(currTallyDur) ) );
                currTallyEng = tallyRun7(:,iband+2,ich,iex,sEng);
                totalEng = sum( currTallyEng( ~isnan(currTallyEng) ) );

                statsRun7(nd,iband+2,ich,iex,sNum) = totalNum;
                statsRun7(nd,iband+2,ich,iex,sDur) = totalDur/totalNum;
                statsRun7(nd,iband+2,ich,iex,sEng) = totalEng/totalNum;
            end
        end
    end

    % RECORD 30 DAY DATA
    for iband = bands
        for ich = channels
            for iex = 1:NEXCUR
                currTallyNum = tallyRun30(:,iband+2,ich,iex,sNum);
                totalNum = sum( currTallyNum( ~isnan(currTallyNum) ) );
                currTallyDur = tallyRun30(:,iband+2,ich,iex,sDur);
                totalDur = sum( currTallyDur( ~isnan(currTallyDur) ) );
                currTallyEng = tallyRun30(:,iband+2,ich,iex,sEng);
                totalEng = sum( currTallyEng( ~isnan(currTallyEng) ) );

                statsRun30(nd,iband+2,ich,iex,sNum) = totalNum;
                statsRun30(nd,iband+2,ich,iex,sDur) = totalDur/totalNum;
                statsRun30(nd,iband+2,ich,iex,sEng) = totalEng/totalNum;
            end
        end
    end

    % save vectors to file
    try
        % WATCH OUT FOR LOSING DATA IF EXCUR HI/LO ARE OFF!!!
        cmd = sprintf('save %s statsDay statsWeek statsMonth statsRun7 statsRun30 statsDescription baseHi baseLo inLimHi inLimLo devHi devLo removeExclusions',fileExcurStats);
        eval(cmd)
        display(sprintf('Stats saved to file: %s',fileExcurStats))
    catch
        display(sprintf('Error saving stats for site %s',isiteStr))
    end
    
    % plot vectors as appropriate
    if( plotStats )
        success = plotFBExcurStats('all',network,isite,viewPlots,plotEQ,logplotEng);
        if( ~success )
            display(sprintf('Error creating plots for %s%s',network,isiteStr))
        end
    end
    
    % mark EQs on plots?
    
end % for iSID = siteIDs


fend = now;
delta = (fend - fstart)*86400;
display(sprintf('Function: %s Start Time: %d',funcname,fstart))
display(sprintf('Function: %s End Time: %d',funcname,fend))
display(sprintf('Function: %s Run Time: %d',funcname,delta))
display(sprintf('Function: %s END',funcname))

success = true;
return
