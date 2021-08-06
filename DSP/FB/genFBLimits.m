function [limitHi,limitLo] = genFBLimits(limitDate,network,siteID,bands,channels,varargin)
% function [limitHi,limitLo] = genFBLimits(limitDate,network,siteID,bands,channels,varargin)
% 
% This function generates FB limits. These limits are returned but can also
% be saved to a .mat file for later use. If limit definition values are not
% input, the output is a NaN matrix.
%
% [limitHi,limitLo] = genFBLimits(limitDate,network,isite,bands,channels,'pT','saveLimits','baseHi','median','baseLo','median','devHi',75,'devLo',25);
%
% =========================================================================
% =========================================================================
% 
% Required Input Arguments:
%   Date Range: 
%       limitDate - Date as string 'yyyy/mm/dd' in PST
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
%       *NOTE: The below arguments are required if limits are to be 
%           calculated. High and Low limits are defined separately. If no
%           argument is specified, the limits are not calculated.
%       Baseline - 'baseHi', 'baseLo'
%           Choices: 'mean' or 'median'
%           Usage: genFBLimits(...,'baseHi','median',...)
%       Deviations - 'devLo', 'devHi'
%           Values: scalar value of deviation that gives percentile for
%               baseline 'median' or number of standard deviations for
%               baseline 'mean'.
%           Usage: genFBLimits(...,'devLo',[0:50]',...)
% 
%   Additional Options:
%       *NOTE: All optional input arguments are input as strings and 
%       correspond to a boolean in the script below. An input argument that
%       is one of the below optional arguments will enable the description
%       associated with the argument and set the boolean to true.
% 
%       'loadLimits' - attempt to load limits from file - 
%           regenerate if file does not exist
%       'saveLimits' - save generated limits to file - 
%           separate files for hi/lo limits
%       'pT' - convert limits to units of pT
% 

funcname = 'genFBLimits.m';
display(sprintf('Function: %s START',funcname))
fstart = now;

% =========================================================================
% =========================================================================
% Constants
nTOD = 96;

% Process arguments
MINARGS = 5;
optargs = size(varargin,2);
stdargs = nargin - optargs;
if( stdargs < MINARGS )
    limitHi = NaN(nTOD,15,4); limitLo = NaN(nTOD,15,4);
    display(sprintf('Not enough input arguments: min - %d used - %d',MINARGS,stdargs))
    display('USAGE')
    return
end
display(sprintf('\nINPUT ARGUMENTS:'))

% Date
% Convert date to a Matlab format, and to a vector for file name generation
% Note: We want sd,ed in UTC - database will store times in UTC
try
    ldPST = str2datenum( limitDate );  % PST
    % ldUTC = ldPST + 8/24;                 % convert from PST to UTC
    ldstr = datestr(limitDate,'yyyymmdd');
catch
    limitHi = NaN(nTOD,15,4); limitLo = NaN(nTOD,15,4);
    display('Cannot interpret date')
    display('USAGE')
    return
end
display(sprintf('Date: %s',limitDate))
% Year, Month, Season Values
[y,m] = datevec(ldPST);             % - Get date vector (month, day, etc)
season = ceil((mod(m+6,12)+1)/3);       % - Calculate season param


% Network
NETWORKS = {'BK' 'BKQ' 'CMN'};
network = upper(network);
if( isempty( find( strcmpi( NETWORKS, network ),1 ) ) )
    limitHi = NaN; limitLo = NaN;
    display(sprintf('Unknown network: %s', network));
    display('USAGE')
    return
end
display(sprintf('Network: %s',network))

% Site
% Get station name here!
if( iscell(siteID) )
    SID = siteID{:};
else
    SID = siteID;
end

if( ischar(SID) )
    siteStr = sprintf('%s',SID);
else
    siteStr = sprintf('%d',SID);
end

% Get Station Name
% Old method - new function called getStationInfo in streams/CalMagNet!
%siteCell = getStationInfoSLP({network},1,1,'SID',siteID,'NAME');
%siteName = siteCell{1};

% New method - only works for CMN network!
% Returns structure with:
% sid, file_name, status, first_data_start, recent_data, latitude, longitude
% Use getStationName.m to get siteName
siteInfo = getStationInfo(siteStr);
siteFN = siteInfo.file_name;
siteName = getStationName(siteFN);

display(sprintf('Site: %s - %s',siteName,siteStr))

% Bands
maxBand = max(bands) + 1;
instr = '';
for jband = bands
    instr = sprintf('%s%d ',instr,jband);
end
display(sprintf('Bands: %s',instr))

% Channels
maxCh = max(channels);
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
loadLimits = false;
saveLimits = false;
pT = false;

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
    elseif( strcmpi(varargin{k}, 'loadLimits') )
        loadLimits = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'saveLimits') )
        saveLimits = true;
        display(sprintf('%s option active',varargin{k}))
    elseif( strcmpi(varargin{k}, 'pT') )
        pT = true;
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

% =========================================================================
% =========================================================================
display(' ')
display('FUNCTION BODY:')

% Load environment variables
[fbDir,fbStatDir,kpTxtFileName,kpMatFileName,fbExcurDir,fbExcurPointsDir,fbExcurPlotDir,fbExcurLogDir,fbLimitDir] = fbLoadExcurEnv(network);
if( strcmpi(fbDir,'ERROR') )
    display('Problem loading environment variables')
    display('ENVIRONMENT')
    limitHi = NaN(nTOD,maxBand,maxCh); limitLo = NaN(nTOD,maxBand,maxCh);
    return
end

% Check that data exists for date before generating limits
dataExist = false;
for ichannel = checkCh
    if( strcmpi(network,'CMN') )
        fbDataFile = sprintf( '%s/%s/CHANNEL%d/%s.CMN.%d.%02d.fb',...
            fbDir,siteFN,ichannel,ldstr,siteID,ichannel);
    else
        % MODIFY TO WORK WITH BK NETWORK!!! and other networks!
        display('UPDATE to work with other networks')
        display('FAILURE')
        return
    end

    if( exist(fbDataFile,'file') )
        dataExist = true;
    end
end % for ichannel = checkCh

% Check if data exists for day. Skip date if no data.
if( ~dataExist )
    display(sprintf('Data does not exist for day: %s',limitDate))
    display('Limits should not be generated.')
    limitHi = NaN(nTOD,maxBand,maxCh); limitLo = NaN(nTOD,maxBand,maxCh);
    return
end

% Load Kp file
try
    startKp = now;
    kp = [ ];
    kpdtnum = [ ];
    cmd = sprintf('load %s kp kpdtnum;', kpMatFileName );
    eval( cmd );
    kpdtnum = kpdtnum - 8/24; % adjust for 8 hr time difference in our analysis, PST
    endKp = now;
    deltaKp = (endKp - startKp)*86400;
    display(sprintf('Time to Load Kp Values: %d', deltaKp));
catch
    display('ERROR: Unable to load Kp values')
    display('BAD_LOAD')
    limitHi = NaN(nTOD,maxBand,maxCh); limitLo = NaN(nTOD,maxBand,maxCh);
    return
end

% Load stats for site - use baseline variable for Hi and Lo
try
    statFile = '';
    statVarHi = '';
    statVarLo = '';

    if( strcmpi( network, 'BKQ' ) )
        display(sprintf('Network: %s, Station Name: %s, Station ID: %s',network,siteName,siteID))
        statFile = sprintf( '%s/summaryQuiet-%s', fbStatDir, siteID );
        statVarHi = sprintf( '%sStats%s', baseHi, siteID );
        statVarLo = sprintf( '%sStats%s', baseLo, siteID );
    elseif( ischar( siteID ) )
        display(sprintf('Network: %s, Station Name: %s, Station ID: %s',network,siteName,siteID))
        statFile = sprintf( '%s/summary-%s', fbStatDir, siteID );
        statVarHi = sprintf( '%sStats%s', baseHi, siteID );
        statVarLo = sprintf( '%sStats%s', baseLo, siteID );
    else
        display(sprintf('Network: %s, Station Name: %s, Station ID: %d',network,siteName,siteID))
        statFile = sprintf( '%s/summary-%d', fbStatDir, siteID );
        statVarHi = sprintf( '%sStats%d', baseHi, siteID );
        statVarLo = sprintf( '%sStats%d', baseLo, siteID );
    end

    statsHi = [ ]; %#ok<NASGU>
    statsLo = [ ]; %#ok<NASGU>
    if( ~strcmpi( baseHi, 'off' ) )
        cmd = sprintf( 'load %s.mat %s', statFile, statVarHi );
        eval( cmd );    % gives dataXXX,statsXXX,seasonXXX,kp_arrXXX
        cmd = sprintf( 'statsHi = %s;', statVarHi );
        eval( cmd );    % gives statsHi
        display(sprintf('Stats %s loaded from file: %s.mat',statVarHi,statFile))
    end
    if( ~strcmpi( baseLo, 'off' ) )
        cmd = sprintf( 'load %s.mat %s', statFile, statVarLo );
        eval( cmd );    % gives dataXXX,statsXXX,seasonXXX,kp_arrXXX
        cmd = sprintf( 'statsLo = %s;', statVarLo );
        eval( cmd );    % gives statsLo
        display(sprintf('Stats %s loaded from file: %s.mat',statVarLo,statFile))
    end
catch
    try
        display(sprintf('Error loading stats from file: %s.mat',statFile))
        display(sprintf('Loading Backup File: %s.backup.mat',statFile))
        if( ~strcmpi( baseHi, 'off' ) )
            cmd = sprintf( 'load %s.backup.mat %s', statFile, statVarHi );
            eval( cmd );    % gives dataXXX,statsXXX,seasonXXX,kp_arrXXX
            cmd = sprintf( 'statsHi = %s;', statVarHi );
            eval( cmd );    % gives statsHi
            display(sprintf('Stats %s loaded from file: %s.backup.mat',statVarHi,statFile))
        end
        if( ~strcmpi( baseLo, 'off' ) )
            cmd = sprintf( 'load %s.backup.mat %s', statFile, statVarLo );
            eval( cmd );    % gives dataXXX,statsXXX,seasonXXX,kp_arrXXX
            cmd = sprintf( 'statsLo = %s;', statVarLo );
            eval( cmd );    % gives statsLo
            display(sprintf('Stats %s loaded from file: %s.backup.mat',statVarLo,statFile))
        end
    catch
        display(sprintf('Error loading stats from file: %s.backup.mat',statFile))
        display('BAD_LOAD')
        limitHi = NaN(nTOD,maxBand,maxCh); limitLo = NaN(nTOD,maxBand,maxCh);
        return
    end
end % try

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

% Generate File Name for limits
if( strcmpi(network,'CMN') )
    limitDir = [fbLimitDir sprintf('/%s',siteFN)];
    success = verifyEnvironment(limitDir);
    if( ~strcmpi( baseHi, 'off' ) )
        limitDirHi = [limitDir sprintf('/%s',baseHi)];
        success = success && verifyEnvironment(limitDirHi);
    end
    if( ~strcmpi( baseLo, 'off' ) )
        limitDirLo = [limitDir sprintf('/%s',baseLo)];
        success = success && verifyEnvironment(limitDirLo);
    end
    if( ~success )
        return
    end
    
    if( strcmpi( baseHi, 'mean' ) )
        if( devHi < 0 )
            limitFileHi = [limitDirHi ...
                sprintf('/%s.%s.n%02d.fbl.mat',datestr(ldPST,'yyyymmdd'),network,-devHi)];
        elseif( ~isnan(devHi) )
            limitFileHi = [limitDirHi ...
                sprintf('/%s.%s.p%02d.fbl.mat',datestr(ldPST,'yyyymmdd'),network,devHi)];
        end
    elseif( strcmpi( baseHi, 'median' ) )
        limitFileHi = [limitDirHi ...
            sprintf('/%s.%s.%03d.fbl.mat',datestr(ldPST,'yyyymmdd'),network,devHi)];
    end
    
    if( strcmpi( baseLo, 'mean' ) )
        if( devLo <= 0 )
            limitFileLo = [limitDirLo ...
                sprintf('/%s.%s.p%02d.fbl.mat',datestr(ldPST,'yyyymmdd'),network,-devLo)];
        elseif( ~isnan(devLo) )
            limitFileLo = [limitDirLo ...
                sprintf('/%s.%s.n%02d.fbl.mat',datestr(ldPST,'yyyymmdd'),network,devLo)];
        end
    elseif( strcmpi( baseLo, 'median' ) )
        limitFileLo = [limitDirLo ...
            sprintf('/%s.%s.%03d.fbl.mat',datestr(ldPST,'yyyymmdd'),network,devLo)];
    end
else
    display(sprintf('Code needs to be updated to work with network: %s', network))
    display('FAILURE')
    return
end

% High Limits
calcLimits = false;
if( ~strcmpi( baseHi, 'off' ) )
    % Load .mat file for limits
    try
        cmd = sprintf('load %s limit;', limitFileHi );
        eval( cmd );
        limitHi = limit; %#ok<NODEF>
        display(sprintf('High Limit File exists for day: %s',limitDate))
    catch
        limitHi = zeros(nTOD,maxBand,maxCh);
        calcLimits = true;
    end
    
    if( ~calcLimits )
        try
            for iband = bands
                for ich = channels
                    if( ~logical(norm(limitHi(:,iband+1,ichannel))) )
                        calcLimits = true;
                    end
                end
            end
        catch
            calcLimits = true;
        end
    end

    if( ~loadLimits || calcLimits )
        display(sprintf('Calculating High Limits for day: %s',limitDate))
        for it = 1:nTOD
            % Calculate time stamp
            t = ldPST + it/nTOD;
            limitHi(it,bands,channels) = t;

            % Look up kp
            % For the current time, get the closest time with a known kp
            % For that time, get the kp value
            thisKp = kp( closest( kpdtnum,t ) );
            if ~isempty(thisKp)
                switch floor(thisKp),
                    case {0,1}
                        kp_tmp = 1;
                    case {2,3}
                        kp_tmp = 2;
                    case {4,5}
                        kp_tmp = 3;
                    case {6,7,8,9}
                        kp_tmp = 4;
                end % switch
            end

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
                    if( strcmpi( baseHi, 'mean' ) )
                        limitBase = statsHi(it,iband,ichannel,season,kp_tmp,2); % mean value
                        % calculate limitLo, limitHi by taking mean and subtracting/adding standard deviation scaled by the number of sigmas
                        limitHi(it,iband+1,ichannel) = limitBase + devHi*statsHi(it,iband,ichannel,season,kp_tmp,3);
                    elseif( strcmpi( baseHi, 'median' ) )
                        limitHi(it,iband+1,ichannel) = statsHi(it,iband,ichannel,season,kp_tmp,devHi+2);
                    end
                    
                    if( pT && (ichannel ~= polCh) )
                        limitHi(it,iband+1,ichannel) = real(sqrt(limitHi(it,iband+1,ichannel))) * bw;
                    end 
                end % for ichannel = channels
            end % for iband = bands
        end % for it = 1:nTOD
        
        % Save limits to .mat file
        if( saveLimits )
            try
                limit = limitHi;
                if( ~pT ) % Convert to pT for saving
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
                            if( ichannel ~= polCh )
                                limit(:,iband+1,ichannel) = real(sqrt(limitHi(:,iband+1,ichannel))) * bw;
                            end
                        end
                    end
                end
                cmd = sprintf('save %s limit;', limitFileHi );
                eval( cmd );
                display(['High Limits saved for day: ' datestr(ldPST,'yyyy-mm-dd')])
            catch
                display(['Error saving high limits for day: ' datestr(ldPST,'yyyy-mm-dd')])
            end
        end % if( saveLimits )
    else
        if( ~pT )   % limits saved in units of pT
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
                    if( ichannel ~= polCh )
                        limitHi(:,iband+1,ichannel) = 1/bw * (limitHi(:,iband+1,ichannel) .^ 2);
                    end
                end
            end
        end
    end % if( ~loadLimits || calcLimits )
else
    limitHi = NaN(nTOD,maxBand,maxCh);
end % if( ~strcmpi( baseHi, 'off' ) )

% Low Limits
calcLimits = false;
if( ~strcmpi( baseLo, 'off' ) )
    % Load .mat file for limits
    try
        cmd = sprintf('load %s limit;', limitFileLo );
        eval( cmd );
        limitLo = limit;
        display(sprintf('Low Limit File exists for day: %s',limitDate))
    catch
        limitLo = zeros(nTOD,maxBand,maxCh);
        calcLimits = true;
    end
    
    if( ~calcLimits )
        try
            for iband = bands
                for ich = channels
                    if( ~logical(norm(limitLo(:,iband+1,ichannel))) )
                        calcLimits = true;
                    end
                end
            end
        catch
            calcLimits = true;
        end
    end

    if( ~loadLimits || calcLimits )
        display(sprintf('Calculating Low Limits for day: %s',limitDate))
        for it = 1:nTOD
            % Calculate time stamp
            t = ldPST + it/nTOD;
            limitLo(it,bands,channels) = t;

            % Look up kp
            % For the current time, get the closest time with a known kp
            % For that time, get the kp value
            thisKp = kp( closest( kpdtnum,t ) );
            if ~isempty(thisKp)
                switch floor(thisKp),
                    case {0,1}
                        kp_tmp = 1;
                    case {2,3}
                        kp_tmp = 2;
                    case {4,5}
                        kp_tmp = 3;
                    case {6,7,8,9}
                        kp_tmp = 4;
                end % switch
            end

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
                    if( strcmpi( baseLo, 'mean' ) )
                        limitBase = statsLo(it,iband,ichannel,season,kp_tmp,2); % mean value
                        % calculate limitLo, limitLo by taking mean and subtracting/adding standard deviation scaled by the number of sigmas
                        limitLo(it,iband+1,ichannel) = limitBase - devLo*statsLo(it,iband,ichannel,season,kp_tmp,3);
                    elseif( strcmpi( baseLo, 'median' ) )
                        limitLo(it,iband+1,ichannel) = statsLo(it,iband,ichannel,season,kp_tmp,devLo+2);
                    end
                    
                    if( pT && (ichannel ~= polCh) )
                        limitLo(it,iband+1,ichannel) = real(sqrt(limitLo(it,iband+1,ichannel))) * bw;
                    end 
                end % for ichannel = channels
            end % for iband = bands
        end % for it = 1:nTOD
        
        % Save limits to .mat file
        if( saveLimits )
            try
                limit = limitLo;
                if( ~pT ) % Convert to pT for saving
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
                            if( ichannel ~= polCh )
                                limit(:,iband+1,ichannel) = real(sqrt(limitLo(:,iband+1,ichannel))) * bw;
                            end
                        end
                    end
                end
                cmd = sprintf('save %s limit;', limitFileLo );
                eval( cmd );
                display(['Low Limits saved for day: ' datestr(ldPST,'yyyy-mm-dd')])
            catch
                display(['Error saving low limits for day: ' datestr(ldPST,'yyyy-mm-dd')])
            end
        end % if( saveLimits )
    else
        if( ~pT )   % limits saved in units of pT
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
                    if( ichannel ~= polCh )
                        limitLo(:,iband+1,ichannel) = 1/bw * (limitLo(:,iband+1,ichannel) .^ 2);
                    end
                end
            end
        end
    end % if( ~loadLimits || calcLimits )
else
    limitLo = NaN(nTOD,maxBand,maxCh);
end % if( ~strcmpi( baseLo, 'off' ) )

fend = now;
delta = (fend - fstart)*86400;
display(sprintf('Function: %s Start Time: %d',funcname,fstart))
display(sprintf('Function: %s End Time: %d',funcname,fend))
display(sprintf('Function: %s Run Time: %d',funcname,delta))
display(sprintf('Function: %s END',funcname))

return

