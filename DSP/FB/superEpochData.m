
%
% Todo
% x Compare raw superposed, mean, median, cleaned
%	x Clean CMN data
% x Integrate BK data
%		x Plot data
%		x Clean BK data
% x Align on midnight vs eq time.
% x Plot a sites fb "sgram"
% - Do quiet FBs

% - Inputs
%	- # of days before
%	- # of days after
%
% - CONSTANTS
%	- # of values per day
%
% - Variables
% 	- stack:       "site number" band [ data ]
% 	- site names:  "site number" [ data ]
%
% - Load in data from stat variables.
% - Loop through sites
%	- Loop through eqs
%		if time of eq > time of last eq + window
%			Get eq time
%			Calculate start time
%			Calculate end time
%			Get data
%			Calculate residual from stats, ie remove median
%			Add to station running data
%			Add to station running residuals
clear

PREEQDAYS   = 1;
POSTEQDAYS  = 1;
VALSPERDAY  = 96;
NOFBANDS    = 14;
NOFCHANNELS = 4;
MINKS       = 10;
MAXDIS      = 30;
CLEANMULT   = 1;
BKSTATIONS  = { 'PKD', 'SAO', 'JRSC', 'PKD1' }
CMNSTATIONS = 10;
NOFSTATIONS = 14;
STARTSTATION = 11
FIDUCIAL    = 1; % 1 = eq time, 0 = midnight

%CMNSTATIONS = 0;
%NOFSTATIONS = 1;


% Get CMN station info from database;
cmnstations = SQLGetCMNStations();
if( ~ iscell(cmnstations) )
	error( 'No cmnstations found in database.' );
	return;
end % if( ~ iscell(cmnstations) )

% Precompute some parameters.
presamps  = PREEQDAYS  * VALSPERDAY;  % # of samples before eq.
postsamps = POSTEQDAYS * VALSPERDAY;  % # of samples after eq.
samps     = presamps + postsamps + 1; % Total # of samples.
nofstations = length( cmnstations );  % # of cmn stations
tx = (presamps*(-1):postsamps);       % Time axis for plots
%count = 0;                            % Number of points dropped in cleaning.

% Create arrays we'll be needed in epoch summations and comparisons.
stackedData    = zeros( NOFSTATIONS, samps, NOFBANDS, NOFCHANNELS );
stackedMeans   = zeros( NOFSTATIONS, samps, NOFBANDS, NOFCHANNELS );
stackedMedians = zeros( NOFSTATIONS, samps, NOFBANDS, NOFCHANNELS );
stdevs         = zeros( NOFSTATIONS, samps, NOFBANDS, NOFCHANNELS );
stdev          = zeros( samps, NOFBANDS, NOFCHANNELS );

% Dates for querying database
sd      = datenum( '1994/01/01 00:00:01', 'yyyy/mm/dd HH:MM:SS' );
sd      = datenum( '2006/01/01 00:00:01', 'yyyy/mm/dd HH:MM:SS' );
ed      = datenum( now );

% Loop through stations getting eqs and interesting data.
disp( 'Getting eq and fb data' );
for ith = STARTSTATION : NOFSTATIONS,

	% Set envrionment variables based on network.  We process CMN stations
	% first, then BK.
	if ( ith > CMNSTATIONS ),
		sName = BKSTATIONS{ith-CMNSTATIONS};
		[fbDir fbStatDir kpTxtFileName kpMatFileName] = fbLoadEnvVar( 'BK' );
	else
		station = cmnstations{ith};
		sName   = station.name;
		sid     = station.sid;
		[fbDir fbStatDir kpTxtFileName kpMatFileName] = fbLoadEnvVar( 'CMN' );
	end % if ( ith > CMNSTATIONS ),

	% Get earthquakes from database.
	earthquakes = SQLGetEpochEqs( sd, ed, MINKS, MAXDIS, sName );
	if( iscell(earthquakes) )

		numQuakes = length(earthquakes);
		display( sprintf('\n%s: %d', sName, numQuakes ) );

		% Load in data. data%d, kp_arr%d, season%d, stats%d
		disp( 'Loading data' );
		if ( ith > CMNSTATIONS ),
			cmd = sprintf( 'load %s/summary-%s.mat', fbStatDir, sName );
			eval( cmd );
			eval( sprintf( 'data = data%s;', sName ) );
			eval( sprintf( 'kp_arr = kp_arr%s;', sName ) );
			eval( sprintf( 'season = season%s;', sName ) );
			eval( sprintf( 'stats = stats%s;', sName ) );
		else,
			cmd = sprintf( 'load %s/summary-%d.mat', fbStatDir, sid );
			eval( cmd );
			eval( sprintf( 'data = data%d;', sid ) );
			eval( sprintf( 'kp_arr = kp_arr%d;', sid ) );
			eval( sprintf( 'season = season%d;', sid ) );
			eval( sprintf( 'stats = stats%d;', sid ) );
		end %if ( ith > CMNSTATIONS ),

		% Get length of data to make sure we don't run off the end of
		% the data arrays.
		ds  = size(data);
		dl  = ds(1);

		% Loop through earthquakes and extract site data
		for jth = 1 : numQuakes,

			eq = earthquakes{jth};
			str = sprintf( '%d %f %s ', jth, ...
						eq.value, datestr( eq.time,0) );
			disp( str );

			% Find the earthquake time index in the data.  Search through data for 
			% time stamps that are greater than the EQ time.  Grab the first one.
			et = find ( data(:,1,1) > eq.time, 1, 'first' );

			% Stack the data if we found a matching time stamp.
			if ( ~ isempty( et ) ),

				% Calculate start and stop indices of the data block.
				if ( FIDUCIAL == 1 ),
					kth = et - presamps;
					lth = et + postsamps;
				elseif ( FIDUCIAL == 0 ),
					midnight = floor( eq.time );
					ft = find ( data(:,1,1) > midnight, 1, 'first' );
					kth = ft - presamps;
					lth = ft + postsamps;
				else
					error( 'Invalid FIDUCIAL value' );
				end % if ( FIDUCIAL == 1 ),

				if ( kth > 0 && lth <= dl ),  % Check for valid indices.

					% Build Stat time series, this is tedious.
					for mth=kth:lth,

						stackedMeans(ith, mth-kth+1,(2:14),:) = ...
							squeeze( stats( floor(mod(mth,96)/2) + 1, :, :,  ...
							                season(mth), kp_arr(mth), 1 ) ) + ...
							squeeze( stackedMeans(ith, mth-kth+1,(2:14),:) );

						stackedMedians(ith, mth-kth+1,(2:14),:) = ...
							squeeze( stats( floor(mod(mth,96)/2) + 1, :, :,  ...
							                season(mth), kp_arr(mth), 3 ) ) + ...
							squeeze( stackedMedians(ith, mth-kth+1,(2:14),:) );

						stdev(mth-kth+1,(2:14),:) = ...
							squeeze( stats( floor(mod(mth,96)/2) + 1, :, :, ...
							                season(mth), kp_arr(mth), 2 ) );

					end % for mth=kth:lth,

					% "Clean" data.  Make the data equal to the mean if the value
					% is greater than stdev * CLEANMULT.  We are looking for low level
					% signals down in the noise and don't expect it to be large.
					count = 0;
					for mth=kth:lth,
						for nth=2:NOFBANDS,
							for oth=1:NOFCHANNELS,
								if ( data(mth,nth,oth)>stdev(mth-kth+1,nth,oth)*CLEANMULT || ...
								     data(mth,nth,oth) == -1 )
									%data(mth,nth,oth) = residueMed(mth-kth+1,nth,oth);
									data(mth,nth,oth) =  ...
										squeeze( stats( floor(mod(mth,96)/2) + 1, nth-1, oth,  ...
							    	                season(mth), kp_arr(mth), 3 ) );
									count = count + 1;
								end % if ( data(mth,nth,oth) > stdev(mth,nth,oth) * CLEANMULT )
							end % for oth=1:NOFCHANNELS,
						end % for nth=1:NOFBANDS,
					end % for mth=kth:lth,

					stackedData( ith, :, :, : ) = ...
							squeeze(stackedData( ith, :, :, : )) + ...
							data( (kth:lth), :, : );

%					disp( sprintf('Count: %d Percentage: %f', ...
%				 	     count, count/(mth-kth)/NOFBANDS/NOFCHANNELS ) );
				end  % if ( kth > 0 && lth > 0 ),
			end % if ( ~ isempty( et ) ),

	
		end % for jth = 1 : numQuakes,


	else
		display('No eqs found')
	end % end: if( iscell(earthquakes) )


end	% for ith = 1 : numOfStations,
