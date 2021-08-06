
%===============================================================================
function [ noe, outputStr ] = processDiff( network, site, channel, band, time, data, ref, subType, outputToScreen );
%===============================================================================

EVENTTYPE = 'FB_QUARTILE';

% StartTime|StartTimeMS|EndTime|EndTimeMS|Duration|EventType|SubEventType|EventVersion|EventSource|DataSourceNetwork|DataSourceStation|DataSourceChannel|CreationTime|Maximum|Minimum|InferredStart|InferredEnd
% 2008-03-24 23:41:26|308|2008-03-24 23:41:27|027|0.7186|TS_PULSE|UP|0|TS_PULSE_COUNTER|CMN|609|3|2008-03-27 12:28:28|1270563|0|0|0

oc = 1;
%outputStr{1} = '';

	size(data)
	oneInds = find( data > 0 );

	% Set up oneInds to look for events.
	num  = [ oneInds; 0     ];
	den  = [ 0   ; oneInds+1];
	diff = num - den;

	% Find indices where the diff is 1.  These our event boundaries
	inds = find ( diff > 0 )

	% Find the number of events.
	noe = length(inds)

	% Initialize an event detector, if jth stays 0, no events.  Set to 1 if we 
	% find one.
	jth = 0;

	% Loop through event boundaries, if there are any.
	for ith=1:noe

		if ( jth ~= 0 )
			% Print event

			sI = oneInds(inds(ith -1));
			eI = oneInds(inds(ith)-1 );

			sT = time(sI) - 1/24/4;  % Adjust to include first 15 minutes.
			eT = time(eI) + 1/24/4;  % Adjust to include last 15 minutes.

			maxD = max( data( sI:eI ) );
			maxR = max( ref(  sI:eI ) );

			str = [ sprintf('%s', datestr(sT,0) ) '|' ...      % StartRime
			        '0|' ...                                                  % StartTimeMS
			        sprintf('%s', datestr(eT,0) ) '|' ...   % EndTime
			        '0|' ...                                                  % EndTimeMS
			        sprintf('%.0f', (eT-sT)*86400 ) '|' ... % Duration
			        EVENTTYPE '|' ...                                       % EventType
			        subType '|' ...                                           % SubEventType
			        '1|' ...                                                  % EventVersion
			        network '|' ...                                           % DataSourceNetwork
			        sprintf('%d', site ) '|' ...                              % DataSourceStation
			        sprintf('%d', channel ) '|' ...                           % DataSourceChannel
			        datestr(now) '|' ...                                      % CreationTime
			        sprintf('%.2f',maxD') '|' ...                               % Maximum
			        sprintf('%.2f',maxR') '|' ...                               % Maximum
			        '0|' ...                                                  % InferredStart
			        '0|' ...                                                  % InferredEnd
			        sprintf('%d', band)                                       % Band
                  ];

			outputStr{oc} = str;
			oc = oc + 1;

			%outputStr = [ outputStr str ];
			%display( sprintf( 'Start: %d   End: %d', ...
			%                   oneInds(inds(ith-1)), oneInds(inds(ith)-1 )) );
		else
			% Do nothing, skips the first entry
			jth = 1;
		end % if ( jth ~= 0 )
	
	end % for ith=1:noe

	% Print the last event, if there is one.
	if ( jth ~= 0 )
		% Look for the end of the last event
		jth = oneInds(inds(ith))+1;
		noEnd = 1;
		while ( jth <= length(data) && noEnd == 1 )
			if ( data(jth) == 0 )
				noEnd = 0;
			else
				jth = jth + 1;
			end % if ( data(jth) == 0 )
		end % while ( jth <= length(data) )

		% Print event
%		outputStr = [ outputStr sprintf( 'Start: %d   End: %d', oneInds(inds(ith)), jth-1 ) ];
			sI = oneInds(inds(ith -1));
			eI = oneInds(inds(ith)-1 );

			sT = time(sI) - 1/24/4;  % Adjust to include first 15 minutes.
			eT = time(eI) + 1/24/4;  % Adjust to include last 15 minutes.

			maxD = max( data( sI:eI ) );
			maxR = max( ref(  sI:eI ) );

			str = [ sprintf('%s', datestr(sT,0) ) '|' ...      % StartRime
			        '0|' ...                                                  % StartTimeMS
			        sprintf('%s', datestr(eT,0) ) '|' ...   % EndTime
			        '0|' ...                                                  % EndTimeMS
			        sprintf('%.0f', (eT-sT)*86400 ) '|' ... % Duration
			        EVENTTYPE '|' ...                                       % EventType
			        subType '|' ...                                           % SubEventType
			        '1|' ...                                                  % EventVersion
			        network '|' ...                                           % DataSourceNetwork
			        sprintf('%d', site ) '|' ...                              % DataSourceStation
			        sprintf('%d', channel ) '|' ...                           % DataSourceChannel
			        datestr(now) '|' ...                                      % CreationTime
			        sprintf('%.2f',maxD') '|' ...                               % Maximum
			        sprintf('%.2f',maxR') '|' ...                               % Maximum
			        '0|' ...                                                  % InferredStart
			        '0|' ...                                                  % InferredEnd
			        sprintf('%d', band)                                       % Band
                  ];

			outputStr{oc} = str;
		%display( sprintf( 'Start: %d   End: %d', oneInds(inds(ith)), jth-1 ) );
	end % if ( jth ~= 0 )


