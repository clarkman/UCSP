function  plotFBWeekly( network, station, band, channels, plotType, year, week, dayShift, directory, viewPlots )

% Turn off negative data ignored warning
warning off MATLAB:Axes:NegativeDataInLogAxis

% Week begins at 01.

MINARGS = 8;

% First check on number of args, make sure we have minimum number
%if ( nargin < MINARGS )
%		error(sprintf('Must have %d arguments.', MINARGS ) );
%end

try
	% Get datenum of Jan 01 of the year we're interested in.
	% sprintf('%d/01/01',year)
	d = datenum( sprintf('%d/01/01',year), 'yyyy/mm/dd' );

	% Find first Sunday of year - that is start of week 1
    while( strcmp( datestr(d,'ddd'), 'Sun' ) ~= 1 )
        d = d +1;
        display( sprintf('\tIncrementing day: %s %s', datestr(d,'ddd'), datestr(d,'yyyy/mm/dd') ) );
    end
    sD = d;
    eD = d + 6;
    display( sprintf('Week 1 Starting day: %s %s', datestr(sD,'ddd'), datestr(sD,'yyyy/mm/dd') ) );
    display( sprintf('Week 1 Final day: %s %s', datestr(eD,'ddd'), datestr(eD,'yyyy/mm/dd') ) );
    
	% Calculate sd,ed for desired week based on the Saturday of the first week.
	ed = eD + 7*(week-1) - dayShift ;
	sd = ed - 6 - dayShift ;
	display( sprintf('Plot Starting day: %s', datestr(sd,'yyyy/mm/dd')) );
	display( sprintf('Plot Final day: %s', datestr(ed,'yyyy/mm/dd')) );

	% Plot single site, multiple channel, single band
    if ( strcmp( plotType, 'ssmcsb' ) == 1 )
        if( viewPlots )
            plotFBssmcsb( network, str2num(station), band, channels, ...
                datestr(sd,'yyyy/mm/dd'), datestr(ed,'yyyy/mm/dd'), ...
                'pT',directory,'logPlot','plotQuartiles','viewPlots');
        else
            plotFBssmcsb( network, str2num(station), band, channels, ...
                datestr(sd,'yyyy/mm/dd'), datestr(ed,'yyyy/mm/dd'), ...
                'pT',directory,'logPlot','plotQuartiles');
        end
    elseif ( strcmp( plotType, 'msmcsb' ) == 1 )
        %		plotFBmsmcsb( network, station, band, channels, ...
        %		              datestr(sd,'yyyy/mm/dd'), datestr(ed,'yyyy/mm/dd'), ...
        %					  'pT',directory,'logPlot','plotQuartiles');
        cmd  = sprintf ('plotFBmsmcsb( network, station, band, channels, datestr(sd,''yyyy/mm/dd''), datestr(ed,''yyyy/mm/dd''), ''pT'',directory,''logPlot'',''plotQuartiles'');');
        %'pT',directory,'plotKp','logPlot','plotQuartiles','plotEq');
    else
        if( ischar(plotType) )
            display(sprintf('Unknown plot type: %s.', plotType ) );
        else
            display(sprintf('Unknown plot type.'));
        end
        display('USAGE')
        return
    end
    display('SUCCESS')


catch
	display('Failed to plot')
    display('FAILURE')
end

% Turn on negative data ignored warning
warning on MATLAB:Axes:NegativeDataInLogAxis


return
%exit

