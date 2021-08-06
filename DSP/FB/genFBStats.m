function success = genFBStats( siteID, network, useMatFile, cleanDataLevel )
% function success = genFBStats( siteID, network, useMatFile, cleanDataLevel )
% 
% This function is an expansion on the old fbmedian.m, created by JWC. That
% function is located in the directory QFDC/tools/DSP/FB. The purpose of
% this function is to make the stat collection for FB data more robust and
% better organized. 
% 
% The old system stores all stats in one matrix called "statsXXX" where XXX
% is the site ID. The old function also stores matrices dataXXX, kparr, and
% season. These matrices should not be necessary and will be removed. The
% variables are stored in a file "summary-XXX.mat".
% 
% The new system will use the same file name. At this time it is unclear
% whether the same file (with appended data) can be used or if it should be
% stored in a different directory. To start, the file will be placed in a
% new directory. Each file will contain two matrices: medianStatsXXX and
% meanStatsXXX. The files will not contain data, stats, kparr, or season
% variables unless necessary. A description of each matrix is below. The
% dimensions of each matrix are consistent with the old stats variable,
% which are:
% 
%   1 - Time of Day ( 1-96 - 15 min intervals )
%   2 - FB Band ( 1-13 )
%   3 - Data Channel ( 1-4 - E/W, N/S, U/D, Polarity - not sure of order )
%   4 - Season ( 1: Sum - Jun,Jul,Aug; 2: Aut - Sep,Oct,Nov; 3: Win -
%       Dec,Jan,Feb; 4: Spr - Mar,Apr,May )
%   5 - Kp Value ( 1-4 )
%   6 - Stats ( described below )
% 
% meanStatsXXX:
% This matrix will contain three columns for the stats: Column 1 is the 
% number of data points, Column 2 is the mean value of the data, Column 3 
% is the standard deviation of the data.
% 
% medianStatsXXX:
% This matrix will contain 102 columns: Column 1 is the number of data
% points, Column k (k > 1) is the (k-2)th percentile of the data. Note that
% the 52nd column corresponds to the 50th percentile and is the median
% value of the data.
% 
% CORRECTION TO THE ABOVE:
% The file that is saved in this function is the same file as used
% previously (the directory has not changed). All variables previously
% stored in the file are still stored (to ensure compatibility with older
% functions) and the variables meanStats and medianStats are added.
% 
% NOTE: The functions that use FB stats need to be updated to work with
% this new system!!! Particularly those that look at FB excursions
% 

funcname = 'genFBStats.m';
display(sprintf('Function: %s START',funcname))
fstart = now;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FROM fbmedian.m
% 
% =========================================================================
% Setup global and computed parameters
% =========================================================================
% MATLAB_TIME  = 1;		% Use matlab time stamps.
% READ_IN      = 1;		% Read in data, used when data is already loaded ie during testing
% CLEAN_DATA   = 0;		% Removes data from stat calcs that is greater than 5*Std
PREFIX       = 'summary'; 	% Prefix for the stat files.

END_DATE     = floor(now);

% % Load generic, all-network environment variables
% [status, CMN_OUTPUT_ROOT] = system( 'echo -n $CMN_OUTPUT_ROOT' );
% if( isempty( CMN_OUTPUT_ROOT ) )
%     display( 'env must contain CMN_OUTPUT_ROOT variable' );
%     return
% end
% [status, BK_OUTPUT_ROOT] = system( 'echo -n $BK_OUTPUT_ROOT' );
% if( isempty( BK_OUTPUT_ROOT ) )
%     display( 'env must contain BK_OUTPUT_ROOT variable' );
%     return
% end
% [status, BKQ_OUTPUT_ROOT] = system( 'echo -n $BKQ_OUTPUT_ROOT' );
% if( isempty( BKQ_OUTPUT_ROOT ) )
%     display( 'env must contain BKQ_OUTPUT_ROOT variable' );
%     return
% end

% Load nework-specific environment variables.
network = upper(network);
% if ( strcmpi( network, 'CMN' ) )
% 	FBdir = sprintf('%s/fbs', CMN_OUTPUT_ROOT );
% 	nBands     = 14;                                % 13 ma 
% 	START_DATE = datenum('01-January-2005');
% elseif ( strcmpi( network, 'BK' ) )
% 	FBdir = sprintf('%s/fbs', BK_OUTPUT_ROOT );
% 	nBands     = 14;                                % 13 ma 
% 	START_DATE = datenum('01-January-1995');
% elseif ( strcmpi( network, 'BKQ' ) )
% 	FBdir = sprintf('%s/fbs-quiet', BKQ_OUTPUT_ROOT );
% 	[nBands t1] = getFBUpperFreqs(0);                %#ok<NASGU> % 13 ma 
%     START_DATE = datenum('01-January-1995');
% else
% 	error( 'Invalid network name: %s', network );
% end

hr_offset= 8;   % offset by 8 hrs from UT
weHaveData   = false;
emptyDayDate = false;
% eData = 0;

% Site Input
% Site
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




%ADDED BECAUSE site WAS NOT DEFINED WHEN RUNNING SCRIPT FOR NEW SITES
site=str2double(SID);
%ADDED BECAUSE site WAS NOT DEFINED WHEN RUNNING SCRIPT FOR NEW SITES




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
siteName = getStationName(siteFN); %#ok<NASGU>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% NEW/MODIFIED CODE USED FOR THIS FUNCTION!

% Load Environmental Variables
[fbDir fbStatDir kpTxtFileName kpMatFileName] = fbLoadEnvVar( network );
% [fbDir,fbStatDir,kpTxtFileName,kpMatFileName,fbExcurDir,fbExcurPointsDir,fbExcurPlotDir,fbExcurLogDir,fbLimitDir] = fbLoadExcurEnv(network);
if( strcmpi(fbDir,'ERROR') )
    display('Problem loading environment variables')
    display('ENVIRONMENT')
    success = -1;
    return
end
FBdir = fbDir;
% MUST UPDATE fbStatDir!!!

% Dimension Sizes
nTOD    = 96;   % 96 half-hour periods in day taken every 15 minutes.
nSeason = 4;    % sum,aut,win,spr
nKp     = 4;    % 4 Kp subdivisions, 1-2,3-4,5-6, >6 
nBands  = 14;   % 13 bands and 1 "summary" band
nCh     = 3;    % number of coils, 4th channel for polarity

nPars    = 6;   % Parameters:
                % 1. average    2. standard deviation
                % 3. median     4. q1 (25%)
                % 5. q3 (75%)   6. number of samples
nMeanCols = 3;
nMedianCols = 102;

% Data matrices
stats     = zeros(nTOD,nBands,nCh+1,nSeason,nKp,nPars);   % averaged data
meanStats = zeros(nTOD,nBands,nCh+1,nSeason,nKp,nMeanCols);
medianStats = zeros(nTOD,nBands,nCh+1,nSeason,nKp,nMedianCols);

Sr      = zeros(nTOD,nBands+1,nCh+1);                    % one day, 3 B-fields
kp_tmp  = zeros(nTOD,1);                            % kp array.
dataTimeSeries    = [ ];
% pol     = [ ];
season  = [ ];
kp_arr  = [ ];
% eDataTimeSeries  = [ ];
% eKp_arr          = [ ];
% eSeason          = [ ];

trashArray4 = -1*ones(nTOD,nBands+1,nCh+1); % arrays used for filling in data


% Load Kp Values
display('Loading kp mat file.')
cmd = sprintf('load %s kp kpdtnum', kpMatFileName );
eval( cmd );
kpdtnum = kpdtnum - hr_offset/24; %#ok<NODEF> % adjust for 8 hr time diffence in our analysis, PST





%ADDED SO IF ~useMatFile, THE CODE KNOWS WHAT THE START DATE IS
START_DATE=siteInfo.first_data_start;
%ADDED SO IF ~useMatFile, THE CODE KNOWS WHAT THE START DATE IS





% Use Existing Stats/Data?

if( useMatFile )
    try
        % Load mat file and change file names
        display('Loading FB .mat file.')
        cmd = sprintf( 'load %s/%s-%s.mat', fbStatDir, PREFIX, siteStr );
        eval( cmd );
        cmd = sprintf( 'dataTimeSeries  = data%s;', siteStr ); eval( cmd );
        cmd = sprintf( 'kp_arr  = kp_arr%s;', siteStr ); eval( cmd );
        cmd = sprintf( 'season  = season%s;', siteStr ); eval( cmd );
        
        % Get last date of data by looking at the time stamp of the 2nd to last
        % data value.  The last time state may actually have the next day's date
        % so we use the second to last one.
        t1 = size( dataTimeSeries );
        START_DATE = dataTimeSeries( t1(1)-1, 1, 1 ) + 1;
        weHaveData = 1;
    catch
        display('.mat data file not found, using default start date');

   
        
        
        
%ADDED SO IF ~useMatFile, THE CODE KNOWS WHAT THE START DATE IS
START_DATE=siteInfo.first_data_start;
%ADDED SO IF ~useMatFile, THE CODE KNOWS WHAT THE START DATE IS
 




    end
end % if useMatFile

%START_DATE=datenum('2010/03/30')
%site=704
%%site=siteID;

% Date Range
display( [ 'Start date: ', datestr(START_DATE,31) ] );
display( [ 'End date: ', datestr(END_DATE,31) ] );
if( END_DATE < START_DATE )
    display('Data up to date')
    display('SUCCESS')
    success = 0;
    return
end

% Loop over Date Range
for iDay = START_DATE:END_DATE
	% Get year, month, day
	yi = datestr( iDay, 'yyyy' );
	mi = datestr( iDay, 'mm' );
	di = datestr( iDay, 'dd' );

	% Get Season 
	% 	1=sum(6,7,8); 2=aut(9,10,11); 3=win(12,1,2); 4=spr(3,4,5)
	si = ceil( (mod(str2double(mi)+6,12)+1)/3 ); 

	disp([ 'Now doing yr: ', yi, ', month: ', ...
	        mi,', day: ', di, ' (season ',num2str(si),') ', sprintf('%f',iDay) ] );

	% get nKp for this & next day (one FB file goes over 2 days)
	thisdaynum = iDay;
	kpi = find( (kpdtnum >= thisdaynum) & (kpdtnum <= (thisdaynum+2)) ); %#ok<NASGU>

	% Loop over channels
    % (Note bt is legacy for channel.  BK channels are called BT* for B-field data.
	% Need to run through all bt's first so we have them ready
	% and can calc polarisation (below)
	ex = zeros(nCh,1);    % whether bt1,bt2,bt3 files exist
	anyempty=false;         % are any files empty? 0=no,1=yes
    for bi = 1:nCh,
        % File name for FB Data
        if ( strcmpi( network, 'CMN' ) )
            % siteCell = getStationInfo({network},1,1,'SID',site,'NAME');
            % siteName = siteCell{1};
            % siteName = siteNamesNOWS(site); % use this temporarily! use above when getStationInfo is fully implemented!
            filename = sprintf('%s/%s/CHANNEL%d/%s%02s%02s.CMN.%d.%02d.fb', ...
                FBdir, siteFN,bi,yi,mi,di,site,bi );
        elseif ( strcmpi( network, 'BK' ) )
            filename = sprintf('%s/%s/BT%d/BK_%s_BT%d_%d_%02d_%02d.fb',...
                FBdir, siteFN, bi, site, bi, yi, mi, di);
        elseif ( strcmpi( network, 'BKQ' ) )
            filename = sprintf('%s/%s/BT%d/BK_%s_BT%d_%d_%02d_%02d.fb',...
                FBdir, siteFN, bi, site, bi, yi, mi, di);
        end
        
        % if filename exists - read it
        ex(bi) = exist(filename,'file');
        if( ex(bi) )
            S  = textread(filename,'', 'headerlines', 1);
            if( ~isempty(S) )
                [Srow,Scol] = size(S);
                % Srow = size(S,1);
                if( Scol == nBands + 1 )
                    Sr(:,:,bi) = S(1:Srow,:); %cols:t,ma1...ma13,rms
                else % UPDATE DATA IF FULL SET IS NOT AVAILABLE!
                    [fbs] = fbcalc( datestr(iDay,'yyyy/mm/dd'), network, num2str(site), bi, 'qfdc', filename ); %#ok<NASGU>
                    S = textread(filename,'', 'headerlines', 1);
                    if( ~isempty(S) )
                        [Srow,Scol] = size(S);
                        if( Scol == nBands + 1 ) % data updated - SUCCESS!
                            Sr(:,:,bi) = S(1:Srow,:); %cols:t,ma1...ma13,rms
                        else % data not fully updated - BOO!
                            Sr(:,1:Scol,bi) = S(1:Srow,1:Scol); %cols:t,ma1...ma13,rms
                        end
                    else % Now data is empty? Things really got screwed up here!
                        anyempty = true;
                    end
                end

                % 				if ~MATLAB_TIME,
                % 					Sr(:,1,bi)= datenum(1970,1,1) + ...
                % 					Sr(:,1,bi)/86400 - hr_offset/24+1e-5;
                % 				end
            else
                try % Try to get data for that channel
                    [fbs] = fbcalc( datestr(iDay,'yyyy/mm/dd'), network, num2str(site), bi, 'qfdc', filename ); %#ok<NASGU>
                    S = textread(filename,'', 'headerlines', 1);
                    if( ~isempty(S) )
                        [Srow,Scol] = size(S);
                        if( Scol == nBands + 1 ) % data updated - SUCCESS!
                            Sr(:,:,bi) = S(1:Srow,:); %cols:t,ma1...ma13,rms
                        else % data not fully updated - BOO!
                            Sr(:,1:Scol,bi) = S(1:Srow,1:Scol); %cols:t,ma1...ma13,rms
                        end
                    else
                        anyempty = true;
                    end
                catch
                    anyempty = true;
                end
            end %
        else
            display (['  Does not exist: ' filename]);
        end % if ex(bi) ... filename exists, read it, etc.
    end % for bi = 1:nCh
            
	if( (sum(ex) >= nCh) && ~anyempty )
        for jj=1:nTOD
            thisKp = kp(closest(kpdtnum,Sr(jj,1,1)));
            if( ~isempty(thisKp) )
                switch floor(thisKp),
                    case {0,1}
                        kp_tmp(jj) = 1;
                    case {2,3}
                        kp_tmp(jj) = 2;
                    case {4,5}
                        kp_tmp(jj) = 3;
                    case {6,7,8,9}
                        kp_tmp(jj) = 4;
                end % switch
            end % if( ~isempty(thisKp) )
        end % jj=1:ntod

		% Check if we need to prepend some empty data.
		if( emptyDayDate )
			for jDay = emptyDayDate:(iDay-1)
				display( ['  Appending empty data: ' num2str(jDay) ] );
				trashArray4(:,1,1) = (1:96)/96 + jDay;
				trashArray4(:,1,2) = (1:96)/96 + jDay;
				trashArray4(:,1,3) = (1:96)/96 + jDay;
				trashArray4(:,1,4) = (1:96)/96 + jDay;
				% Append empty data, kp_arr, season
				dataTimeSeries = [ dataTimeSeries ; trashArray4 ];
				kp_arr = [ kp_arr; kp_tmp ];
				season = [ season; si*ones(nTOD,1) ];
				emptyDayDate = 0;
			end % for jDay = emptyDayDate:(iDay-1)
		end % if( emptydayDate )

		kp_arr = [ kp_arr; kp_tmp ];    
		season = [ season; si*ones(nTOD,1) ];
		pol = (Sr(:,:,3)./sqrt(Sr(:,:,1).^2 + Sr(:,:,2).^2));
		Sr(:,:,4) = pol;
		dataTimeSeries = [ dataTimeSeries; Sr ];               
		weHaveData = true;
	else    
		% We don't have a full set of data.  We could stuff zeros, but we only
		% want to do this if we have data left to load in (ie there is still data
		% to process).  So let's keep track of the first day of no data, and we'll
		% load in zero data at a later time IF we find a valid day after this.
		
		if( weHaveData && ~emptyDayDate )
			display( ['  Creating empty data: ', num2str(iDay) ]);
			emptyDayDate = iDay;
		end
	end % if( (sum(ex) > 5) && ~anyempty )
end %for iDay = START_DATE:END_DATE

% Clean Data
% display('Removing NaN values - replacing with median value')
% for iBand = 2:nBands+1,
%     for iCh = 1:nCh+1,
%         badind = isnan(dataTimeSeries(:,iBand,iCh));
%         dataTimeSeries(badind,iBand,iCh) = median( dataTimeSeries(~badind,iBand,iCh) );
%     end
% end

if( cleanDataLevel )
	display(['Cleaning data with level: ' cleanDataLevel ] );
	for iBand = 2:nBands+1,
		for iCh = 1:nCh+1,
			badind = dataTimeSeries(:,iBand,iCh) > cleanDataLevel*std(dataTimeSeries(:,iBand,iCh));
			dataTimeSeries(badind,iBand,iCh) = median( dataTimeSeries(:,iBand,iCh) );
		end, % for iCh
	end, % for iBand
end % if cleanDataLevel

% =========================================================================
% --------- Sort data ----------
% This section runs through all the data stored in variable "data", and
% sorts it according to:
% 	1. Time of day (96 half-hour periods)
% 	2. FB index (13 indices)
% 	3. Coil number (bt1-3 + polarization)
% 	4. Season (1-4)
% 	5. Kp (1-4)
% 	6. Param (1-6, ave, stddev, median, 25%, 75%, number of samples)
% =========================================================================

% Get date as vector, clean it up.  Sometimes there is a rounding error and
% we're off by a second.  Need to clean it up.
dt = datevec( dataTimeSeries(:,1,1) );

% Fix 14:59, 29:59, 44:59
ff = find( dt(:,6)>55 & dt(:,5) < 59  );
dt(ff,5) = dt(ff,5)+1;
dt(ff,6) = 0;

% Fix 59:59
ff = find( dt(:,6)>55 & dt(:,5) > 58  );
dt(ff,6) = 0;
dt(ff,5) = 0;
dt(ff,4) = dt(ff,4)+1;

% Main loop: go through all bins
% fyi: dat = zeros(ntod,nma,nbt+1,nseason,nkp,pars);  
for iTOD = 1:nTOD
    thish = floor((iTOD-1)/4);
    switch mod( (iTOD-1), 4),
    	case 0,
		thismin = 0;
    	case 1,
		thismin = 15;
    	case 2,
		thismin = 30;
    	case 3,
		thismin = 45;
    end
    	
%     if( 0 )
%         if( mod((iTOD-1),2) )
%             thismin = 45;
%         else
%             thismin = 15;
%         end
%     end
    
    disp(['Hour ',num2str(thish),', Min ',num2str(thismin)]);
    
    for iBand = 1:nBands,     
        for iCh = 1:nCh+1,      % 3 bt coils + pol   
            for isea = 1:nSeason,   
                for ikp = 1:nKp,
                    % Try to find matching indices.  This throws an error if there are empty matrices
                    % in the find statements, so it is wrapped in a try statement.
                    try
                        ind = find( dt(:,4) == thish & ...
                            dt(:,5) == thismin & ...
                            season == isea & ...
                            kp_arr == ikp);
                    catch
                        ind = [ ];
                    end

                    % Get relevant data
                    vals = dataTimeSeries(ind, iBand+1, iCh);
                    vals( isnan(vals) ) = [ ];
                    vals = sortrows(vals); % sort data to generate percentiles
                    
                    if( ~isempty(vals) )
                        nVals = size(vals,1);
                        
                        % Generate stats
                        % 1. Mean
                        stats(iTOD,iBand,iCh,isea,ikp,1) = mean(vals);
                        % 2. Standard deviation
                        stats(iTOD,iBand,iCh,isea,ikp,2) = std(vals);  
                        % 3. Median
                        stats(iTOD,iBand,iCh,isea,ikp,3) = median(vals);   
                        % 4. q1: 25th percentile
                        stats(iTOD,iBand,iCh,isea,ikp,4) = ...
                            median(vals( vals < median(vals) ));
                        % 5. q3: 75th percentile
                        stats(iTOD,iBand,iCh,isea,ikp,5) = ...
                            median(vals( vals > median(vals) )); 
                        % 6. Number of data points
                        stats(iTOD,iBand,iCh,isea,ikp,6) = nVals; 
                        
                        % Generate meanStats
                        meanStats(iTOD,iBand,iCh,isea,ikp,1) = nVals;
                        meanStats(iTOD,iBand,iCh,isea,ikp,2) = mean(vals);
                        meanStats(iTOD,iBand,iCh,isea,ikp,3) = std(vals);
                        
                        % Generate medianStats
                        medianStats(iTOD,iBand,iCh,isea,ikp,1) = nVals;
                        pcts = zeros(nVals,1);
                        for iVal = 1:nVals
                            pcts(iVal,1) = 100/nVals*(iVal-0.5);
                        end % for iVal = 1:nVals
                        for iPct = 0:100
                            if( iPct < pcts(1,1) )
                                medianStats(iTOD,iBand,iCh,isea,ikp,iPct+2) = vals(1,1);
                            elseif( iPct > pcts(nVals,1) )
                                medianStats(iTOD,iBand,iCh,isea,ikp,iPct+2) = vals(nVals,1);
                            elseif( nVals == 1 )
                                medianStats(iTOD,iBand,iCh,isea,ikp,iPct+2) = vals(nVals,1);
                            else
%                                 inds = find( (pcts <= iPct) & (pcts >= iPct) );
%                                 if( size(inds,1) == 1 )
%                                     medianStats(iTOD,iBand,iCh,isea,ikp,iPct+2) = ...
%                                         vals(inds,1);
%                                 else
%                                     medianStats(iTOD,iBand,iCh,isea,ikp,iPct+2) = ...
%                                         vals(inds(1,1),1) + (iPct - pcts(inds(1,1),1))/(pcts(inds(2,1),1) - pcts(inds(1,1),1))*(vals(inds(2,1),1)-vals(inds(1,1),1));
%                                 end
                                inds = [ ];
                                for iVal = 1:nVals-1
                                    if( (pcts(iVal,1) <= iPct) && (pcts(iVal+1,1) >= iPct) )
                                        inds = [iVal;iVal+1];
                                    end
                                end
                                medianStats(iTOD,iBand,iCh,isea,ikp,iPct+2) = ...
                                    vals(inds(1,1),1) + (iPct - pcts(inds(1,1),1))/(pcts(inds(2,1),1) - pcts(inds(1,1),1))*(vals(inds(2,1),1)-vals(inds(1,1),1));
                            end
                        end % for iPct = 0:100
                    else
                        %txt=sprintf('Empty at: ikp=%d, isea=%d, ibt=%d, ima=%d, itod=%d',...
                        %    ikp,isea,ibt,ima,itod);
                    
                        %disp(txt);
                    end % if( ~isemmpty(vals) )
                end % for ikp=1:nKp
            end % for isea=1:nSeason
        end % for iCh=1:nCh+1
    end % for iBand =1:nBands
end % for iTOD=1:nTOD


% Generate fbmedian command, and save command based on network
filename = sprintf('%s',fbStatDir);
filename = [filename sprintf('/summary-%s.mat',siteStr)];
cmd = sprintf('data%s = dataTimeSeries; kp_arr%s = kp_arr; season%s = season; stats%s = stats; meanStats%s = meanStats; medianStats%s = medianStats;', ...
    siteStr,siteStr,siteStr,siteStr,siteStr,siteStr);
saveCMD = sprintf('save %s data%s stats%s kp_arr%s season%s meanStats%s medianStats%s', ...
    filename,siteStr,siteStr,siteStr,siteStr,siteStr,siteStr);

% Save results to .mat file
try
    display(sprintf('Saving Stats .mat file: %s',filename))
    display(saveCMD)
    eval(cmd)
    eval(saveCMD)
    display('Stats .mat file saved')
catch
    display('Error saving Stats .mat file');
    display('BAD_WRITE')
    success = -1;
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fend = now;
delta = (fend - fstart)*86400;
display(sprintf('%s Run Time: %d',funcname,delta))
display(sprintf('Function: %s END',funcname))

success = 0;
display('SUCCESS')

return
