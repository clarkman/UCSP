function [ lblsIncidentPulse, arr ] = loadIncidentPulse( incidentPulseName )

% Load IncidentPulse Table
[ lbls, strs ] = readLabeledCSV( incidentPulseName );
% Sanity ...                                                                                                                                        1     2     4      5     6     7     8     9    10    13    15    16    17    18    20    22    23    28    29    32    33    40    41    42    43    44    48    49    50    52    53    57
[ lblsIncidentPulse, arr ] = pluckArray( lbls, strs, [1 2 4 5 6 7 8 9 10 13 15 16 17 18 20 22 23 28 29 32 33 40 41 42 43 44 48 49 50 52 53 57], { '%g', 'dn', '%g', '%lu', 'dn', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g', '%g' } );

