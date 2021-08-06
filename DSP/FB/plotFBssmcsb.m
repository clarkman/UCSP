function [ data ] = plotFBssmcsb( varargin )
%
% function [ data ] = plotFBssmcsb( varargin )
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
%		saveDir   - Directory to save the files in
%
% Comments:
%
%	- Uses the ENV variables FBOUTPUT_CMN and FBOUTPUT_BK to get the output directories
% 	  for each network.
%	- Plotting eqs with log plot doesn't work well.
%   - This code is ugly, sorry!  We just fix it.--jwc
%
% Option:
%   - plotKp: use a subplot to see Kp.  Plot real Kp, and our 4 groups
%   - logPlot: do you want 
%   - viewPlots: display plots
%
% Todo:
%   - Could use error checking on arguments.
%   - This code is ugly, sorry!  We just fix it.--jwc
%
%  $Id: plotFBssmcsb.m,v 6cf42e707190 2009/12/04 02:08:16 qcvs $



% Set up GLOBALS
% Set the colors for three channels, 1 is red, 2 is blue, 3 is green
RESIZE   = '760x440!';
QUALITY  = 80;
COLORS   = ['r' 'g' 'b' 'm'];
NETWORKS = {'BK' 'BKQ' 'CMN'};
NOFSTATS      = 5; % 
NARGS         = 8;
logPlot       = 0;
plotKp        = 0;
plotMean      = 0;
plotMedian    = 0;
plotQuartiles = 0;
plotEq        = 0;
plotStds      = 0;
stats         = 0;
viewPlots     = 0;
minKs=10;


figLeft = 0.05;
figBottom = 0.075;
figWidth = 1.0-2*figLeft;
figSpacing = 0.025;
figHeight = (1.0 - 2 * figSpacing - 2 * figBottom) / 3;



% Process arguments
	% Check length
	if ( nargin < NARGS )
		display([ 'Must have ' NARGS ' arguments' ])
        error('USAGE');
	end

	% Process required arguments
	network = varargin{1};
	if ( isempty( find( strcmp( NETWORKS, network ) ) ) )
		display([ 'Unknown network: ' network ] );
        error('USAGE');
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
            if ( strcmp( varargin{ii}, 'viewPlots' ) ),
                viewPlots = 1;
            end
		end
	end
% End processing of arguments

% Load environment variables
[fbDir fbStatDir kpTxtFileName kpMatFileName] = fbLoadEnvVar( network );

% Convert date to a Matlab format, and to a vector for file name generation
sd  = datenum( startDate, 'yyyy/mm/dd' );
sdv = datevec( sd );
ed  = datenum( endDate, 'yyyy/mm/dd' );
edv = datevec( ed );
nd = ed - sd + 1;

% Load filter bank data
data1 = [ ];
data2 = [ ];
data3 = [ ];
data4 = [ ];
for id = sd:ed
    try
        idata = loadFBDataMB( id, id, network, site, channels, band, false );
        data1 = [ data1; idata(:,1:band+1,1) ];
        data2 = [ data2; idata(:,1:band+1,2) ];
        data3 = [ data3; idata(:,1:band+1,3) ];
        data4 = [ data4; idata(:,1:band+1,4) ];
    catch
        data1 = [ data1; zeros(96,band+1) ];
        data2 = [ data1; zeros(96,band+1) ];
        data3 = [ data1; zeros(96,band+1) ];
        data4 = [ data1; zeros(96,band+1) ];
    end
end
% [ data1 data2 data3 data4 ] = loadFBDataSB( sd, ed, network, site, channels, band );

% Load in Kp file if we need
if ( ( stats > 0 ) || ( plotKp > 0 ) ),
	cmd = sprintf('load %s kp kpdtnum;', kpMatFileName );
	eval( cmd );
	% adjust for 8 time diffence in our analysis, PST
	kpdtnum = kpdtnum - 8/24;
end


% Load in stats
if ( stats > 0 ),
	% Init time series variables, 1 per channel for a total of 4
	statTimeSeries1 = zeros(96*(ed-sd+1),NOFSTATS); 
	statTimeSeries2 = zeros(96*(ed-sd+1),NOFSTATS); 
	statTimeSeries3 = zeros(96*(ed-sd+1),NOFSTATS); 
	statTimeSeries4 = zeros(96*(ed-sd+1),NOFSTATS); 

	% Load in the stat file into variable, statInfo.
	%cmd = sprintf( 'load %s/CMN%d_%s%d/summary-%d.mat', ...
	%               fbStatDir, site, siteNames(site), site, site );
	if( strcmp( network, 'CMN' ) ),
		cmd = sprintf( 'load %s/summary-%d.mat stats%d', fbStatDir, site, site );
		eval( cmd );
		cmd = sprintf( 'statInfo = stats%d;', site );
		eval( cmd );
	elseif( strcmp( network, 'BK' ) ),
		cmd = sprintf( 'load %s/summary-%s.mat stats%s', fbStatDir, site, site );
		eval( cmd );
		cmd = sprintf( 'statInfo = stats%s;', site );
		eval( cmd );
	elseif( strcmp( network, 'BKQ' ) ),
		cmd = sprintf( 'load %s/summaryQuiet-%s.mat stats%s', fbStatDir, site, site );
		eval( cmd );
		cmd = sprintf( 'statInfo = stats%s;', site );
		eval( cmd );
	end
end

% Build Kp and Stat time series.
if ( plotKp > 0 || stats > 0 )

	% Populate a time series with expected values
	for id=sd:ed		                    % - Loop through days

		[y,m,d,h,mi,s] = datevec(id);       % - Get date vector (month, day, etc)
		season = ceil((mod(m+6,12)+1)/3);   % - Calculate season param

		% Loop through time of days
		for it=[1:1:96]

			% Calculate time stamp
			t = id + it/96;      

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

				for channel=channels,
					if ( plotMean ),
						eval( sprintf( 'statTimeSeries%d( (id-sd)*96 + it, 1 ) = statInfo( it, band, %d, season, kp_tmp, 1 );', ...
									 channel, channel ) );
					end
					if ( plotMedian ),
						eval( sprintf( 'statTimeSeries%d( (id-sd)*96 + it, 3 ) = statInfo( it, band, %d, season, kp_tmp, 3 );', ...
									 channel, channel ) );
					end
					if ( plotStds ),
						eval( sprintf( 'statTimeSeries%d( (id-sd)*96 + it, 2 ) = statInfo( it, band, %d, season, kp_tmp, 2 );', ...
									 channel, channel ) );
					end
					if ( plotQuartiles ),
						eval( sprintf( 'statTimeSeries%d( (id-sd)*96 + it, 4 ) = statInfo( it, band, %d, season, kp_tmp, 4 );', ...
									 channel, channel ) );
						eval( sprintf( 'statTimeSeries%d( (id-sd)*96 + it, 5 ) = statInfo( it, band, %d, season, kp_tmp, 5 );', ...
									 channel, channel ) );
					end
				end

					if ( plotKp > 0 ),
						kpTimeSeries( (id-sd)*96 + it   ) = thisKp;
						kpsTimeSeries( (id-sd)*96 + it   ) = kp_tmp;
						if ( thisKp < 3 )
							barColor( (id-sd)*96 + it, : ) = [0 1 0];
						elseif ( thisKp >=3 && thisKp < 5 ) 
							barColor( (id-sd)*96 + it, : ) = [1 1 0];
						else
							barColor( (id-sd)*96 + it, : ) = [1 0 0];
						end
					end % end: if ( plotKp > 0 ),
			end % end: for it=[1:1:96]
	end % end: for id=sd:ed		
end % end: if ( plotKp > 0 || stats > 0 )

% Convert units if desired.
%	Note, this results in imaginary numbers since the no data default value is -1.  This should
%	be fixed at some point.  XXX
	if( strcmp( network, 'CMN' ) || strcmp( network, 'BK' ) ),
		[f1 f2] = getUCBMAFreqs(band);    
	elseif( strcmp( network, 'BKQ' ) ),
		[f1 f2] = getFBUpperFreqs(band);    
	end
	
	bw = f2 - f1;                    
	if ( strcmp( units, 'pT' ) ),
		data1(:,band+1) = sqrt(data1(:,band+1)) * bw;  
		data2(:,band+1) = sqrt(data2(:,band+1)) * bw;  
		data3(:,band+1) = sqrt(data3(:,band+1)) * bw;  
		% data4(:,band+1) = sqrt(data4(:,band+1)) * bw;  
		if stats > 0,
			for ii=1:NOFSTATS,
				statTimeSeries1(:,ii) = sqrt(statTimeSeries1(:,ii)) * bw;
				statTimeSeries2(:,ii) = sqrt(statTimeSeries2(:,ii)) * bw;
				statTimeSeries3(:,ii) = sqrt(statTimeSeries3(:,ii)) * bw;
				% statTimeSeries4(:,ii) = sqrt(statTimeSeries4(:,ii)) * bw;
			end
		end
	else
		display( ['Unknown units: ' units] );
        error('USAGE');
	end



% Plot the figure
    if( ~viewPlots )
        set(0,'defaultFigureVisible','off')
        display('Default value for Figure Visible set to "off"')
    end
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

		% Init y limits.
		ymin = 10e30;
		ymax = 10e-30;

		if ( plotMean > 0),
			plot( data(:,1), statTimeSeries(:,1), 'm--' );  %#ok<NODEF,COLND>
			if ( max( statTimeSeries(:,1) ) > ymax ) %#ok<COLND>
				ymax = max( statTimeSeries(:,1) ); %#ok<COLND>
			end
			if ( min( statTimeSeries(:,1) ) < ymin ) %#ok<COLND>
				ymin = min( statTimeSeries(:,1) ); %#ok<COLND>
			end
		end
		if ( plotStds > 0),
			plot( data(:,1), statTimeSeries(:,2)*3, 'c--' );  %#ok<COLND>
			if ( max( statTimeSeries(:,2) ) > ymax ) %#ok<COLND>
				ymax = max( statTimeSeries(:,2) ); %#ok<COLND>
			end
			if ( min( statTimeSeries(:,2) ) < ymin ) %#ok<COLND>
				ymin = min( statTimeSeries(:,2) ); %#ok<COLND>
			end
		end
		if ( plotMedian > 0),
			plot( data(:,1), statTimeSeries(:,3), 'm--' );  %#ok<COLND>
			if ( max( statTimeSeries(:,3) ) > ymax ) %#ok<COLND>
				ymax = max( statTimeSeries(:,3) ); %#ok<COLND>
			end
			if ( min( statTimeSeries(:,3) ) < ymin ) %#ok<COLND>
				ymin = min( statTimeSeries(:,3) ); %#ok<COLND>
			end
		end
		if ( plotQuartiles > 0 ),
			plot( data(:,1), statTimeSeries(:,4), 'k' );  %#ok<COLND>
			plot( data(:,1), statTimeSeries(:,5), 'k' );  %#ok<COLND>
%jwc
			if ( max( statTimeSeries(:,5) ) > ymax ) %#ok<COLND>
				ymax = max( statTimeSeries(:,5) ); %#ok<COLND>
			end
			if ( min( statTimeSeries(:,4) ) < ymin ) %#ok<COLND>
				ymin = min( statTimeSeries(:,4) ); %#ok<COLND>
			end
		end

		% Set data plot properties
		if ( logPlot ),
			set(get(gcf,'CurrentAxes'),'YScale','log' );
		end

%		if ( strcmp( units, 'pT' ) )
%			ylabel( 'pT' );
%		else
%			error( ['Unknown units: ' units] );
%		end
	
		ca = get( gcf, 'CurrentAxes' );
		set( ca, 'XTickLabel', {} );
		set( ca , 'XLim', [sd ed+1] );
% jwc
		tmp1 = sort( data(:,band+1), 'ascend' );
		tmp2 = 0;
		tmp2 = find( tmp1 > 0 );
		if ( tmp2 ~= 0 )
			if ( tmp1(tmp2(1)) < ymin )
				ymin = tmp1(tmp2(1));
			end
		end
		
		%ymin = min( data(:,band+1) );
		%ymax = max( data(:,band+1) );
		if ( max( data(:,band+1) ) > ymax )
			ymax = max( data(:,band+1) );
		end

		if ( ymax > ymin )
			set( ca, 'YLim', [ymin*0.9 ymax*1.1] );
		end

		%pos = get(ca,'Position')
		%pos(4) = pos(4) * 1.2;
		%set(ca,'Position', pos );

		pos = get(ca,'Position');
		% orig jwc code
		%	pos2 = [ pos(1) ((nosp-lp)*height+yllim) pos(3) (height-0.01)/2 ];
		%	pos2 = [ pos(1) (1 - yllim - (height*(lp+1)) ) pos(3) (height-0.01) ];

		pos2 = [ figLeft (1 - yllim - (height*(lp+1)) ) figWidth (height-0.01) ];

		set( ca, 'Position', pos2 );
		pos = get(ca,'Position');

%        set(gca,'Position', [figLeft, figBottom + (2-(ith-1)) * (figHeight + figSpacing), figWidth, figHeight]);


		if ( lp == 0 ),
			s = sprintf( '%s %s - %s - FB%d: %f - %f in pico Teslas', siteNames(site), startDate, endDate, band, f1, f2 );
			title( s );
		end

		lp = lp + 1;

		cmd = sprintf('gcf%d = gcf;',channel);
		eval( cmd );

		% =========================================================================
		% Plotting eqs.
		% =========================================================================
		if ( plotEq > 0 ),
				display('=============')
				display('Plotting eqs')
				if ( strcmp( network, 'CMN' ) )
					sn = sprintf('%s-%d',siteNames(site),site);
				else
					sn = site;
				end
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
                        ymin
                        ymax
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
	set( ca, 'Position', [ figLeft yllim figWidth height-0.01 ] );

end

	if ( ed - sd > 2 )
		datetick('x',6,'keeplimits')
		else
			datetick('x',15,'keeplimits')
		end

xlabel( 'Local time (hours)' );

data = gcf1;


if saveDir,

	try,
	opengl neverselect 
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
    fNameGif = sprintf('%s/fbplot-%s-%s-%02d-%s-%s.gif', ...
					saveDir, network, siteName, band, ssDate, seDate );
	fNamePdf = sprintf('%s/fbplot-%s-%s-%02d-%s-%s.pdf', ...
					saveDir, network, siteName, band, ssDate, seDate );
				
	display( fNamePng );
	saveas(gcf,fNamePng, 'png');
    system( sprintf( 'chmod a+w %s', fNamePng ) );
	system( sprintf( 'convert %s %s ', fNamePng, fNameGif ) );
	system( sprintf( 'convert -resize %s -quality %d %s %s ', RESIZE, QUALITY, fNameGif, fNameGif ) );
	system( sprintf( 'rm %s', fNamePng ) );
%	saveas(gcf,fNamePdf,'pdf');
	close;
	catch
		close
		s = sprintf( 'ERROR: Failed to save file: %s', fNamePng );
		display( s );
        error('BAD_WRITE');
	end
end

set(0,'defaultFigureVisible','on')
% display('Default value for Figure Visible set to "on"')

display('plotFBssmcsb.m successful')
display('SUCCESS')
return
