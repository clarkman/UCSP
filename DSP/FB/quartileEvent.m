function [ summary_high summary_low events_high events_low ] = plotCMNFBssmcsb( varargin )
%

NETWORK  = 'CMN';
SITES    = [600:609];
BANDS    = [1:13];
CHANNELS = [1:4];
NOFSTATS = 5; % 

network   = varargin{1};
startDate = varargin{2};
endDate   = varargin{3};

% Load environment variables
[fbDir fbStatDir kpTxtFileName kpMatFileName] = fbLoadEnvVar( network );

% Convert date to a Matlab format, and to a vector for file name generation
sd  = datenum( startDate, 'yyyy/mm/dd' );
sdv = datevec( sd );
ed  = datenum( endDate, 'yyyy/mm/dd' );
edv = datevec( ed );
nd = ed - sd + 1;

% Load in Kp file if we need
cmd = sprintf('load %s;', kpMatFileName );
eval( cmd );

% Load in stats
% Init time series variables, 1 per channel for a total of 4
statTimeSeries1 = zeros(96*(ed-sd+1),NOFSTATS); 
statTimeSeries2 = zeros(96*(ed-sd+1),NOFSTATS); 
statTimeSeries3 = zeros(96*(ed-sd+1),NOFSTATS); 
statTimeSeries4 = zeros(96*(ed-sd+1),NOFSTATS); 

%---------------------------------------------------------------------------------jwc

% Load filter bank data
for site=SITES,
	display( sprintf('Sites %d', site) );

	% Load in the stat file into variable, statInfo.
	cmd = sprintf( 'load %s/CMN%d_%s%d/summary-%d.mat', fbStatDir, site, siteNames(site), site, site );
	cmd = sprintf( 'load %s/summary-%d.mat', fbStatDir, site );
	eval( cmd );
	cmd = sprintf( 'statInfo = stats%d;', site );
	eval( cmd );

	% Build kp and stat arrays
	for band=BANDS,
		display( sprintf('Band %d', band) );

		% Load in data.
		[ data1 data2 data3 data4 ] = loadFBDataSB( sd, ed, network, site, CHANNELS, band );
		tLen = 96*(ed-sd+1);

			% Populate a time series with expected values
			for id=sd:ed		                    	% - Loop through days
					[y,m,d,h,mi,s] = datevec(id);       % - Get date vector (month, day, etc)
			        season = ceil((mod(m+6,12)+1)/3);   % - Calculate season param
		
					% Loop through time of days
					for it=[1:1:48]
		
						% Calculate time stamp
						t = id + 2*it/96;      
		
						% Look up kp
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
   			             end     % if ~isempty(thisKp)
	
					for channel=CHANNELS
						% 25th quartile
						eval( sprintf( 'statTimeSeries%d( (id-sd)*96 + it*2-1, 4 ) = statInfo( it, band, %d, season, kp_tmp, 4 );', ...
							channel, channel ) );
						eval( sprintf( 'statTimeSeries%d( (id-sd)*96 + it*2, 4 ) = statInfo( it, band, %d, season, kp_tmp, 4 );', ...
							channel, channel ) );

						% 75th quartile
						eval( sprintf( 'statTimeSeries%d( (id-sd)*96 + it*2-1, 5 ) = statInfo( it, band, %d, season, kp_tmp, 5 );', ...
							channel, channel ) );
						eval( sprintf( 'statTimeSeries%d( (id-sd)*96 + it*2, 5 ) = statInfo( it, band, %d, season, kp_tmp, 5 );', ...
							channel, channel ) );
					end 

					end % end: for it=[1:1:48]
		end % end: for id=sd:ed		

		% Do comparisons on data.
		j = 1;
		k = 1;
		k1 = 1;
		tLen = 96*(ed-sd+1)

		display( 'Looking for events' );
		clear events_high events_low;
		for channel=CHANNELS
			for i=[1:tLen]
				cmd = sprintf( 'data = data%d(i,band+1);', channel );       eval( cmd )
				cmd = sprintf( 'stat4 = statTimeSeries%d(i,4);', channel ); eval( cmd )
				cmd = sprintf( 'stat5 = statTimeSeries%d(i,5);', channel ); eval( cmd )


				% Check below quartile.
				if ( data < stat4 )

					if ( j <= 1 ),
						events_low( j,:,:,:,:,:,:,: ) = [ site channel band i i 1 -1 ];
						j = j + 1;
					else
						% Get last event.
						e = events_low( j-1, :,:,:,:,:,:,: );

						if ( e(5) == (i-1) ),
							e(5) = i;
							e(6) = e(6) + 1;
							events_low( j-1,:,:,:,:,:,:,: ) = e;
						else
							events_low( j,:,:,:,:,:,:,: ) = [ site channel band i i 1 -1 ];
							j = j + 1;
						end
					end
					
				end

				% Check above quartile.
				if ( data > stat5 )
					if ( k <= 1 ),
						events_high( k,:,:,:,:,:,:,: ) = [ site channel band i i 1 1 ];
						k = k + 1;
					else
						% Get last event.
						e = events_high( k-1, :,:,:,:,:,:,: );

						if ( e(5) == (i-1) ),
							e(5) = i;
							e(6) = e(6) + 1;
							events_high( k-1,:,:,:,:,:,:,: ) = e;
						else
							events_high( k,:,:,:,:,:,:,: ) = [ site channel band i i 1 1 ];
							k = k + 1;
						end
					end
					%events_high( k,site,channel,band,st,et,len,value ) 
					
				end

			end % for i=[1:tLen]

			display( sprintf('Number of high events-%d-%d-%d: %d',site,channel,band,k-1 ) );
			display( sprintf('Number of low  events-%d-%d-%d: %d',site,channel,band,j-1 ) );

			if ( exist( 'events_high' ) ),
				t1 = max(events_high,[],1);
				max_high = t1(6);
				summary_high( site-599, band, channel ) = max_high;
			else
				summary_high( site-599, band, channel ) = 0;
			end

			if ( exist( 'events_low' ) ),
				t1 = max(events_low,[],1);
				max_low = t1(6);
				summary_low( site-599, band, channel ) = max_low;
			else
				summary_low( site-599, band, channel ) = 0;
			end

		end % for channel=CHANNELS

	end % for band=BANDS,
end % for site=SITES,

figure;
for channel=[1:4]
	subplot(2,4,channel);
	imagesc( [600:609], [1:13], summary_high(:,:,channel)'/4 ), colorbar, axis xy
	title(sprintf('High Alerts: Channel %d',channel));
	ylabel('FB #');
	xlabel('Site #')
end
for channel=[1:4]
	subplot(2,4,channel+4);
	imagesc( [600:609], [1:13], summary_low(:,:,channel)'/4 ), colorbar, axis xy
	title(sprintf('Low Alerts: Channel %d',channel));
	ylabel('FB #');
	xlabel('Site #')
end


return
%---------------------------------------------------------------------------------
%---------------------------------------------------------------------------------
%---------------------------------------------------------------------------------
%---------------------------------------------------------------------------------



% Set up GLOBALS
% Set the colors for three channels, 1 is red, 2 is blue, 3 is green
COLORS = ['r' 'g' 'b' 'm'];
NETWORKS = {'BK' 'CMN'};
NARGS         = 8;
logPlot       = 0;
plotKp        = 0;
plotMean      = 0;
plotMedian    = 0;
plotQuartiles = 0;
plotEq        = 0;
plotStds      = 0;
stats         = 0;
minKs=10;

% Process arguments
	% Check length
	if ( nargin < NARGS )
		error([ 'Must have ' NARGS ' arguments' ])
	end

	% Process required arguments
	network = varargin{1};
	if ( isempty( find( strcmp( NETWORKS, network ) ) ) )
		error([ 'Unknown network: ' network ] );
	end

	% XXX We should do some input checking here.
	network   = varargin{1};
	site      = varargin{2};
	band      = varargin{3};
	channels  = varargin{4};
	startDate = varargin{5};
	endDate   = varargin{6};
	units     = varargin{7};
	saveDir    = varargin{8};

	if ( nargin > NARGS ),
		for ii=NARGS:nargin,
			if ( strcmp( varargin{ii}, 'plotKp' ) ),
				plotKp = 1;
			end
			if ( strcmp( varargin{ii}, 'plotEq' ) ),
				plotEq = 1;
			end
			if ( strcmp( varargin{ii}, 'logPlot' ) ),
				logPlot = 1;
			end
			if ( strcmp( varargin{ii}, 'plotMean' ) ),
				plotMean = 1;
				stats = stats + 1;
			end
			if ( strcmp( varargin{ii}, 'plotMedian' ) ),
				plotMedian = 1;
				stats = stats + 1;
			end
			if ( strcmp( varargin{ii}, 'plotQuartiles' ) ),
				plotQuartiles = 1;
				stats = stats + 1;
			end
			if ( strcmp( varargin{ii}, 'plotStds' ) ),
				plotStds = 1;
				stats = stats + 1;
			end
		end
	end
% End processing of arguments



%---------------------------------------------------------------------------------jwc



% Plot the figure
	l = {};	                          % - Init legend variable
	figure, hold on;                  % - Create figure

	% Calculate number of subplots
	nosp = size( channels, 2 );
	nosp = nosp + plotKp;

	yllim = 0.08;
	xpos = 0.13;
	width = 0.7750;
	yulim = 1 - yllim;
	dy = yulim - yllim;
	height = dy / nosp;

	s = sprintf( '%s %s - %s - FB%d: %f - %f', siteNames(site), startDate, endDate, band, f1, f2 );
	title( s );

	lp = 0;
	for channel=channels

		% Plot data
%		subplot(nosp,1,lp+1),hold on
		subplot( 'Position' , [ xpos (1 - yllim - (height*(lp+1)) ) width (height-0.01) ] ), hold on;

		cmd = sprintf('data = data%d;',channel);
		eval( cmd );
		cmd = sprintf('h%d = plot( data(:,1), data(:,band+1), COLORS(channel) );',channel);
		eval( cmd );
		if ( stats > 0 ),
			cmd = sprintf('statTimeSeries = statTimeSeries%d;',channel);
			eval( cmd );
		end
%		h = plot( data(:,1), data(:,band+1), COLORS(channel) );
		sLegend = sprintf('Channel %d', channel );
%		legend( sLegend );
	%	legend( sLegend, 'Location', 'EastOutside' );

		if ( plotMean > 0),
			plot( data(:,1), statTimeSeries(:,1), 'm--' ); 
		end
		if ( plotStds > 0),
			plot( data(:,1), statTimeSeries(:,2)*3, 'c--' ); 
		end
		if ( plotMedian > 0),
			plot( data(:,1), statTimeSeries(:,3), 'm--' ); 
		end
		if ( plotQuartiles > 0 ),
			plot( data(:,1), statTimeSeries(:,4), 'k' ); 
			plot( data(:,1), statTimeSeries(:,5), 'k' ); 
		end

		% Set data plot properties
		if ( logPlot ),
			set(get(gcf,'CurrentAxes'),'YScale','log' );
		end
		if ( strcmp( units, 'pT' ) )
			ylabel( 'pT' );
		else
			error( ['Unknown units: ' units] );
		end
	
		ca = get( gcf, 'CurrentAxes' );
		set( ca, 'XTickLabel', {} );
		set( ca , 'XLim', [sd ed+1] );
		ymin = min( data(:,band+1) );
		ymax = max( data(:,band+1) );
		if ( ymax > ymin )
			set( ca, 'YLim', [ymin ymax] );
		end

		%pos = get(ca,'Position')
		%pos(4) = pos(4) * 1.2;
		%set(ca,'Position', pos );

		pos = get(ca,'Position');
		pos2 = [ pos(1) ((nosp-lp)*height+yllim) pos(3) (height-0.01)/2 ];
		pos2 = [ pos(1) (1 - yllim - (height*(lp+1)) ) pos(3) (height-0.01) ];
		%set( ca, 'Position', [ pos(1) (nosp-lp)*height+yllim pos(3) height-0.01 ] );
		set( ca, 'Position', pos2 );
		pos = get(ca,'Position');

		if ( lp == 0 ),
			s = sprintf( '%s %s - %s - FB%d: %f - %f', siteNames(site), startDate, endDate, band, f1, f2 );
			title( s );
		end

		lp = lp + 1;

		cmd = sprintf('gcf%d = gcf;',channel);
		eval( cmd );

		if ( plotEq > 0 ),
				display('=============')
				display('Plotting eqs')
				sn = sprintf('%s-%d',siteNames(site),site);
				% EQ times in UTC
				sdUTC = sd + 8/24;
				edUTC = ed + 8/24 +1;
		        earthquakes = SQLQueryEarthquakes( sdUTC, edUTC, minKs, sn );
		        if( iscell(earthquakes) )
		            numQuakes = length(earthquakes)
		            hold on;
		            yy = get(get(gcf,'CurrentAxes'),'YLim')
		            %xx = get(get(gcf,'CurrentAxes'),'XLim')
		            for ith = 1 : numQuakes
		                earthquake = earthquakes{ith};
		                eqMag = earthquake.magnitude;
		                ksVal = log10( abs(earthquake.value) * 2 );
		                earthquake.time
		                x = earthquake.time - 8/24; % Adjust for UTC, we're 8 hours behind.
%		                kth = yy(2) - (yy(2) - yy(1)) * ksVal/1.6; % Earthquake Magnitude positioner
%		                kth = yy(2) - (yy(2) - yy(1)) * ksVal/1.6; % Earthquake Magnitude positioner
%		                if( kth > yy(1) )
%       		             yy(1) = kth;
%		                end % end: if( kth > yy(1) )
		                %yy(1) = yy(2) - yy(2) * 0.3*eqMag/6; % Earthquake Magnitude positioner
		                %line( [x x], yy, 'Color', [0.3 0.3 0.3], 'LineStyle', '--' );
		                line( [x x], [abs(ymin) (ymax)], 'Color', [0 0 0],'LineStyle', '--', 'LineWidth', 2.1 );
		    %                line( [x x], yy, 'Color', [0.618/2 0 1/2],'LineStyle', '--', 'LineWidth', 1.1 );
		                if( eqMag >= 1.0 )
		                    text( x, abs(ymin), sprintf('%2.1f',eqMag),'Color', [0 0 0], 'HorizontalAlignment', 'left' );
		    %               text( x, yy(1), sprintf('%2.1f',eqMag),'Color', [0.618/2 0 1/2], 'HorizontalAlignment', 'center' );
		                end % end: if( eqMag >= 1.0 )
		            end % end: for ith = 1 : numQuakes
				else
					display('No eqs found')
		        end % end: if( iscell(earthquakes) )
		        hold off;
		end % end: if ( plotEq > 0 ),
	end % end: for channel=channels


% Plot Kp if we're doing it
if (plotKp == 1)
	subplot(nosp,1,nosp), hold on
	x = data(:,1);
	hk = bar(x,kpTimeSeries);
	set( hk, 'EdgeColor', 'none' );

	% Crazy code to change bar color to match Kp plots from NOAA
	% http://xtargets.com/snippets/tag/colour
	% Turns out, it's related to Clark's method too!
	[cax,args,nargs] = axescheck(x,kpTimeSeries );
	[msg,x,y,xx,yy,linetype,plottype,barwidth,equal]=makebars(args{:});
	ix=reshape(1:numel(x)*5,5,[]);
	col=barColor;
	for kk=1:numel(args{1}) 
		p(kk)=patch(xx(ix(:,kk)),yy(ix(:,kk)),col(kk,:), 'EdgeColor', 'none'); 
	end

	set(get(gcf,'CurrentAxes'),'XLim',[sd ed+1]);
	set(get(gcf,'CurrentAxes'),'YLim',[0 10]);
%	set(gcf, 'PaperPosition', [0.25 2.5 6 2])
	ylabel('Kp')
	ca = get( gcf, 'CurrentAxes' );
%	pos = get(ca,'Position')
%	pos(4) = pos(4) * 0.5;
%	set(ca,'Position', pos );
	set( ca, 'XTickLabel', {} );
	gcfk = gcf;

	pos = get(ca,'Position');
	%set( ca, 'Position', [ pos(1) (nosp-lp)*height+yllim pos(3) height-0.01 ] );
	set( ca, 'Position', [ pos(1) yllim pos(3) height-0.01 ] );

end

	if ( ed - sd > 2 )
		datetick('x',6,'keeplimits')
		else
			datetick('x',15,'keeplimits')
		end

xlabel( 'Local time (hours)' );

data = gcf1;


if saveDir,

	ssDate  = datestr( sd, 'yyyymmdd' );
	seDate  = datestr( ed, 'yyyymmdd' );

	% Converts site names to strings
	n = lower( network );
	if ( strcmp( network, 'cmn' ) == 0 ),
		siteName = sprintf( '%03d', site );
	elseif ( strcmp( network, 'bk' ) == 0 ),
		siteName = site;
	end

	fNamePng = sprintf('%s/fbplot-%s-%s-%02d-%s-%s.png', ...
					saveDir, network, siteName, band, ssDate, seDate );
	fNamePdf = sprintf('%s/fbplot-%s-%s-%02d-%s-%s.pdf', ...
					saveDir, network, siteName, band, ssDate, seDate );
				
	saveas(gcf,fNamePng,'png');
	system( sprintf( 'chmod a+w %s', fNamePng ) );
%	saveas(gcf,fNamePdf,'pdf');
	close;
end

return
