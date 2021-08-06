function [dataTimeSeries stats kp_arr season ] = fbmedian( site, network, useMatFile, cleanDataLevel )
% FBmedian.m -- Reads and computes stat quantities for the filter bank
% files calculated filter bank code.
%
% Arugments:
%    site       - site ID, three digit number for CMN or alpha code for BK (i.e. PKD)
%    network    - name of the network (BK, CMN)
%    useMatFile - 0, use txt files, > 0, use the mat file
%
% FBmedian takes in site and network as argument to calculate FB raw stats.
%
% Frequency bands:
% FB1: 0.001-0.002  FB2: 0.002-0.003
% FB3: 0.003-0.007  FB4: 0.007-0.010
% FB5: 0.010-0.022  FB6: 0.022-0.050
% FB7: 0.050-0.100  FB8: 0.100-0.200
% FB9: 0.200-0.500  FB10:0.500-1.000
% FB11:1.000-2.000  FB12:2.000-6.000
% FB13:6.000-10.00
%
% Statistics are stored in the variable "dat":
%	Col 1: Time of day, 
%	Col 2: FB band, 13
%	Col 3: Channel, 1-3 and Polarity
%	Col 4: Season, 4 values
%	Col 5: Kp groups, 4
%	Col 6: stat, 1=mean, 2=std, 3=median, 4=25th percentile, 5=75th percentile, 6=# of points
%
% Update log:
%	2008/01/14: Added ability to load in precomputed mat file to speed up calculations with
%	            new data. jwc.
%
%
% Upgrades needed:
%	1 Intelligently get start dates from DB rather than hard code them.
%	3 Reasses cleaning and how to use it.
%	5 Output individual time series for stats
%	6 Add RMS values to
%	8 Select start and end times.
%
% Work Log:
%	- Working 96 point upgrade.
%		- Chnaged ntod to 96.
%		- Where else does it come into play

%			
% Code originally developed by J. Bortnik, Fri. Nov. 11th 2005.
% Modified by J. Cutler, 09 Nov. 2006 to deploy in QFDC.
%
% $Id: fbmedian.m,v e202264be13b 2010/06/17 17:54:10 qcvs $

% =========================================================================
% Setup global and computed parameters
% =========================================================================
MATLAB_TIME  = 1;		% Use matlab time stamps.
READ_IN      = 1;		% Read in data, used when data is already loaded ie during testing
CLEAN_DATA   = 0;		% Removes data from stat calcs that is greater than 5*Std
PREFIX       = 'summary'; 	% Prefix for the stat files.

END_DATE     = floor(now);

% Load generic, all-network environment variables
[status, CMN_OUTPUT_ROOT] = system( 'echo -n $CMN_OUTPUT_ROOT' );
if( length( CMN_OUTPUT_ROOT ) == 0 )
        display( 'env must contain CMN_OUTPUT_ROOT variable' );
        return
end
[status, BK_OUTPUT_ROOT] = system( 'echo -n $BK_OUTPUT_ROOT' );
if( length( BK_OUTPUT_ROOT ) == 0 )
        display( 'env must contain BK_OUTPUT_ROOT variable' );
        return
end
[status, BKQ_OUTPUT_ROOT] = system( 'echo -n $BKQ_OUTPUT_ROOT' );
if( length( BKQ_OUTPUT_ROOT ) == 0 )
        display( 'env must contain BKQ_OUTPUT_ROOT variable' );
        return
end

% Load nework-specific environment variables.
if ( strcmp( network, 'CMN' ) )
	FBdir = sprintf('%s/fbs', CMN_OUTPUT_ROOT );
	nma     = 13;                                % 13 ma 
	START_DATE = datenum('01-January-2005');
elseif ( strcmp( network, 'BK' ) )
	FBdir = sprintf('%s/fbs', BK_OUTPUT_ROOT );
	nma     = 13;                                % 13 ma 
	START_DATE = datenum('01-January-1995');
elseif ( strcmp( network, 'BKQ' ) )
	FBdir    = sprintf('%s/fbs-quiet', BKQ_OUTPUT_ROOT );
	[nma t1] = getFBUpperFreqs(0);                % 13 ma 
	START_DATE = datenum('01-January-1995');
else
	error( sprintf('Invalid network name: %s', network ) );
end

[fbDir fbStatDir kpTxtFileName kpMatFileName] = fbLoadEnvVar( network );

bt      = [1:3];                % 3 search coils 
nbt     = length(bt);

ntod    = 96;   % 96 half-hour periods in day taken every 15 minutes.
nseason = 4;    % sum,aut,win,spr
nkp     = 4;    % 4 Kp subdivisions, 1-2,3-4,5-6, >6 
pars    = 6;    % Parameters:
                % 1. average    2. standard deviation
                % 3. median     4. q1 (25%)
                % 5. q3 (75%)   6. number of samples
hr_offset= 8;   % offset by 8 hrs from UT
weHaveData   = 0;
emptyDayDate = 0;
eData = 0;
%ntot     = (END_DATE - START_DATE) * ntod;

% Data matrices
stats     = zeros(ntod,nma,nbt+1,nseason,nkp,pars);   % averaged data
Sr      = zeros(ntod,nma+1,nbt+1);                    % one day, 3 B-fields
kp_tmp  = zeros(ntod,1);                            % kp array.
%data   = zeros(ntot, nma+1, nbt);
%pol    = zeros(ntot, nma+1);
%season = zeros(ntot, 1);
%kp_arr = zeros(ntot, 1);
dataTimeSeries    = [];
pol     = [];
season  = [];
kp_arr  = [];
eDataTimeSeries  = [];
eKp_arr          = [];
eSeason          = [];

emptyArray4 = ones(ntod,nma+1,nbt+1)*-1; % Empty arrays used for filling in data

if READ_IN,

% =========================================================================
% -----  Read in Kp values ---
% =========================================================================
if ~exist('kp'),
	display('Loading kp mat file.')
	cmd = sprintf('load %s;', kpMatFileName );
	eval( cmd );
	% adjust for 8 time diffence in our analysis, PDT
	kpdtnum = kpdtnum - 8/24;

	% Old code from jacob for reading the kp text files (too slow)
	%[kpdate,kptime,kp10,kpstatus] = textread(kpfilename, '%s %s %f %s');
	%kpsp    = char(32*ones(size(kpdate))); % vert. array of spaces
	%kpdt    = datevec([cell2mat(kpdate) kpsp cell2mat(kptime)]);
	%kpdtnum = datenum( kpdt );
	%kp      = kp10/10;  % div by 10 to get it to proper Kp value
end

% =========================================================================
% ------------------- Read in all FB indices -------------
% =========================================================================

if useMatFile,

   	try,
		% Load mat file and change file names
		display('Loading FB mat file.')
		if ( strcmp( network, 'CMN' ) )
			cmd = sprintf( 'load %s/%s-%d.mat', fbStatDir, PREFIX, site );
			display(cmd);
			eval( cmd );
			cmd = sprintf( 'dataTimeSeries  = data%d;', site );     eval( cmd );
			cmd = sprintf( 'kp_arr  = kp_arr%d;', site ); eval( cmd );
			cmd = sprintf( 'season  = season%d;', site ); eval( cmd );
		else
			cmd = sprintf( 'load %s/%s-%d.mat', fbStatDir, PREFIX, site );
			eval( cmd );
			cmd = sprintf( 'dataTimeSeries  = data%s;', site );     eval( cmd );
			cmd = sprintf( 'kp_arr  = kp_arr%s;', site ); eval( cmd );
			cmd = sprintf( 'season  = season%s;', site ); eval( cmd );
		end
	
		% Get last date of data by looking at the time stamp of the 2nd to last
		% data value.  The last time state may actually have the next day's date
		% so we use the second to last one.
		t1 = size( dataTimeSeries );
		START_DATE = dataTimeSeries( t1(1)-1, 1, 1 ) + 1;  
		weHaveData   = 1;

	catch,
		display('mat data file not found, using default start date');
	end

end % if useMatFile,

display( ['Start date: ', datestr(START_DATE,31) ] );
display( ['End date: ', datestr(END_DATE,31) ] );

if ( END_DATE < START_DATE )
		display ('Data up to date')
		return
end

%START_DATE=datenum('2010/03/30')

for ithDay=START_DATE:END_DATE

	% Get year, month, day
	yi = datestr( ithDay, 'yyyy' );
	mi = datestr( ithDay, 'mm' );
	di = datestr( ithDay, 'dd' );

	% Get Season 
	% 	1=sum(6,7,8); 2=aut(9,10,11); 3=win(12,1,2); 4=spr(3,4,5)
	si = ceil((mod(str2num(mi)+6,12)+1)/3); 

	disp([ 'Now doing yr: ', yi, ', month: ', ...
	        mi,', day: ', di, ' (season ',num2str(si),') ', sprintf('%f',ithDay) ] );

	% get nkp for this & next day (one FB file goes over 2 days)
	thisdaynum = ithDay;
	kpi = find((kpdtnum>=thisdaynum)&(kpdtnum<=(thisdaynum+2)));

	% (Note bt is legacy for channel.  BK channels are called BT* for B-field data.
	% Need to run through all bt's first so we have them ready
	% and can calc polarisation (below)
	ex = zeros(3,1);    % whether bt1,bt2,bt3 files exist
	anyempty=0;         % are any files empty? 0=no,1=yes

	for bi = 1:nbt,
                
		if ( strcmp( network, 'CMN' ) )
            if site<700;
			filename = sprintf('%s/CMN%d_%s%d/CHANNEL%d/%s%02s%02s.CMN.%d.%02d.fb', ...
			                   FBdir, site, siteNamesNOWS(site), site,bt(bi),yi,mi,di,site,bt(bi) );
            else
            filename = sprintf('%s/CMN%d_%s/CHANNEL%d/%s%02s%02s.CMN.%d.%02d.fb', ...
			                   FBdir, site, siteNamesNOWS(site),bt(bi),yi,mi,di,site,bt(bi) );
            end
		elseif ( strcmp( network, 'BK' ) )
			filename = sprintf('%s/%s/BT%d/BK_%s_BT%d_%d_%02d_%02d.fb',...
			                   FBdir, site, bt(bi), site, bt(bi), yi, mi, di);
		elseif ( strcmp( network, 'BKQ' ) )
			filename = sprintf('%s/%s/BT%d/BK_%s_BT%d_%d_%02d_%02d.fb',...
			                   FBdir, site, bt(bi), site, bt(bi), yi, mi, di);
		end

		% if filename exists - read it    
		ex(bi) = exist(filename,'file');
		if ex(bi),
			%display (['Exists: ' filename]);
			S  = textread(filename,'', 'headerlines', 1);
			if ~isempty(S),
				[Srow,Scol] = size(S);
				Sr(:,:,bi)= S([1:1:Srow],:); %cols:t,ma1...ma13,rms
				if ~MATLAB_TIME,
					Sr(:,1,bi)= datenum(1970,1,1) + ...
					Sr(:,1,bi)/86400 - hr_offset/24+1e-5;
				end
			else
				anyempty=1;
			end % 
		else
		    display (['  Does not exist: ' filename]);
		end % if ex(bi) ... filename exists, read it, etc.
                
	end     % bi
            
	if sum(ex)>5 & ~anyempty , 

		for jj=1:ntod,
			thisKp = kp(closest(kpdtnum,Sr(jj,1,1)));
			if ~isempty(thisKp)
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
			end     % if ~isempty(thisKp)
	                
		end % jj=1:ntod

		% Check if we need to prepend some empty data.
		if emptyDayDate,
			for jthDay=[emptyDayDate:(ithDay-1)]
				display( ['  Appending empty data: ' num2str(jthDay) ] );
				emptyArray4(:,1,1) = (1:96)/96 + jthDay;
				emptyArray4(:,1,2) = (1:96)/96 + jthDay;
				emptyArray4(:,1,3) = (1:96)/96 + jthDay;
				emptyArray4(:,1,4) = (1:96)/96 + jthDay;
				% Append empty data, kp_arr, season
				dataTimeSeries = [ dataTimeSeries ; emptyArray4 ];
				kp_arr          = [ kp_arr; kp_tmp ];
				season          = [ season ; (ones(ntod,1)*si) ];
				emptyDayDate = 0;
			end % for jthDay=emptyDayDate:ithDay
		end % if ~emptydayDate

		kp_arr = [ kp_arr ; kp_tmp ];    
		season = [ season ; (ones(ntod,1)*si) ];
		pol = [(Sr(:,:,3)./sqrt(Sr(:,:,1).^2+Sr(:,:,2).^2))];
		Sr(:,:,4)  = pol;
		dataTimeSeries = [ dataTimeSeries ; Sr ];               
		weHaveData = 1;
	else    
		% We don't have a full set of data.  We could stuff zeros, but we only
		% want to do this if we have data left to load in (ie there is still data
		% to process).  So let's keep track of the first day of no data, and we'll
		% load in zero data at a later time IF we find a valid day after this.
		
		if weHaveData && ~emptyDayDate,
			display( ['  Creating empty data: ', num2str(ithDay) ]);
			emptyDayDate = ithDay;
			% Create time for empty array
			%tStamps = (1:96)/96 + ithDay;
			%emptyArray4(:,1,1) = tStamps;
			%emptyArray4(:,1,2) = tStamps;
			%emptyArray4(:,1,3) = tStamps;
			%emptyArray4(:,1,4) = tStamps;
			% Append data 
			%eDataTimeSeries  = [ eDataTimeSeries; emptyArray4];
			%eKp_arr          = [ kp_arr; kp_tmp ];
			%eSeason          = [ season ; (ones(ntod,1)*si) ];
			%eData = 1;
		end
	end    % if sum(ex)>5

end %for di=START_DATE:END_DATE

end     % if READ_IN

% =========================================================================
% --------- Clean data -----------
% A lot of the channals have period where the signal jumps by orders of
% magnitude which affects all the stats.  We want to get rid of those 
% values beforehand.
% =========================================================================
display('Removing NaN values - replacing with median value')
for ima = 2:nma+1,
    for ibt = 1:nbt+1,
        badind = isnan(dataTimeSeries(:,ima,ibt));
        dataTimeSeries(badind,ima,ibt) = median( dataTimeSeries(~badind,ima,ibt) );
    end
end

if cleanDataLevel,
	display(['Cleaning data with level: ' cleanDataLevel ] );
	for ima = 2:nma+1,
		for ibt = 1:nbt+1,
			badind = dataTimeSeries(:,ima,ibt) > cleanDataLevel*std(dataTimeSeries(:,ima,ibt));
			dataTimeSeries(badind,ima,ibt) = median( dataTimeSeries(:,ima,ibt) );
		end,    % for ibt
	end,    % for ima
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

%datestr(data(:,1,1),31 )
%datestr(dt,31)

% Main loop: go through all bins
%
% fyi: dat = zeros(ntod,nma,nbt+1,nseason,nkp,pars);  
for itod = 1:ntod,
    
    thish = floor((itod-1)/4);
    switch mod( (itod-1), 4),
    	case 0,
		thismin = 0;
    	case 1,
		thismin = 15;
    	case 2,
		thismin = 30;
    	case 3,
		thismin = 45;
    end
    	
    if 0,
    if mod( (itod-1), 2),
        thismin = 45;
    else,
        thismin = 15;
    end
    end
    
    disp(['hour ',num2str(thish),', min ',num2str(thismin)]);
    
    for ima = 1:nma,     
        for ibt = 1:nbt+1,      % 3 bt coils + pol   
            for isea = 1:nseason,   
                for ikp = 1:nkp,
                     
                    % Try to find matching indices.  This throws an error if there are empty matrices 
		    % in the find statements, so it is wrapped in a try statement.
                    try,
                    	ind = find( dt(:,4)==thish & ...
                       	 	dt(:,5) == thismin & ...
                       	 	season == isea & ...
                       	 	kp_arr == ikp);
                    catch,
		    	ind = [];
                    end

		
			
                        
                    vals = dataTimeSeries(ind, ima+1, ibt);
                    vals(find(isnan(vals))) = [];
                    
                    
                    if ~isempty(vals),
                        
                        % 1. Mean
                        stats(itod,ima,ibt,isea,ikp,1) = mean(vals);

                        % 2. Standard deviation
                        stats(itod,ima,ibt,isea,ikp,2) = std(vals);  

                        % 3. Median
                        stats(itod,ima,ibt,isea,ikp,3) = median(vals);   

                        % 4. q1: 25th percentile
                        stats(itod,ima,ibt,isea,ikp,4) = ...
                            median(vals(find( vals<median(vals) )));

                        % 5. q3: 75th percentile
                        stats(itod,ima,ibt,isea,ikp,5) = ...
                            median(vals(find( vals>median(vals) ))); 
                        
                        % 6. Number of data points
                        stats(itod,ima,ibt,isea,ikp,6) = length(vals);                         

                    else
                        %txt=sprintf('Empty at: ikp=%d, isea=%d, ibt=%d, ima=%d, itod=%d',...
                        %    ikp,isea,ibt,ima,itod);
                    
                        %disp(txt);
                        
                    end % if ~isemmpty(vals)
                    
                    
                end % for ikp=1:nkp
            end     % for ns=1:nseason
        end % for ibt=1:nbt+1
    end     % for ima =1:nma
end,        % for itod=1:ntod

return
