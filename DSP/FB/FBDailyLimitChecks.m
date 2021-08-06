function osT = FBDailyLimitChecks( network, site, channels, bands, startDate, endDate, multipliers, fileName )
%
%
% Limit checks on quarter tiles. 
%
% Function Inputs:
%     network  - network of the site
%     site     - name/number of the site
%     channels - which channels to limit check
%     bands    - which bands to limit check
%     day      - which day to check 'yyyy/mm/dd'
%     multipliers - 2 element array, 75th quartile is first, then 25th quartile
%
% Flat file outputs:
%	- StartTime           Start time of the limit excursion.
%	- StartTimeMS         Start time in ms of the limit excursion.
%	- EndTime             End time of the excursion.
%	- EndTimeMS           End time in ms of the excursion.
%	- Duration            Duration of the excursion
%	- EventType           FB_DAILY_LIMIT_CHECK
%	- SubEventType        GREATER_THAN or LESS_THAN
%	- EventVersion        UNK (replaced by bash script calling this)
%	- EventSource         FBDailyLimitChecks.m
%	- DataSourceNetwork   'network'
%	- DataSourceStation   'site'
%	- DataSourceChannel   'channel'
%	- CreationTime        Current time of code execution.
%	- Maximum             Maximum of the excursion (could be a min of LESS_THAN)
%	                      abs(signal - reference)                         
%	- Reference           The reference level used (allows us to calculate the delta)
%	- InferredStart       If the day starts with an excursion, infer that it started earlier
%	- InferredEnd         If the day end with an excursion, infer that it stop later 

% Todo:
%	- See the jwc/todos below in the code.
%
% Limitations
%  - Currently CMN centric.  Needs to be fixed to use BK.
%  - Do we want to do more than one check?

OUTPUTTOSCREEN = 1;

% Perform input checks.
if ( length(multipliers) ~= 2 )
	display( sprintf( 'ERROR: invalid number of multiplies.  2 are required.' ) );
	return
end


% Load in state files, based on network
[fbDir fbStatDir kpTxtFileName kpMatFileName] = fbLoadEnvVar( network );

% Load in the stat files for the site.  Rename the variables from the
% summary files to use generic names, not ones with site numbers in them
display ('Loading stat data');
eval( sprintf( 'load %s/summary-%d.mat', fbStatDir, site) );
eval( sprintf( 'stats = stats%d;', site ) );


% Convert a string date to 
sd  = datenum( startDate, 'yyyy/mm/dd' );
ed  = datenum( endDate,   'yyyy/mm/dd' );
nd = ed - sd + 1;

% Load and build the data we need.
display ('Loading FB data');
[ data1 data2 data3 data4 ] = loadFBDataSB( sd, ed, network, site, channels, 1 );
display ('Building stat time series');
statTS = buildStatTimeSeries( sd, ed, stats, kpMatFileName );

% Extract the time array, and squeeze to the right size to get rid of 
% an extra, empty columns.
time = squeeze( data1(:,1, 1) );

% Now we loop through the bands and the channels to do limit checks
for band=bands,
	for channel=channels,

	% Get data 
	d1 = squeeze( data1(:,band+1,channel) );

	% Get quarter data
	q2 = statTS( :, band, channel, 3 );
	q3 = statTS( :, band, channel, 5 );

	% Remove NaN from the stats and replace with median value.
	% Occasionally, there are sets of parameters that don't have stats
	% b/c our data set is limited.
	q3Global = median( q3 );        % Calc quartile median
	inds3 = find( isnan(q3) > 0 );  % Find where quartiles are NaN
	q3(inds3) =q3Global;            % Replace NaN with median

	q2Global = median( q2 );        % Calc quartile median
	inds2 = find( isnan(q2) > 0 );  % Find where quartiles are NaN
	q2(inds2) =q2Global;            % Replace NaN with median

	inds = find( isnan(d1) > 0 );   % Find NaN in the data set
	d1(inds) = q2(inds);            % Replance NaN with medians


	% Print output header
	osT{1} = printEventHeader( OUTPUTTOSCREEN );

	% Do greater than check
	ref = q3*multipliers(1);
	[diff diffZ diffZN] = limitcheck( d1, ref, 'GREATERTHAN' );
	[noe, os1] = processLCDiff( network, site, channel, band, time, diffZ, ref, 'ABOVE_75TH', OUTPUTTOSCREEN );
	osT = [ osT os1 ];

	% Do less than check
	ref = q2*multipliers(1);
	[diff diffZ diffZN] = limitcheck( d1, ref, 'LESSERTHAN' );
	processDiff( network, site, channel, band, time, diffZ, ref, 'BELOW_25TH', OUTPUTTOSCREEN );
	[noe, os2] = processLCDiff( network, site, channel, band, time, diffZ, ref, 'BELOW_25TH', OUTPUTTOSCREEN );
	osT = [ osT os2 ];

	plot(time,d1, time, q3*multipliers(1), time, q2*multipliers(2) );

	% Clear the used variables
	clear d1, q2, q3, inds2, inds3, ref;

	end % for channel=CHANNELS,
end % for band=BANDS,

% jwc working here
if ( length(fileName) > 0 )

   	display( 'Writing file.' );

	fid = fopen( fileName, 'w' );
	for ith=1:length(osT)
		fprintf( fid, '%s\n', osT{ith} );
	end % for ith=1:length(osT)
	fclose( fid );

end % if fileName,

return


%===============================================================================
%function plotTestFig( a, b, c )
%===============================================================================

%	figure
%	hold on
%	plot( a, 'r' )
%	plot( b,'g' )
%	plot( c,'b' )
%	set(get(gcf,'CurrentAxes'),'YScale','log' );
%	hold off
%	return

%===============================================================================
%===============================================================================
