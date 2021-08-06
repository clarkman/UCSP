function [ data ] = plotFBmsscsb( varargin )
%
% function [ data ] = plotCMNFBmsmcsb( varargin )
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
%
% Todo:
%   - Could use error checking on arguments.
%   - This code is ugly, sorry!  We just fix it.--jwc
%
%  $Id: plotFBmsmcsb.m,v 97d192272855 2008/04/01 18:45:23 jwc $

% Set up GLOBALS
% Set the colors for three channels, 1 is red, 2 is blue, 3 is green
COLORS = ['r' 'g' 'b' 'm'];
NETWORKS = {'BK' 'CMN'};
NOFSTATS      = 5; % 
NARGS         = 8;
logPlot       = 0;
plotKp        = 0;
plotMean      = 0;
plotMedian    = 0;
plotQuartiles = 0;
plotEq        = 0;
plotStds      = 0;
minKs=10;

% Process arguments
	% Check length
	if ( nargin < NARGS )
		s = sprintf( 'Must have %d arguments.', NARGS );
		error( s );
	end

	% Process required arguments
	network = varargin{1};
	if ( isempty( find( strcmp( NETWORKS, network ) ) ) )
		error([ 'Unknown network: ' network ] );
	end

	% XXX We should do some input checking here.
	network   = varargin{1};
	sites      = varargin{2};
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

t1 = size(sites);      % Get number of sites.
nos = t1(2);
t1 = size(channels);      % Get number of sites.
noc = t1(2);

% Load filter bank data
for site=sites,
	s = sprintf('[ data1_%d data2_%d data3_%d data4_%d ] = loadFBDataSB( sd, ed, network, site, channels, band );', site, site, site, site )
	eval( s );
	for c=[1:4],
		s = sprintf('t1 = find( data%d_%d == -1 );', c, site );
		eval ( s );
		s = sprintf('data%d_%d(t1) = NaN;', c, site );
		eval ( s );
	end % for c=[1:4],
end  % for site=sites,

% Load in Kp file if we need
if ( plotKp > 0 ),
	cmd = sprintf('load %s;', kpMatFileName );
	eval( cmd );
	% adjust for 8 time diffence in our analysis, PDT
	kpdtnum = kpdtnum-8/24;
end

% Build Kp and Stat time series.
if ( plotKp > 0 )

	% Populate a time series with expected values
	for id=sd:ed		                    % - Loop through days

		[y,m,d,h,mi,s] = datevec(id);       % - Get date vector (month, day, etc)
		season = ceil((mod(m+6,12)+1)/3);   % - Calculate season param

		% Loop through time of days
		for it=[1:1:96]
			t = id + it/96;                    % Calculate time stamp
			thisKp = kp( closest( kpdtnum,t ) ); % Look up kp, jwc
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
		
			kpTimeSeries(  (id-sd)*96 + it   ) = thisKp;
			kpsTimeSeries( (id-sd)*96 + it   ) = kp_tmp;
			if ( thisKp < 4 )
				barColor( (id-sd)*96 + it, : ) = [0 1 0];
			elseif ( thisKp ==4 ) 
				barColor( (id-sd)*96 + it, : ) = [1 1 0];
			else
				barColor( (id-sd)*96 + it, : ) = [1 0 0];
			end
		end % end: for it=[1:1:96]
	end % end: for id=sd:ed		
end % end: if ( plotKp > 0 )

% Convert units if desired.
%	Note, this results in imaginary numbers since the no data default value is -1.  This should
%	be fixed at some point.  XXX
	[f1 f2] = getUCBMAFreqs(band);    
	bw = f2 - f1;                    
	for site=sites,
		if ( strcmp( units, 'pT' ) ),
			s = sprintf( 'data1_%d(:,band+1) = sqrt(data1_%d(:,band+1)) * bw;', site, site );
			eval( s );
			s = sprintf( 'data2_%d(:,band+1) = sqrt(data2_%d(:,band+1)) * bw;', site, site );
			eval( s );
			s = sprintf( 'data3_%d(:,band+1) = sqrt(data3_%d(:,band+1)) * bw;', site, site );
			eval( s );
			s = sprintf( 'data4_%d(:,band+1) = sqrt(data4_%d(:,band+1)) * bw;', site, site );
			eval( s );
		else
			error( ['Unknown units: ' units] );
		end
	end  % for site=sites,

% Plot the figure
%	l = {};           % - Init legend variable
	figure, hold on;  % - Create figure

	% Calculate number of subplots
	nosp = size( channels, 2 );
	nosp = nosp + plotKp;

	yllim = 0.08;
	xpos = 0.13;
	width = 0.7750;
	yulim = 1 - yllim;
	dy = yulim - yllim;
	height = dy / nosp;

	lp = 0;
	for j=1:noc
%	for channel=channels

		%subplot(nosp,1,j);
		subplot( 'Position' , [ xpos (1 - yllim - (height*(lp+1)) ) width (height-0.02) ] ), hold on;
		lp = lp + 1;

		if j == 1,
			s = sprintf( 'Network View: %s - %s - FB%d: %f - %f', startDate, endDate, band, f1, f2 );
			title( s );
		end

		% Plot data
		cmd = 'plot (';       
		cmdLegend = 'legend( ';
		i = 1;
		if ( logPlot ),
			ymax = -20;
			ymin = 20;
		else,
			ymax = 0;
			ymin = 10e20;
		end
		for i = 1:1:nos,
			%cmd = sprintf('%s data%d_%d(:,1), data%d_%d(:,band+1)', cmd, channels(j), sites(i), channels(j), sites(i) );
			if ( logPlot ),
				cmd  = sprintf('%s data%d_%d(:,1), log10(data%d_%d(:,band+1))', cmd, channels(j), sites(i), channels(j), sites(i) );
				cmd2 = sprintf( 'tymax = log10(max( data%d_%d(:,band+1) ));', channels(j), sites(i) );
				cmd3 = sprintf( 'tymin = log10(min( data%d_%d(:,band+1) ));', channels(j), sites(i) );
			else
				cmd  = sprintf('%s data%d_%d(:,1), data%d_%d(:,band+1)', cmd, channels(j), sites(i), channels(j), sites(i) );
				cmd2 = sprintf( 'tymax = max( data%d_%d(:,band+1) );', channels(j), sites(i) );
				cmd3 = sprintf( 'tymin = (min( data%d_%d(:,band+1) ));', channels(j), sites(i) );
			end
			cmdLegend = sprintf('%s ''%d''', cmdLegend, sites(i) );
			if i < nos,
				cmd = sprintf('%s,', cmd);
				cmdLegend = sprintf('%s,', cmdLegend);
			end

			%cmd2 = sprintf( 'ty = max( data%d_%d(:,band+1) );', channels(j), sites(i) );
			eval( cmd2 );

			if ( tymax > ymax ),
				ymax = tymax;
			end
			%cmd3 = sprintf( 'ty = min( data%d_%d(:,band+1) );', channels(j), sites(i) );
			eval( cmd3 );
			%if ( ty < ymin && ty > 0 )
			if ( tymin < ymin && tymin ~= -Inf )
				ymin = tymin;
			end
		end % for i = 1:1:nos,

		size( cmd )
		size( cmdLegend )
		cmd = sprintf('%s );', cmd);
		eval( cmd );
		cmdLegend = sprintf('%s, ''Location'', ''SouthOutside'', ''Orientation'', ''Horizontal'');', cmdLegend);
		%eval( cmdLegend );

		if ( plotEq > 0 ),
		for i = 1:1:nos,
				display('================')
				display('Looking for eqs')
				sn = sprintf('%s-%d',siteNames(sites(i)),sites(i))
				% EQ times in UTC
				sdUTC = sd + 8/24;
				edUTC = ed + 8/24 +1;
				earthquakes = SQLQueryEarthquakes( sdUTC, edUTC, minKs, sn );
				if( iscell(earthquakes) )
					display('   Plotting eqs')
					numQuakes = length(earthquakes)
					hold on;
					yy = get(get(gcf,'CurrentAxes'),'YLim')
					for ith = 1 : numQuakes
						earthquake = earthquakes{ith};
						eqMag = earthquake.magnitude;
						ksVal = log10( abs(earthquake.value) * 2 );
						earthquake.time
						x = earthquake.time - 8/24; % Adjust for UTC, we're 8 hours behind.
						ymin
						ymax
						line( [x x], [(ymin) (ymax)], 'Color', [0 0 0],'LineStyle', '--', 'LineWidth', 2.1 );
						if( eqMag >= 1.0 )
							text( x, (ymax), sprintf('%2.1f',eqMag),'Color', [0 0 0], 'HorizontalAlignment', 'left' );
							display( sprintf(' mag %2.1f',eqMag) );
						end % end: if( eqMag >= 1.0 )
					end % end: for ith = 1 : numQuakes
				else
					display('No eqs found')
				end % end: if( iscell(earthquakes) )
				hold off;
			end % for i = 1:1:nos,
		end % end: if ( plotEq > 0 ),

	
		% Set data plot properties
%		if ( logPlot ),
%			set(get(gcf,'CurrentAxes'),'YScale','log' );
%		end
		if ( strcmp( units, 'pT' ) )
			if ( logPlot == 0 )
				str = sprintf( 'Ch: %d (pT)', channels(j) );
			else
				str = sprintf( 'Ch: %d (log(pT))', channels(j) );
			end
			%ylabel( 'pT' );
			ylabel( str );
		else
			error( ['Unknown units: ' units] );
		end

		set(get(gcf,'CurrentAxes'),'Xtick',[] );

		ca = get( gcf, 'CurrentAxes' );
		lims = get( ca, 'YLim' );
		if ( ymax > ymin )
			set( ca, 'YLim', [ymin ymax] );
		end
%		ca = get( gcf, 'CurrentAxes' );
%		if ( ymax > ymin )
%			set( ca, 'YLim', [ymin ymax] );
%		end


	end % for channel=channels

eval( cmdLegend );

% Plot Kp if we're doing it
if (plotKp == 1)
	subplot(nosp,1,nosp), hold on

	cmd = sprintf('x = data%d_%d(:,1);', channels(1), sites(1) )
	eval( cmd );

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
	set( ca, 'Position', [ pos(1) yllim pos(3) height-0.04 ] );

end

xlabel( 'Local time (hours)' );

% Set X labels
if ( ed - sd > 1 )
	datetick('x',6,'keeplimits')
else
	datetick('x',15,'keeplimits')
end

if saveDir,

	ssDate  = datestr( sd, 'yyyymmdd' );
	seDate  = datestr( ed, 'yyyymmdd' );

	fNamePng = sprintf('%s/fbplot-%s-ALL-%02d-%s-%s.png', ...
					saveDir, network, band, ssDate, seDate );
				
	saveas(gcf,fNamePng,'png');
	system( sprintf( 'chmod a+w %s', fNamePng ) );
%	saveas(gcf,fNamePdf,'pdf');
	close;
end



return



%		subplot(nosp,1,lp+1),hold on
		subplot( 'Position' , [ xpos (1 - yllim - (height*(lp+1)) ) width (height-0.01) ] ), hold on;

		cmd = sprintf('data = data%d;',channel);
		eval( cmd );
		cmd = sprintf('h%d = plot( data(:,1), data(:,band+1), COLORS(channel) );',channel);
		eval( cmd );
%		h = plot( data(:,1), data(:,band+1), COLORS(channel) );
		sLegend = sprintf('Channel %d', channel );


	

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


data = gcf1;


return


