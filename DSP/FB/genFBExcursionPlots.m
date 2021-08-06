function success = genFBExcursionPlots(startDate,endDate,network,sites,bands,channels,varargin)
% function success = genFBExcursionPlots(startDate,endDate,network,sites,bands,channels,varargin)
%
% This function creates plots for the date range given. For each day, FB
% data, limits, and excursions are loaded and plotted. A new plot is
% created for each day, site, and band specified. Each channel is on a new
% subplot.
%
% =========================================================================
% =========================================================================
% Required Input Arguments:
%   startDate - Start Date as string 'yyyy/mm/dd' in PST
%   endDate - End Date as string 'yyyy/mm/dd' in PST
%   network - 'CMN','BK', or 'BKQ' - only works with 'CMN' for now
%   sites - station numbers of 'CMN' stations; names for other networks
%   channels - [1:4] - channels to look for excursions on
%   bands - [1:13] - bands to look for excursions on
% 
% Optional Input Arguments:
%   Limits: separate for High and Low
%       *NOTE: The below arguments are required if limits are to be 
%           plotted. High and Low limits are defined separately. If no
%           argument is specified, the limits are not plotted.
%       Baseline - 'baseHi', 'baseLo'
%           Choices: 'mean' or 'median'
%           Usage: genFBExcursionDaily(...,'baseHi','median',...)
%       Deviations - 'devLo', 'devHi'
%           Values: scalar value of deviation that gives percentile for
%               baseline 'median' or number of standard deviations for
%               baseline 'mean'.
%           Usage: genFBExcursionDaily(...,'devLo',25,...)
%   Excursions: separate for High and Low
%       *NOTE: The below arguments are required if excursions are not
%           turned off ('excurHiOff','excurLoOff'). The default values are
%           outLimHi [1], outLimLo [1], inLimHi [1], inLimLo [1], and
%           inLimRow 'off' for hi and lo if the values are not specified.
%       OutLimNumbers - 'outLimHi', 'outLimLo'
%           Values: scalar that determine the number
%               of points in a row that must be out of limits for an
%               excursion to occur.
%           Usage: genFBExcursionDaily(...,'outLimLo',6,...)
%       InLimNumbers - 'inLimHi', 'inLimLo'
%           Values: scalar that determine the number
%               of total points that must be within limits for an
%               excursion to end.
%           Usage: genFBExcursionDaily(...,'inLimHi',3,...)
%       InLimRow - 'inLimRowHi', 'inLimRowLo'
%           Values: string that specifies that the InLimNumbers must occur
%               in a row in order to end an excursion.
%           Usage: genFBExcursionDaily(...,'inLimRowHi',...)
% 
% Additional Optional Input Arguments:
%   NOTE: All optional input arguments are input as strings and correspond 
%   to a boolean in the script below. An input argument that is one of the 
%   below optional arguments will enable the description associated with 
%   the argument and set the boolean to true.
%
%   viewPlots - allow figures to be displayed - use for debugging
%   excurHiOff - do not plot hi excursions
%   excurLoOff - do not plot lo excursions
%   plotDayZero - create plot for day before start date (day 0)
%   smoothData - load smoothed data
% 
% NOTE: The excurHiOff and excurLoOff options are not functional yet!!!
% Need to change the way excursion points are loaded in these cases!
% 
% TO ADD/CHANGE:
% high and low excursions should be loaded from separate files. Do not put
% them in one file in genFBExcursionDaily.m - THIS NEEDS TO BE FIXED IN
% THAT FUNCTION! Input arguments need to be specified for
% outLimNumber/inLimNumber and inLimInARow for both high and low
% excursions. The variables need to be independent so that high and low
% excursions can have different values.
% =========================================================================
% =========================================================================
%

funcname = 'genFBExcursionPlots.m';
display(sprintf('Function: %s START',funcname))
fstart = now;

% =========================================================================
% =========================================================================

% Turn off negative data ignored warning
warning off MATLAB:Axes:NegativeDataInLogAxis

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
    % sdUTC = sdPST + 8/24;                 % convert from PST to UTC
    % edUTC = edPST + 8/24;                 % convert from PST to UTC
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
    display([ 'Unknown network: ' network ] );
    display('USAGE')
    return
end
display(sprintf('Network: %s',network))

% Sites
instr = '';
for jsite = sites
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

% Bands
instr = '';
for jband = bands
    instr = sprintf('%s%d ',instr,jband);
end
display(sprintf('Bands: %s',instr))

% Channels
numCh = size(channels,2); % used to size plots
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
baseHi = 'off';
baseLo = 'off';
devHi = NaN;
devLo = NaN;
viewPlots = false;
outLimHi = 1;
outLimLo = 1;
inLimHi = 1;
inLimLo = 1;
inLimRowHi = false;
inLimRowLo = false;
excurHiOff = false;
excurLoOff = false;
smoothData = false;
isd = 1;

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
            devHi = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'devLo') )
        if( isnumeric( varargin{k+1} ) )
            devLo = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'outLimHi') )
        if( isnumeric( varargin{k+1} ) )
            outLimHi = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'outLimLo') )
        if( isnumeric( varargin{k+1} ) )
            outLimLo = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'inLimHi') )
        if( isnumeric( varargin{k+1} ) )
            inLimHi = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'inLimLo') )
        if( isnumeric( varargin{k+1} ) )
            inLimLo = varargin{k+1};
            display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
            k = k + 1;
        end
    elseif( strcmpi(varargin{k}, 'inLimRowHi') )
        inLimRowHi = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'inLimRowLo') )
        inLimRowLo = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'viewPlots') )
        viewPlots = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'excurHiOff') )
        excurHiOff = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'excurLoOff') )
        excurLoOff = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'plotDayZero') )
        isd = 0;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'smoothData') )
        smoothData = true;
        display(sprintf('%s option active',varargin{k}))
    else
        display(sprintf('Optional argument %s cannot be interpreted. Argument is ignored.', varargin{k}))
    end
    
    k = k + 1;
end
display(' ')

% High Limits
% Baseline
display(sprintf('High Limit Baseline: %s',baseHi))
% Deviations
display(sprintf('High Limit Deviations: %d',devHi))

% Low Limits
% Baseline
display(sprintf('Low Limit Baseline: %s',baseLo))
% Deviations
display(sprintf('Low Limit Deviations: %d',devLo))

% High Excursions
if( ~excurHiOff )
    display('High Excursions to be Plotted')
    display(sprintf('High Out of Limit Number: %d',outLimHi))
    display(sprintf('High In Limit Number: %d',inLimHi))
    display(sprintf('High In Limit In A Row: %d',inLimRowHi))
end

% Low Excursions
if( ~excurLoOff )
    display('Low Excursions to be Plotted')
    display(sprintf('Low Out of Limit Number: %d',outLimLo))
    display(sprintf('Low In Limit Number: %d',inLimLo))
    display(sprintf('Low In Limit In A Row: %d',inLimRowLo))
end

% Clear Input Argument display variables
clear instr* j*

% =========================================================================
% =========================================================================
display(' ')
display('FUNCTION BODY:')

% Success Check Variable
allPlots = true;

% Load environment variables
[fbDir,fbStatDir,kpTxtFileName,kpMatFileName,fbExcurDir,fbExcurPointsDir,fbExcurPlotDir,fbExcurLogDir,fbLimitDir,fbSmoothDir] = fbLoadExcurEnv(network);
if( strcmpi(fbDir,'ERROR') )
    display('Problem loading environment variables')
    display('ENVIRONMENT')
    success = -1;
    return
end
if( smoothData )
    rootDir = fbSmoothDir;
else
    rootDir = fbDir;
end

% Turn off Figure visibility?
if( ~viewPlots )
    set(0,'defaultFigureVisible','off')
    display('Default value for Figure Visible set to "off"')
end % if( ~viewPlots )

% Check Deviation Values
if( strcmpi(baseHi,'median') ) % make sure percentiles are integer values in range 0-100, devLo < devHi
    devHi = ceil(devHi);

    if( devHi < 0 )
        display('WARNING: Percentile given for high limit is less than zero. Setting to zero.')
        devHi = 0;
    elseif( devHi > 100 )
        display('WARNING: Percentile given for high limit is greater than 100. Setting to 100.')
        devHi = 100;
    end
elseif( strcmpi(baseHi,'mean') )
end
if( strcmpi(baseLo,'median') ) % make sure percentiles are integer values in range 0-100, devLo < devHi
    devLo = floor(devLo);

    if( devLo < 0 )
        display('WARNING: Percentile given for low limit is less than zero. Setting to zero.')
        devLo = 0;
    elseif( devLo > 100 )
        display('WARNING: Percentile given for low limit is greater than 100. Setting to 100.')
        devLo = 100;
    end
elseif( strcmpi(baseLo,'mean') )
end

% Iterate over all desired sites
for isite = sites
    if( iscell(isite) ) 
        isiteID = isite{:};
    else
        isiteID = isite;
    end
    
    if( ischar(isiteID) )
        isiteStr = isiteID;
    else
        isiteStr = sprintf('%d',isiteID);
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
        
    % Iterate over each day
    for ind=isd:nd
        id = sdPST + ind - 1;
        plotDelta = 0;
        saveDelta = 0;
        display(sprintf('Day Number %d of %d, Date: %s',ind,nd,datestr(id,'yyyy/mm/dd')))

        % Determine if data, limits, & excursions exist for day
        dataExist = false;
        limitExist = false;
        excurExist = false;
        
        % Data
        for ichannel = checkCh
            if( strcmpi(network,'CMN') )
                fbDataTest = sprintf( '%s/%s/CHANNEL%d/%s.%s.%s.%02d.fb',...
                    rootDir,isiteFN,ichannel,datestr(id,'yyyymmdd'),network,isiteStr,ichannel);
            else
                display(sprintf('Code needs to be updated to work with network: %s', network))
                display('USAGE')
                return
            end

            if( exist(fbDataTest,'file') )
                dataExist = true;
            end
        end % for ichannel = checkCh
        
        % Limits
        if( strcmpi(network,'CMN') )
            limitDir = [fbLimitDir sprintf('/%s',isiteFN)];
            if( ~strcmpi( baseHi, 'off' ) )
                limitDirHi = [limitDir sprintf('/%s',baseHi)];
            end
            if( ~strcmpi( baseLo, 'off' ) )
                limitDirLo = [limitDir sprintf('/%s',baseLo)];
            end
            
            if( strcmpi( baseHi, 'mean' ) )
                if( devHi < 0 )
                    limitFileHi = [limitDirHi ...
                        sprintf('/%s.%s.n%02d.fbl.mat',datestr(id,'yyyymmdd'),network,-devHi)];
                elseif( ~isnan(devHi) )
                    limitFileHi = [limitDirHi ...
                        sprintf('/%s.%s.p%02d.fbl.mat',datestr(id,'yyyymmdd'),network,devHi)];
                end
            elseif( strcmpi( baseHi, 'median' ) )
                limitFileHi = [limitDirHi ...
                    sprintf('/%s.%s.%03d.fbl.mat',datestr(id,'yyyymmdd'),network,devHi)];
            else
                limitFileHi = NaN;
            end

            if( strcmpi( baseLo, 'mean' ) )
                if( devLo <= 0 )
                    limitFileLo = [limitDirLo ...
                        sprintf('/%s.%s.p%02d.fbl.mat',datestr(id,'yyyymmdd'),network,-devLo)];
                elseif( ~isnan(devLo) )
                    limitFileLo = [limitDirLo ...
                        sprintf('/%s.%s.n%02d.fbl.mat',datestr(id,'yyyymmdd'),network,devLo)];
                end
            elseif( strcmpi( baseLo, 'median' ) )
                limitFileLo = [limitDirLo ...
                    sprintf('/%s.%s.%03d.fbl.mat',datestr(id,'yyyymmdd'),network,devLo)];
            else
                limitFileLo = NaN;
            end
        else
            display(sprintf('Code needs to be updated to work with network: %s', network))
            return
        end
        
        if( (strcmpi(baseHi,'off') || exist(limitFileHi,'file')) && (strcmpi(baseLo,'off') || exist(limitFileLo,'file')) )
            limitExist = true;
        end

        % Excursions
        siteDir = sprintf('%s/%s',fbExcurPointsDir,isiteFN);
        for iband = bands
            bandDir = sprintf('%s/FB%02d',siteDir,iband);
            for ichannel = channels
                chDir = sprintf('%s/CHANNEL%d',bandDir,ichannel);
                
                % Different File Names for Hi & Lo
                if( strcmpi(network,'CMN') )
                    if( strcmpi( baseHi, 'mean' ) )
                        if( devHi < 0 )
                            excurFileHi = [chDir ...
                                sprintf('/%s.%s.%s.%02d.%d.fbe.hi.n%02d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,-devHi)];
                        else
                            excurFileHi = [chDir ...
                                sprintf('/%s.%s.%s.%02d.%d.fbe.hi.p%02d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,devHi)];
                        end
                    elseif( strcmpi( baseHi, 'median' ) )
                        excurFileHi = [chDir ...
                            sprintf('/%s.%s.%s.%02d.%d.fbe.hi.%03d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,devHi)];
                    end
                    
                    if( strcmpi( baseLo, 'mean' ) )
                        if( devLo <= 0 )
                            excurFileLo = [chDir ...
                                sprintf('/%s.%s.%s.%02d.%d.fbe.lo.p%02d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,-devLo)];
                        else
                            excurFileLo = [chDir ...
                                sprintf('/%s.%s.%s.%02d.%d.fbe.lo.n%02d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,devLo)];
                        end
                    elseif( strcmpi( baseLo, 'median' ) )
                        excurFileLo = [chDir ...
                            sprintf('/%s.%s.%s.%02d.%d.fbe.lo.%03d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,devLo)];
                    end
                else
                    % MODIFY TO WORK WITH OTHER NETWORKS!!!
                end % if( strcmpi(network,'CMN') )
                
                if( (excurHiOff || exist(excurFileHi,'file')) && (excurLoOff || exist(excurFileLo,'file')) )
                    excurExist = true;
                end
            end
        end % for ichannel = channels

        % Is there data for current day?
        if( dataExist && limitExist && excurExist )
            display(sprintf('Data, Relevant Limits, and Excursions found for date: %s',datestr(id,'yyyy/mm/dd')))

            % Load data for current day
            try
                data = loadFBDataMB( id, id, network, isite, channels, bands, 0, smoothData);
            catch
                try
                    display(sprintf('Desired data could not be loaded - smoothData = %d',smoothData))
                    display(sprintf('Trying smoothData = %d',~smoothData))
                    data = loadFBDataMB( id, id, network, isite, channels, bands, 0, ~smoothData);
                catch
                    display(sprintf('Error: Data not loaded'))
                    success = -1;
                    return
                end
            end

            % Load .mat file for limits
            try
                if( strcmpi(baseHi,'off') )
                    limitHi = NaN(96,15,4);
                else
                    cmd = sprintf('load %s limit;', limitFileHi );
                    eval( cmd );
                    limitHi = limit;
                end
            catch
                display(['Error loading High limits for day: ' datestr(id,'yyyy-mm-dd')])
                display('BAD_LOAD')
                success = -1;
                return
            end

            try
                if( strcmpi(baseLo,'off') )
                    limitLo = NaN(96,15,4);
                else
                    cmd = sprintf('load %s limit;', limitFileLo );
                    eval( cmd );
                    limitLo = limit;
                end
            catch
                display(['Error loading Low limits for day: ' datestr(id,'yyyy-mm-dd')])
                display('BAD_LOAD')
                success = -1;
                return
            end

            % Load & Plot Excursions
            for iband = bands
                bandDir = sprintf('%s/FB%02d',siteDir,iband);
                % Get frequency range for band
                % Used to convert units to pT
                if( strcmpi( network, 'CMN' ) || strcmpi( network, 'BK' ) )
                    [freq1 freq2] = getUCBMAFreqs(iband);
                elseif( strcmp( network, 'BKQ' ) ),
                    [freq1 freq2] = getFBUpperFreqs(iband);
                end % if
                bw = freq2 - freq1;

                plotST = now;
                for ichannel = channels
                    chDir = sprintf('%s/CHANNEL%d',bandDir,ichannel);
                
                    % Generate File Names for excursion points
                    if( strcmpi(network,'CMN') )
                        if( strcmpi( baseHi, 'mean' ) )
                            if( devHi < 0 )
                                excurFileHi = [chDir ...
                                    sprintf('/%s.%s.%s.%02d.%d.fbe.hi.n%02d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,-devHi)];
                            else
                                excurFileHi = [chDir ...
                                    sprintf('/%s.%s.%s.%02d.%d.fbe.hi.p%02d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,devHi)];
                            end
                        elseif( strcmpi( baseHi, 'median' ) )
                            excurFileHi = [chDir ...
                                sprintf('/%s.%s.%s.%02d.%d.fbe.hi.%03d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,devHi)];
                        end

                        if( strcmpi( baseLo, 'mean' ) )
                            if( devLo <= 0 )
                                excurFileLo = [chDir ...
                                    sprintf('/%s.%s.%s.%02d.%d.fbe.lo.p%02d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,-devLo)];
                            else
                                excurFileLo = [chDir ...
                                    sprintf('/%s.%s.%s.%02d.%d.fbe.lo.n%02d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,devLo)];
                            end
                        elseif( strcmpi( baseLo, 'median' ) )
                            excurFileLo = [chDir ...
                                sprintf('/%s.%s.%s.%02d.%d.fbe.lo.%03d.mat',datestr(id,'yyyymmdd'),network,isiteStr,iband,ichannel,devLo)];
                        end
                    else
                        % MODIFY TO WORK WITH OTHER NETWORKS!!!
                    end % if( strcmpi(network,'CMN') )
                    
                    % Load .mat file for excursion points
                    try
                        if( excurHiOff )
                            excurPtsHi = NaN;
                        else
                            % cmd = sprintf('load %s excurPoints;', excurFileHi );
                            % eval( cmd );
                            % excurPtsHi = excurPoints;
                            cmd = sprintf('load %s excurPoints%02d%02d%02d;', ...
                                excurFileHi, outLimHi, inLimHi, inLimRowHi );
                            eval( cmd );
                            cmd = sprintf('excurPtsHi = excurPoints%02d%02d%02d;', ...
                                outLimHi, inLimHi, inLimRowHi );
                            eval( cmd );
                        end
                    catch
                        try
                            if( inLimRowHi ), inLimStr = 'inLimRowHi'; else inLimStr = 'dummyInput'; end
                            success = genFBExcursionDaily(iD,iD,network,isite,iband,ichannel, ...
                                'baseHi',baseHi,'devHi',devHi,'outLimHi',outLimHi,'inLimHi',inLimHi, inLimStr, ...
                                'excurLoOff','loadLimits','saveLimits','loadExcursions','saveExcursions','logExcurDB','removeExclusions');
                            if( success == 0 )
                                cmd = sprintf('load %s excurPoints%02d%02d%02d;', ...
                                    excurFileHi, outLimHi, inLimHi, inLimRowHi );
                                eval( cmd );
                                cmd = sprintf('excurPtsHi = excurPoints%02d%02d%02d;', ...
                                    outLimHi, inLimHi, inLimRowHi );
                                eval( cmd );
                            else
                                display(['Error loading high excursions for day: ' datestr(id,'yyyy-mm-dd') sprintf(' Band: %02d Channel: %02d',iband,ichannel)])
                                excurPtsHi = NaN;
                            end
                        catch
                            display(['Error loading high excursions for day: ' datestr(id,'yyyy-mm-dd') sprintf(' Band: %02d Channel: %02d',iband,ichannel)])
                            excurPtsHi = NaN;
                        end
                    end
                    
                    try
                        if( excurLoOff )
                            excurPtsLo = NaN;
                        else
                            % cmd = sprintf('load %s excurPoints;', excurFileLo );
                            % eval( cmd );
                            % excurPtsLo = excurPoints;
                            cmd = sprintf('load %s excurPoints%02d%02d%02d;', ...
                                excurFileLo, outLimLo, inLimLo, inLimRowLo );
                            eval( cmd );
                            cmd = sprintf('excurPtsLo = excurPoints%02d%02d%02d;', ...
                                outLimLo, inLimLo, inLimRowLo );
                            eval( cmd );
                        end
                    catch
                        try
                            if( inLimRowLo ), inLimStr = 'inLimRowLo'; else inLimStr = 'dummyInput'; end
                            success = genFBExcursionDaily(iD,iD,network,isite,iband,ichannel, ...
                                'baseLo',baseLo,'devLo',devLo,'outLimLo',outLimLo,'inLimLo',inLimLo, inLimStr, ...
                                'excurHiOff','loadLimits','saveLimits','loadExcursions','saveExcursions','logExcurDB','removeExclusions');
                            if( success == 0 )
                                cmd = sprintf('load %s excurPoints%02d%02d%02d;', ...
                                    excurFileLo, outLimLo, inLimLo, inLimRowLo );
                                eval( cmd );
                                cmd = sprintf('excurPtsLo = excurPoints%02d%02d%02d;', ...
                                    outLimLo, inLimLo, inLimRowLo );
                                eval( cmd );
                            else
                                display(['Error loading low excursions for day: ' datestr(id,'yyyy-mm-dd') sprintf(' Band: %02d Channel: %02d',iband,ichannel)])
                                excurPtsLo = NaN;
                            end
                        catch
                            display(['Error loading low excursions for day: ' datestr(id,'yyyy-mm-dd') sprintf(' Band: %02d Channel: %02d',iband,ichannel)])
                            excurPtsLo = NaN;
                        end
                    end
                    
                    % Convert data units to pT
                    if( ichannel ~= polCh )
                        data(:,iband+1,ichannel) = real(sqrt(data(:,iband+1,ichannel))) * bw;
                    end

                    % =================================================================
                    % =================================================================
                    % Plot data and limits
                    % Change size, formatting and save to file - use example code from plotFBssmcsb.m
                    if( ishandle(1) )
                        set(0,'CurrentFigure',1)
                    else
                        figure(1)
                    end
                    plotFBExcursions(numCh,id,network,isite,ichannel,iband,data(:,1,ichannel),data(:,iband+1,ichannel),limitHi(:,1,ichannel),limitHi(:,iband+1,ichannel),limitLo(:,1,ichannel),limitLo(:,iband+1,ichannel),excurPtsHi,excurPtsLo,viewPlots);
                    % hold on
                    % if( excurHiOff && excurLoOff )
                    %     plotFBExcursions(numCh,id,network,isite,ichannel,iband,data(:,1,ichannel),data(:,iband+1,ichannel),limitHi,limitHi,limitLo,limitLo,excurPoints,viewPlots);
                    % elseif( excurHiOff )
                    %     plotFBExcursions(numCh,id,network,isite,ichannel,iband,data(:,1,ichannel),data(:,iband+1,ichannel),limitHi,limitHi,limitLo(:,1,ichannel),limitLo(:,iband+1,ichannel),excurPoints,viewPlots);
                    % elseif( excurLoOff )
                    %     plotFBExcursions(numCh,id,network,isite,ichannel,iband,data(:,1,ichannel),data(:,iband+1,ichannel),limitHi(:,1,ichannel),limitHi(:,iband+1,ichannel),limitLo,limitLo,excurPoints,viewPlots);
                    % else
                    %     plotFBExcursions(numCh,id,network,isite,ichannel,iband,data(:,1,ichannel),data(:,iband+1,ichannel),limitHi(:,1,ichannel),limitHi(:,iband+1,ichannel),limitLo(:,1,ichannel),limitLo(:,iband+1,ichannel),excurPoints,viewPlots);
                    % end
                    % hold off
                    % =================================================================
                    % =================================================================
                end % for ichannel = channels
                plotET = now;
                plotDelta = plotDelta+(plotET-plotST)*86400;

                % Save plots to file - .gif format
                % Plots should be saved to a file like the daily FB plots
                % are in plotFBssmcsb.m. The same file names should be used
                % but the plots should be stored in a different directory.
                % These plots should eventually be the ones displayed on
                % the website.
                if( strcmpi(network,'CMN') )
                    % Check save directory environment
                    currDir = [fbExcurPlotDir sprintf('/%s',isiteFN)];
                    success = verifyEnvironment(currDir);
                    currDir = [currDir sprintf('/FB%02d',iband)];
                    success = success && verifyEnvironment(currDir);
                    if( ~success )
                        display(sprintf('Error creating directory for plot: %s',currDir))
                        display('FAILURE')
                        return
                    end

                    plotFileName = [fbExcurPlotDir sprintf('/%s/FB%02d/%s.%s.%d.%02d',...
                        isiteFN,iband,datestr(id,'yyyymmdd'),network,isiteID,iband)];
                else
                    display(sprintf('Code needs to be updated to work with network: %s', network))
                    display('USAGE')
                    return
                end

                saveST = now;
                try
                    set(0,'CurrentFigure',1), hold on;
                    success = saveFBExcurPlot(plotFileName);
                    if( success ~= 0 )
                        display('Error saving plot for current day')
                        display('BAD_WRITE')
                        return
                    end
                catch
                    display('Error saving plot for current day')
                    display('BAD_WRITE')
                    return
                end
                saveET = now;
                saveDelta = saveDelta+(saveET-saveST)*86400;
            end % for iband = bands

            display(sprintf('Plot time: %d',plotDelta))
            display(sprintf('Save time: %d',saveDelta))
            display(sprintf('Plots created for day: %s',datestr(id,'yyyy-mm-dd')))
        else
            if( ~dataExist )
                display(sprintf('Missing Data for date: %s',datestr(id,'yyyy/mm/dd')))
            end
            if( ~limitExist )
                display(sprintf('Missing Limits for date: %s',datestr(id,'yyyy/mm/dd')))
            end
            if( ~excurExist )
                display(sprintf('Missing Excursions for date: %s',datestr(id,'yyyy/mm/dd')))
            end
            
            display('Skipping day')
        end % if( exist(fbDataCurr,'file') )
    end % for ind=1:nd
end % for isite = sites

% Close plots
close all

% Turn on negative data ignored warning
warning on MATLAB:Axes:NegativeDataInLogAxis

% Reset Figure Visible default back to on
set(0,'defaultFigureVisible','on')

fend = now;
delta = (fend - fstart)*86400;
display(sprintf('Function: %s Start Time: %d',funcname,fstart))
display(sprintf('Function: %s End Time: %d',funcname,fend))
display(sprintf('Function: %s Run Time: %d',funcname,delta))
display(sprintf('Function: %s END',funcname))

if( allPlots )
    display('SUCCESS')
    success = 0;
else
    success = -1;
    display('ERROR: Not all excursions logged into DB')
    display('BAD_WRITE')
end

return
