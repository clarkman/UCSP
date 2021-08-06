iLoggerName = [ bldg, 'Output.fixed.csv' ];
incidentName = [ 'dbase/', bldg, 'Incident.csv' ];
incidentPulseName = [ 'dbase/', bldg, 'IncidentPulse.csv' ];
sensorNameName = [ 'dbase/', bldg, 'SensorName.csv' ];
ls( iLoggerName )
ls( incidentName )
ls( incidentPulseName )
ls( sensorNameName )
% All exist


% Load iLogger Table
[ lbls, strs ] = readLabeledCSV( iLoggerName );
[ lblsILogger, arr ] = pluckArray( lbls, strs, [1 2 3 4 5 7 8 12 13 14 15 16 18 19 20 24 27 28 29 30 31], { '%g', '%s', '%g', '%g', 'dn', '%s', '%g', '%s', '%s', '%lu', '%s', '%g', '%g', '%g', '%s', '%g', '%g', '%g', '%s', '%s', '%s' } );
arrILoggerName = [ 'iLoggerVals', bldg ];
eval( [ arrILoggerName ' = arr'] )


% Load Incident Table
% Must fix, becuase comment filed has a comma
cmd = [ 'cat ', incidentName, ' | sed ''s/nearby,/nearby/'' > tmp.csv' ];
system(cmd)
cmd = [ 'mv tmp.csv ', incidentName ]
system(cmd)
[ lbls, strs ] = readLabeledCSV( incidentName );
[ lblsIncident, arr ] = pluckArray( lbls, strs, [1 3 4 7 11 12 13 19 24], { '%g', 'dn', 'dn', '%g', '%s', '%g', '%g', '%s', '%g' } );
arrIncidentName = [ 'incidentVals', bldg ];
eval( [ arrIncidentName ' = arr'] )


% Load IncidentPulse Table
[ lbls, strs ] = readLabeledCSV( incidentPulseName );
% Sanity ...                                                                                                                                        1     2     4      5     6     7     8     9    10    13    15    16    17    18    20    22    23    28    29    32    33    40    41    42    43    44    48    49    50    52    53    57
[ lblsIncidentPulse, arr ] = pluckArray( lbls, strs, [1 2 4 5 6 7 8 9 10 13 15 16 17 18 20 22 23 28 29 32 33 40 41 42 43 44 48 49 50 52 53 57], { '%g', 'dn', '%g', '%lu', 'dn', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g' } );
arrIncidentPulseName = [ 'incidentPulseVals', bldg ];
eval( [ arrIncidentPulseName ' = arr'] )


% Load Sensor Name Table
[ lbls, strs ] = readLabeledCSV( sensorNameName );
%                                                                         1     2     3     8     9    15    16
[ lblsSensorName, arr ] = pluckArray( lbls, strs, [1 2 3 8 9 15 16], { '%lu', '%s', '%g', 'dn', 'dn', '%s', 'dn' } );
arrSensorName = [ 'sensorNames', bldg ];
eval( [ arrSensorName ' = arr'] )


clear arr lbls strs arrILoggerName arrIncidentName arrIncidentPulseName arrSensorName
clear iLoggerName incidentName incidentPulseName sensorNameName