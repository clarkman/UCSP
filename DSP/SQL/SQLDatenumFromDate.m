function dateVal = SQLDatenumFromDate( dateStr )


dateStr(5) = '/';
dateStr(8) = '/';

dateVal = str2datenum( dateStr );
