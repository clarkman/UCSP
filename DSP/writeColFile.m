function success = writeColFile( filename, columns, labels, format, tokens, sep )
%
% Writes a labeled column file.
% If number of rows in labels is zero, append is assumed 
% Num columns in 'columns' must match num in 'labels'
% 
% filename = Path & name of file to be written
% columns = Data array to be written
% labels = Cell Array of labels to be written (must be: 0; or numCols)
% format = Cell Array of formats to use for writing
% sep = optional filed separator, default is TAB
%


% Checks ...
numLabels = size( labels );
numColumns = size( columns );
numTokens = size( tokens );
numFormats = size( format );
if( nargin < 4 )
    error( 'writeColFile:: Not enough args!' );
end
if( length(filename) == 0 )
    error( 'writeColFile:: Filename empty!' );
end
if( ~iscell(labels) || numLabels(1) ~= 1 )
    error( 'writeColFile:: "labels" must be a (1 x n) row cell array!' );
end
if( ~iscell(tokens) || numTokens(2) ~= 2 )
    error( 'writeColFile:: "tokens" must be a (1 x n) row cell array!' );
end
if( numColumns(2) == 0 )
    error( 'writeColFile:: Nothing to write!' );
end
if( numFormats(1) ~= 1 )
    error( 'writeColFile:: Only one row of "format" allowed!' );
end


% Configure ...
if( numLabels(1) == 0 )
    %display(['writeColFile:: Append mode!'] );
    writeMode = 'a';
    writeHeader = 0;
else % New file
    %display(['writeColFile:: Write mode!'] );
    if( numLabels(2) ~= numColumns(2) )
	error(['writeColFile:: Column count mismatch: ', sprintf( '%d != %d', numLabels(2), numColumns(2) ) ] );
    end
    writeMode = 'w';
    writeHeader = 1;
end
if( nargin < 5 )
    tokens = {};
end
if( nargin < 6 )
    sep = '\t';
end


% Open file ...
fid = fopen( filename, writeMode );
if( fid == -1 )
    display( ['writeColFile:: File: ', filename, ' could not be opened!'] );
    success = 0;
    return;
end


% Write optional tokens ...
numTokens = size( tokens );
fprintf( fid, 'ROWS=%d\n', numColumns(1) );
numTokens = size( tokens );
fprintf( fid, 'FS=%c\n', sep );
if( numTokens(1) > 0 || numTokens(2) == 2 )
    for tth = 1 : numTokens(1)
        fprintf( fid, '%s=%s\n', char(tokens{tth,1}), char(tokens{tth,2}) );
    end
end
fprintf( fid, 'HEADER_END\n' );


% Write header ...
if( writeHeader )
    fprintf( fid, 'LABELS = ' );  % Spaces are legacy
    for ith = 1 : numLabels(2) - 1
	fprintf( fid, '%s%c', labels{ith}, sep );
    end
    fprintf( fid, '%s', labels{numLabels(2)} );
    fprintf( fid, '\n' );
end


% Write rows ...
for ith = 1 : numColumns(1)
    for jth = 1 : numColumns(2) - 1
        whichFormat = mod( jth, numFormats(2) );
        formatter = [format{whichFormat},sep];
        fprintf( fid, formatter, columns{ith, jth} );
    end
    fprintf( fid, format{numColumns(2)}, columns{ith, numColumns(2)} );
    fprintf( fid, '\n' );
end


% Open file ...
fclose( fid );

success = 1;
