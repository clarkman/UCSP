function data = plotCMNFBsssb( network, site, band, channels, stats, startDate, endDate, logPlot, units )
%
% function plotFBsssb( site, channels, bands, stats, startDate, endDate )
%
% Purpose: Plots filter bank values for a single site and single band (sssb).
%
% Inputs: 
%		network   - the network you are interested in.
%		site      - the site your are interested in, (for BK is the letter name,
%		            for CMN it is the site number).
%		band      - which band, 1-14, do you want to plot.
%		channels  - which channels do you want.  Exmaple [1 0 1] plots
%		            channels 1 and 3.
%		stats     - which stats do you want.  Pass a 3x1 array setting each
%		            element to 1 or 0 if you want or don't want 
%		            means, medians, +-std
%		startDate - start date you want in yyyy/mm/dd.
%		endDate   - end date you want in yyyy/mm/dd.
%		logPlot   - plot y axis in log format
%		units     - what units?  support conversion to pT
%
% Comments:
%
%	- Uses the ENV variables FBOUTPUT_CMN and FBOUTPUT_BK to get the output directories
% 	  for each network.
%
%  $Id: plotFBsssb.m,v 30f690c1506e 2007/01/15 23:34:49 jwc $

% Set the colors for three channels, 1 is red, 2 is blue, 3 is green
COLORS = ['r' 'g' 'b'];

% Get directory of filter bank values
if ( strcmp( network, 'BK' ) )
	[status, fbDir] = system( 'echo -n $FBOUTPUT_BK' );
	if( length( fbDir ) == 0 )
	    error( 'ERROR: env must contain FBOUTPUT_BK variable found in $QFDC/include/qfpaths.bash' );
	end
elseif ( strcmp( network, 'CMN' ) )
	[status, fbDir] = system( 'echo -n $FBOUTPUT_CMN' );
	if( length( fbDir ) == 0 )
	    error( 'ERROR: env must contain FBOUTPUT_CMN variable found in $QFDC/include/qfpaths.bash' );
	end
else
	error( ['ERROR: invalid network name--' network] );
end

% Convert date to a Matlab format, and to a vector for file name generation
sd  = datenum( startDate, 'yyyy/mm/dd' );
sdv = datevec( sd );
ed  = datenum( endDate, 'yyyy/mm/dd' );
edv = datevec( ed );
nd = ed - sd + 1;

for ic=1:3					% - Loop through all the channels
	if (channels(ic))		% - Check if we want to plot the channel
		t2 = [];
		for id=sd:ed		% - Loop through days
			try,
				idv = datevec( id );
				[yr mo day] = datevec( id );

				fn = sprintf( '%s/CMN%d_%s%d/CHANNEL%d/%d%02d%02d.CMN.%d.%02d.fb',...
					fbDir,site,siteNames(site),site,ic,yr,mo,day,site,ic);
				td = readColumnFile( fn );
	
				% Check size of array, should be 96x14
				t1 = size(td);
				if (t1(1) ~= 96 || t1(2) ~=14),
					s = sprintf(' Error in %s, size is %d %d.', fn, t1(1), t1(2) );
					error( s );
				end
	
			catch,
				td = zeros(96,14);	
			end

			% Set the correct time stamp
			td(:,1) = [1:1:96]/96 + id;

			% Append channel data to temp data variable
			t2 = [ t2; td ];

		end % end for id=sd:ed
	else
		t2 = zeros(96*(ed-sd+1),14);		% Fill with zeros.
	end % if (channels(ic))
	data(ic,:,:) = t2;

end % for ic=1:3

size(data)
% Plot the figure
l = {};
figure, hold on;
ii = 1;
for ic=1:3
	if (channels(ic)),
		plot( data(ic,:,1), data( ic,:,band+1), COLORS(ic) )
		l1 = sprintf('Channel %d', ic );
		l{ii} = l1;
		ii = ii + 1;
	end % if (channels(ic))
end % for ic=1:3


% Set log properties of y-axis
if ( logPlot ),
	set(get(gcf,'CurrentAxes'),'YScale','log' );
end

% Set lab for y-axis
if ( strcmp( units, 'pT' ) )
	ylabel( 'Magnetic Field Strength (pT)' );
else
	error( ['Unknown units: ' units] );
end

xlabel( 'Local time (hours)' );
legend( l );
datetick('x',15,'keeplimits')

[f1 f2] = getUCBMAFreqs( band );
s = sprintf( '%s %s - %s - FB%d: %f - %f', siteNames(site), startDate, endDate, band, f1, f2 );
title( s );



