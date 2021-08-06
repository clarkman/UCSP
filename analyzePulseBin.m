% Script for analyzing pulseBinData 

[ lbls, strs ] = readLabeledCSV( 'pulseBinMWIR.csv' );
[ pulseBinLbls, pbinsMWIR ] = pluckArray( lbls, strs, [2 3 5 6 7 8 9 11 12 13], { 'dn', '%d', '%g', '%g', '%g', '%g', '%d', '%g', '%g', 'h16' } );
[ lbls, strs ] = readLabeledCSV( 'pulseBinSWIR.csv' );
[ pulseBinLbls, pbinsSWIR ] = pluckArray( lbls, strs, [2 3 5 6 7 8 9 11 12 13], { 'dn', '%d', '%g', '%g', '%g', '%g', '%d', '%g', '%g', 'h16' } );
