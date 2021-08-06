function [ truthOut, pulseOut ] = plotPulseFeature( truth, pulse, dateRange )



% Elimination by time
doDateRange = 1;
if length(dateRange) ~= 2
	if isempty(dateRange)
		doDateRange = 0;
	else
	    error( 'Problem with date range!');
	end
end

if doDateRange
	truthDn = extractNumeric( truth, 4 );
	pulseDn = extractNumeric( pulse, 2 );
	truthInds = find( truthDn >= dateRange(1) & truthDn < dateRange(2) );
	pulseInds = find( pulseDn >= dateRange(1) & pulseDn < dateRange(2) );
	if isempty(truthInds) || isempty(pulseInds)
		error('Date Range problem')
	end
	truthOut = extractCellRows( truth, truthInds );
	pulseOut = extractCellRows( pulse, pulseInds );
end

