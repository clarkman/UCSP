function success = writeColumnFile( filename, columns, labels, format )
%
% Writes a labeled column file for later reading
% Num columns in 'columns' must match num in 'labels'
%


numLabels = size( labels );
numColumns = size( columns );
if( numLabels(2) ~= numColumns(2) )
    display(['writeColumnFile:: Column count mismatch: ', sprintf( '%d != %d', numLabels(2), numColumns(2) ) ] );
    success = 0;
    return;
end
if( numLabels(1) ~= 1 )
    display(['writeColumnFile:: Labels must be an array!'] );
    success = 0;
    return;
end

fid = fopen( filename, 'w' );
if( fid == -1 )
    display( ['writeColumnFile:: File: ', filename, ' could not be opened!'] );
    success = 0;
    return;
end

fprintf( fid, 'LABELS = ' );
for ith = 1 : numLabels(2) - 1
    fprintf( fid, '%s\t', labels{ith} );
end
fprintf( fid, '%s', labels{numLabels(2)} );
fprintf( fid, '\n' );


formatter = [format,'\t'];
for ith = 1 : numColumns(1)
    for jth = 1 : numColumns(2) - 1
        fprintf( fid, formatter, columns(ith, jth) );
    end
    fprintf( fid, format, columns(ith, numColumns(2)) );
    fprintf( fid, '\n' );
end


fclose( fid );

success = 1;
