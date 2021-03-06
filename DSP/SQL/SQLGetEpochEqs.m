function objects = SQLQueryEarthquakes( startDatenum, stopDatenum, minKs, maxDist, station )
%
% Generates a query that returns all Signal Events for the given file, and
% executes the query.
%  Returns a cell array of the Signal Events.

startStr = datenum2str( startDatenum, 'sql' );
stopStr = datenum2str( stopDatenum, 'sql' );

NEWLINE = char(10);

queryString = ...
['use xweb;', NEWLINE, ...
 'select k_s.value,', NEWLINE, ...
 'k_s.distance,', NEWLINE, ...
 'cnss_quake_data_readable.magnitude,', NEWLINE, ...
 'cnss_quake_data_readable.latitude,', NEWLINE, ...
 'cnss_quake_data_readable.longitude, ', NEWLINE, ...
 'DATE_FORMAT(cnss_quake_data_readable.time,"%Y/%m/%d %H:%i:%S") AS time', NEWLINE, ...
 'FROM k_s LEFT JOIN cnss_quake_data_readable on k_s.quake=cnss_quake_data_readable._key', NEWLINE, ...
 'WHERE k_s.observatory="', station, '"', NEWLINE, ...
 'AND k_s.value >  "', sprintf('%f',minKs), '"', NEWLINE, ...
 'AND k_s.distance <  "', sprintf('%f',maxDist), '"', NEWLINE, ...
 'AND cnss_quake_data_readable.time >  "', startStr, '"', NEWLINE, ...
 'AND cnss_quake_data_readable.time <  "', stopStr,  '"', NEWLINE, ...
 'ORDER BY cnss_quake_data_readable.time ASC', NEWLINE];

%display(queryString)

objects = SQLrunQuery( queryString, 'quakedata', 'matlab' );

