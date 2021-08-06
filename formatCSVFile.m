function [ Labels, CellArr ] = formatCSVFile( fName, cols, forms )
% formatCSVFile

display( [ 'Reading: ', fName ] )
[ lbls, vals ] = readLabeledCSV( fName );

display( [ 'Formatting ', sprintf( '%d', length(cols) ), ' columns.' ] )
[ Labels, CellArr ] = pluckArray( lbls, vals, cols, forms );

