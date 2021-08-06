
%===============================================================================
function header = printHeader( outputToScreen )
%===============================================================================

%# Print basic header
header = 'StartTime|StartTimeMS|EndTime|EndTimeMS|Duration|EventType|SubEventType|EventVersion|EventSource|DataSourceNetwork|DataSourceStation|DataSourceChannel|CreationTime|Maximum|Minimum|InferredStart|InferredEnd|Band';

if ( outputToScreen == 1 )
	display( header );
end % if ( outputToScreen == 1 )


