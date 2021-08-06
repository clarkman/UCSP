function success = remakeFBExcursionDaily(startDate,endDate,varargin)
% function success = remakeFBExcursionDaily(startDate,endDate,varargin)
% 
% This function remakes the excursion database entries and plots for the
% input arguments. A date range is required. Can also remake for a given
% network, sites, bands, channels, limit definitions, and excursion 
% criteria. This function first removes all database entries that overlap 
% with the input arguments. Then, genFBExcursionDaily.m is called to remake
% the entries.
%
% Optional arguments may be input in any order. However, if providing an
% input argument for sites, bands, or channels, there must also be an input
% argument for networks. When inputting an argument for sites, bands, or 
% channels, only one network may be defined. Optional arguments are input 
% as follows: first input the argument you are setting as a string (e.g. 
% 'networks', 'sites', etc.), then input the value the argument is being 
% set to as the next argument. However, for genFBExcursionDaily optional 
% arguments, to activate the option just input that argument as a string. 
% For example, to remake the excursions from Jan 1, 2009 to Feb 1, 2009 for
% bands 1-10 and channels 1-3, with viewPlots and inLimInARow active, call 
% this function like so:
%
% remakeFBExcursionDaily('2009/01/01','2009/02/01','bands',[1:10], ...
%       'channels',[1:3],'viewPlots','inLimInARow');
%
% =========================================================================
% =========================================================================
% Required Input Arguments:
%   startDate - Start Date as string 'yyyy/mm/dd' in PST
%   endDate - End Date as string 'yyyy/mm/dd' in PST
% 
% Optional Input Arguments:
%   genPlots - run genFBExcursionPlots after running genFBExcursionDaily
%   networks - 'CMN','BK', or 'BKQ' - only works with 'CMN' for now
%   sites - station numbers of 'CMN' stations; names for other networks
%   channels - [1:4] - channels to look for excursions on
%   bands - [1:13] - bands to look for excursions on
% 
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
% 
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
% 
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
%       'viewPlots' - make figures visible for debugging
%       'plotDayZero' - create plot for day before start date (day 0)
% =========================================================================
% =========================================================================
%

display('Function: remakeFBExcursionDaily.m START')
startTime = now;
success = -1;

% =========================================================================
% =========================================================================
% Process arguments
MINARGS = 2;
optargs = size(varargin,2);
stdargs = nargin - optargs;
if( stdargs < MINARGS )
    success = -1;
    display(sprintf('Not enough input arguments: min - %d used - %d',MINARGS,stdargs))
    display('USAGE')
    return
end

% Start and End Date
% Convert date to a Matlab format, and to a vector for file name generation
% Note: We want sd,ed in UTC - database will store times in UTC
try
    sdPST = str2datenum( startDate );  %#ok<NASGU> % PST
    edPST = str2datenum( endDate );    %#ok<NASGU> % PST
    % sdUTC = sdPST + 8/24;                 % convert from PST to UTC
    % edUTC = edPST + 8/24;                 % convert from PST to UTC
catch
    success = -1;
    display('Cannot interpret start and end dates')
    display('USAGE')
    return
end

% Initial values for optional arguments
genPlots = false;
networks = { 'CMN' 'BK' 'BKQ' };
% networkSpecified = false;
sites = [ ];
bands = [ ];
channels = [ ];

% Limits
baseHi = 'median'; %#ok<NASGU>
baseLo = 'median'; %#ok<NASGU>
devHis = 75; %#ok<NASGU>
devLos = 25; %#ok<NASGU>

% Excursions
outLimHis = 6; %#ok<NASGU>
outLimLos = 6; %#ok<NASGU>
inLimHis = 3; %#ok<NASGU>
inLimLos = 3; %#ok<NASGU>
% inLimRowHi = false;
% inLimRowLo = false;

% Additional Options
% clearDB = false;
% clearOverlapDBOff = false;
% debugMode = false;
% loadLimits = false;
% saveLimits = false;
% loadExcursions = false;
% saveExcursions = false;
% logExcurDB = false;
% logExcurMAT = false;
% viewPlots = false;

% Initialize command string for remaking Excursions and Plots
remakeExcurCmdStart = 'success = genFBExcursionDaily(';
remakePlotCmdStart = 'success = genFBExcursionPlots(';
remakeExcurCmdEnd = ');';
remakePlotCmdEnd = ');';

% Optional Arguments
try
    k = 1;
    while( k <= optargs )
        if( strcmpi(varargin{k}, 'genPlots') )
            genPlots = true;
            display(sprintf('%s option active',varargin{k}))
        elseif( strcmpi(varargin{k}, 'networks') )
            if( ischar( varargin{k+1} ) )
                networks = { varargin{k+1} };
                networkSpecified = true; %#ok<NASGU>
                k = k + 1;
                display(sprintf('%s option set to %s',varargin{k},varargin{k+1}))
            end
        elseif( strcmpi(varargin{k}, 'sites') )
            sites = varargin{k+1};
            display(sprintf('%s option set',varargin{k}))
            k = k + 1;
        elseif( strcmpi(varargin{k}, 'bands') )
            bands = varargin{k+1};
            display(sprintf('%s option set',varargin{k}))
            k = k + 1;
        elseif( strcmpi(varargin{k}, 'channels') )
            channels = varargin{k+1};
            display(sprintf('%s option set',varargin{k}))
            k = k + 1;
        elseif( strcmpi(varargin{k}, 'baseHi') )
            if( ischar( varargin{k+1} ) )
                switch lower( varargin{k+1} )
                    case { 'median','mean' }
                        baseHi = lower( varargin{k+1} ); %#ok<NASGU>
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
                        baseLo = lower( varargin{k+1} ); %#ok<NASGU>
                        display(sprintf('%s option set to %s',varargin{k},varargin{k+1}))
                        k = k + 1;
                    otherwise
                        display(sprintf('Invalid value for %s, setting to default',varargin{k}))
                end
            end
        elseif( strcmpi(varargin{k}, 'devHi') )
            if( isnumeric( varargin{k+1} ) )
                devHis = varargin{k+1}; %#ok<NASGU>
                display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
                k = k + 1;
            end
        elseif( strcmpi(varargin{k}, 'devLo') )
            if( isnumeric( varargin{k+1} ) )
                devLos = varargin{k+1}; %#ok<NASGU>
                display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
                k = k + 1;
            end
        elseif( strcmpi(varargin{k}, 'maxDevHi') )
            if( isnumeric( varargin{k+1} ) )
                maxDevHi = varargin{k+1}; %#ok<NASGU>
                display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
                k = k + 1;
            end
        elseif( strcmpi(varargin{k}, 'maxDevLo') )
            if( isnumeric( varargin{k+1} ) )
                maxDevLo = varargin{k+1}; %#ok<NASGU>
                display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
                k = k + 1;
            end
        elseif( strcmpi(varargin{k}, 'outLimHi') )
            if( isnumeric( varargin{k+1} ) )
                outLimHis = varargin{k+1}; %#ok<NASGU>
                display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
                k = k + 1;
            end
        elseif( strcmpi(varargin{k}, 'outLimLo') )
            if( isnumeric( varargin{k+1} ) )
                outLimLos = varargin{k+1}; %#ok<NASGU>
                display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
                k = k + 1;
            end
        elseif( strcmpi(varargin{k}, 'inLimHi') )
            if( isnumeric( varargin{k+1} ) )
                inLimHis = varargin{k+1}; %#ok<NASGU>
                display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
                k = k + 1;
            end
        elseif( strcmpi(varargin{k}, 'inLimLo') )
            if( isnumeric( varargin{k+1} ) )
                inLimLos = varargin{k+1}; %#ok<NASGU>
                display(sprintf('%s option set to %d',varargin{k},varargin{k+1}))
                k = k + 1;
            end
        else
            switch lower( varargin{k} )
                case { 'excurhioff','excurlooff','inlimrowhi','inlimrowlo' }
                    remakeExcurCmdEnd = sprintf(',''%s''%s',varargin{k},remakeExcurCmdEnd);
                    remakePlotCmdEnd = sprintf(',''%s''%s',varargin{k},remakePlotCmdEnd);
                case { 'cleardb','clearoverlapdboff','debugmode', ...
                        'loadlimits','savelimits','loadexcursions','saveexcursions', ...
                        'logexcurdb','logexcurmat','removeexclusions' }
                    remakeExcurCmdEnd = sprintf(',''%s''%s',varargin{k},remakeExcurCmdEnd);
                case { 'viewplots','plotdayzero' }
                    remakePlotCmdEnd = sprintf(',''%s''%s',varargin{k},remakePlotCmdEnd);
                otherwise
                    display(sprintf('Optional argument %s cannot be interpreted. Argument is ignored.', k))
            end
        end
        
        k = k+1;
    end % while( k <= optargs )
catch
    display('Error processing arguments')
    display('USAGE')
    success = -1;
    return
end

% % Clear DB entries based on input arguments
% try
%     if( networkSpecified )
%         network = upper(networks{1});
%         cmd = sprintf('success = clearFBDataBase(%.8f,%.8f,''%s''',sdUTC,edUTC+1,network);
%         if( isempty(sites) && isempty(bands) && isempty(channels) )
%             cmd = [cmd ')'];
%             eval(cmd);
%             
%             if( success < 0 )
%                 display('Error clearing database')
%                 display(sprintf('Clear Command: %s',cmd))
%                 display('FAILURE')
%                 return
%             end
%         elseif( isempty(bands) && isempty(channels) )
%             for isite = sites
%                 if( strcmpi( network, 'CMN' ) )
%                     cmdS = [cmd sprintf(',%d',isite) ');'];
%                     bands = [1:13];
%                     channels = [1:4];
%                 else
%                     cmdS = [cmd sprintf(',''%s''',isite) ');'];
%                     % Get BK bands, channels
%                     bands = [];
%                     channels = [];
%                 end
%                 eval(cmdS);
%                 
%                 if( success < 0 )
%                     display('Error clearing database')
%                     display(sprintf('Clear Command: %s',cmdS))
%                     display('FAILURE')
%                     return
%                 end
%             end
%         elseif( isempty(sites) && isempty(channels) )
%             if( strcmpi( network, 'CMN' ) )
%                 sites = [600:609];
%                 channels = [1:4];
%             else
%                 % Get BK site names, channels
%                 sites = [];
%                 channels = [];
%             end
%             
%             for isite = sites
%                 for iband = bands
%                     if( strcmpi( network, 'CMN' ) )
%                         cmdS = [cmd sprintf(',%d,%d',isite,iband) ');'];
%                     else
%                         cmdS = [cmd sprintf(',''%s'',%d',isite,iband) ');'];
%                     end
%                     eval(cmdS);
%                     
%                     if( success < 0 )
%                         display('Error clearing database')
%                         display(sprintf('Clear Command: %s',cmdS))
%                         display('FAILURE')
%                         return
%                     end
%                 end
%             end
%         elseif( isempty(sites) && isempty(bands) )
%             if( strcmpi( network, 'CMN' ) )
%                 sites = [600:609];
%                 bands = [1:13];
%             else
%                 % Get BK site names, bands
%                 sites = [];
%                 bands = [];
%             end
%             
%             for isite = sites
%                 for iband = bands
%                     for ichannel = channels
%                         if( strcmpi( network, 'CMN' ) )
%                             cmdS = [cmd sprintf(',%d,%d,%d',isite,iband,ichannel) ');'];
%                         else
%                             cmdS = [cmd sprintf(',''%s'',%d,%d',isite,iband,ichannel) ');'];
%                         end
%                         eval(cmdS);
%                         
%                         if( success < 0 )
%                             display('Error clearing database')
%                             display(sprintf('Clear Command: %s',cmdS))
%                             display('FAILURE')
%                             return
%                         end
%                     end
%                 end
%             end
%         elseif( isempty(channels) )
%             if( strcmpi( network, 'CMN' ) )
%                 channels = [1:4];
%             else
%                 % Get BK channels
%                 channels = [];
%             end
%             
%             for isite = sites
%                 for iband = bands
%                     if( strcmpi( network, 'CMN' ) )
%                         cmdS = [cmd sprintf(',%d,%d',isite,iband) ');'];
%                     else
%                         cmdS = [cmd sprintf(',''%s'',%d',isite,iband) ');'];
%                     end
%                     eval(cmdS);
%                     
%                     if( success < 0 )
%                         display('Error clearing database')
%                         display(sprintf('Clear Command: %s',cmdS))
%                         display('FAILURE')
%                         return
%                     end
%                 end
%             end
%         elseif( isempty(bands) )
%             if( strcmpi( network, 'CMN' ) )
%                 bands = [1:13];
%             else
%                 % Get BK bands
%                 bands = [];
%             end
%             
%             for isite = sites
%                 for iband = bands
%                     for ichannel = channels
%                         if( strcmpi( network, 'CMN' ) )
%                             cmdS = [cmd sprintf(',%d,%d,%d',isite,iband,ichannel) ');'];
%                         else
%                             cmdS = [cmd sprintf(',''%s'',%d,%d',isite,iband,ichannel) ');'];
%                         end
%                         eval(cmdS);
%                         
%                         if( success < 0 )
%                             display('Error clearing database')
%                             display(sprintf('Clear Command: %s',cmdS))
%                             display('FAILURE')
%                             return
%                         end
%                     end
%                 end
%             end
%         elseif( isempty(sites) )
%             if( strcmpi( network, 'CMN' ) )
%                 sites = [600:609];
%             else
%                 % Get BK site names, bands
%                 sites = [];
%             end
%             
%             for isite = sites
%                 for iband = bands
%                     for ichannel = channels
%                         if( strcmpi( network, 'CMN' ) )
%                             cmdS = [cmd sprintf(',%d,%d,%d',isite,iband,ichannel) ');'];
%                         else
%                             cmdS = [cmd sprintf(',''%s'',%d,%d',isite,iband,ichannel) ');'];
%                         end
%                         eval(cmdS);
%                         
%                         if( success < 0 )
%                             display('Error clearing database')
%                             display(sprintf('Clear Command: %s',cmdS))
%                             display('FAILURE')
%                             return
%                         end
%                     end
%                 end
%             end
%         else
%             for isite = sites
%                 for iband = bands
%                     for ichannel = channels
%                         if( strcmpi( network, 'CMN' ) )
%                             cmdS = [cmd sprintf(',%d,%d,%d',isite,iband,ichannel) ');'];
%                         else
%                             cmdS = [cmd sprintf(',''%s'',%d,%d',isite,iband,ichannel) ');'];
%                         end
%                         eval(cmdS);
%                         
%                         if( success < 0 )
%                             display('Error clearing database')
%                             display(sprintf('Clear Command: %s',cmdS))
%                             display('FAILURE')
%                             return
%                         end
%                     end
%                 end
%             end
%         end % if( isempty(sites) && isempty(bands) && isempty(channels) )
%     else
%         if( ~isempty(sites) || ~isempty(bands) || ~isempty(channels) )
%             display('ERROR: Must specify network when specifying sites, bands, or channels')
%             display('USAGE')
%             success = -1;
%             return
%         end
%         success = clearFBDataBase(sdUTC,edUTC);
%         
%         if( success < 0 )
%             display('Error clearing database')
%             display(sprintf('Clear Command: success = clearFBDataBase(%.8f,%.8f);',sdUTC,edUTC+1))
%             display('FAILURE')
%             return
%         end
%     end % if( networkSpecified )
% catch
%     display('Error clearing database')
%     display('FAILURE')
%     success = -1;
%     return
% end
% 
% if( success < 0 )
%     display('Error clearing database')
%     display('FAILURE')
%     return
% end

% Remake entries
try
   for inet = networks
       inetwork = char(inet);
       remakeCmd = sprintf('''%s'',''%s'',''%s'',',startDate,endDate,inetwork);
       
       if(strcmpi(inetwork,'CMN'))
           if( isempty(sites) && isempty(bands) && isempty(channels) )
               sites = 600:609;
               bands = 1:13;
               channels = 1:4;
           end
           
           remakeCmd = [remakeCmd '[ '];
           
           for isite = sites
               remakeCmd = [remakeCmd sprintf('%d ',isite)];
           end % for isites = sites
           remakeCmd = [remakeCmd '],[ '];
           
           for iband = bands
               remakeCmd = [remakeCmd sprintf('%d ',iband)];
           end % for iband = bands
           remakeCmd = [remakeCmd '],[ '];
           
           for ichannel = channels
               remakeCmd = [remakeCmd sprintf('%d ',ichannel)];
           end % for ichannel = channels
           remakeCmd = [remakeCmd ']'];
       else
           if( isempty(sites) && isempty(bands) && isempty(channels) )
               % Get BK sites, bands, channels
               sites = [];
               bands = [];
               channels = [];
           end
           
           remakeCmd = [remakeCmd '{ '];
           
           for isite = sites
               remakeCmd = [remakeCmd sprintf('''%s'' ',isite)];
           end % for isites = sites
           remakeCmd = [remakeCmd '},[ '];
           
           for iband = bands
               remakeCmd = [remakeCmd sprintf('%d ',iband)];
           end % for iband = bands
           remakeCmd = [remakeCmd '],[ '];
       
           for ichannel = channels
               remakeCmd = [remakeCmd sprintf('%d ',ichannel)];
           end % for ichannel = channels
           remakeCmd = [remakeCmd ']'];
       end
       
       remakeCmdLim = '''baseHi'',baseHi,''devHi'',devHis,''baseLo'',baseLo,''devLo'',devLos';
       remakeCmdExcur = '''outLimHi'',outLimHis,''inLimHi'',inLimHis,''outLimLo'',outLimLos,''inLimLo'',inLimLos';
       
       remakeExcurCmd = sprintf('%s%s,%s,%s%s',...
           remakeExcurCmdStart,remakeCmd,remakeCmdLim,remakeCmdExcur,remakeExcurCmdEnd);
       remakePlotCmd = sprintf('%s%s,%s,%s%s',...
           remakePlotCmdStart,remakeCmd,remakeCmdLim,remakeCmdExcur,remakePlotCmdEnd);
       
       % Remake Excursions
       display('Remaking Excursions:')
       display(remakeExcurCmd)
       eval(remakeExcurCmd)
       if( success < 0 )
           display('Error running genFBExcursionDaily.m')
           display('FAILURE')
           return
       end
       
       % Remake Plots
       if( genPlots )
           display('Remaking Plots:')
           display(remakePlotCmd)
           eval(remakePlotCmd)
           if( success < 0 )
               display('Error running genFBExcursionPlots.m')
               display('FAILURE')
               return
           end
       end % if( genPlots )
       
       % Ok to clear sites, bands, and channels because can only have
       % multiple networks if these were not specified.
       sites = [];
       bands = [];
       channels = [];
   end % for inetwork = networks
catch
    display('Error remaking FB excursions')
    display('FAILURE')
    success = -1;
    return
end

endTime = now;
delta = (endTime - startTime)*86400;
success = 0;
display(sprintf('Function Start Time: %d',startTime))
display(sprintf('Function End Time: %d',endTime))
display(sprintf('Function Run Time: %d',delta))
display('Function: remakeFBExcursionDaily.m END')
display('SUCCESS')
return
