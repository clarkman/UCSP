function [ arrayOut, tokens, labels ] = readColFile( filename )
%
% Case-Sensitive, tab-delimited format:
% 
% ROWS=XXX
% FS=|
% TOKEN1 = blah (optional)
% TOKEN2 = blather (optional)
% HEADER_END
% LABELS = a	b   c
% 2.4	5.6 7.8
% 3.2	5.4 7.6
% 1.5	3.4 8.9
%
% Header is optional, but "LABELS = " must be exact
% and is mandatory.  Returned struct will have fields
% struct.a, struct.b, etc.


% Checks ...
if( length(filename) == 0 )
    error( 'readColFile:: Filename empty!' );
end


% Configure ...
doLabels = 0;
if( nargout > 2 ), doLabels = 1;, end;


% Open file ...
fid = fopen(filename, 'r');
if (fid == -1)
    display(['readColFile:: Cannot open the file ', filename]);
    return;
end


% First line, must be number of rows ...
tline = fgetl(fid);
if( ~strcmp( tline(1:5), 'ROWS=' ) )
    error( 'readColFile:: First line of Col file must be ROWS=XXXX !!' );
else
    [numRows, count] = sscanf( tline(6:end), '%d' );
    if( count ~= 1 || numRows < 0 )
        error( 'readColFile:: Row scan error!' );
    end
end
if( numRows == 0 )
    error( 'readColFile:: Row count scanned is zero!!' );
end


% Second line, must be sperarator character (tabs are invisible!!!) ...
tline = fgetl(fid);
if( ~strcmp( tline(1:3), 'FS=' ) )
    error( 'readColFile:: Second line of Col file must be field separator FS=X !!' );
else
    [sep, count] = sscanf( tline(4), '%c' );
    if( count ~= 1 )
        error( 'readColFile:: Sep scan error!' );
    end
end


% Sniff tokens ...
numTokens = 0;
tokenArray = cell(10,2);
tline = fgetl(fid);
while( ~strcmp( tline, 'HEADER_END' ) )
    quals = strfind( tline, '=' );
    if( length(quals) ~= 1 )
	error( 'readColFile:: Malformed Token, sb: NAME=VAL' );
    end	
    numTokens = numTokens + 1;
    tokenArray{numTokens,1} = tline(1:quals(1)-1);
    tokenArray{numTokens,2} = tline(quals(1)+1:end);
    tline = fgetl(fid);
    if( tline == -1 )
        error( 'readColFile:: Malformed token set! Tokens exhausted before HEADER_END' );
    end
end
if( numTokens > 0 )
    for( tokth = 1 : numTokens )
        tokens{tokth} = { tokenArray{ tokth,1 }, tokenArray{ tokth,2 } }; % trim
    end
else
    tokens = { {}, {} };
end


% Process header line ...
tline = fgetl(fid);
if( ~strcmp( tline(1:9), 'LABELS = ' ) )
    error( 'readColFile:: No label row!!' );
end
if( doLabels )
    labels = parseDelimitedString(tline(10:end), sep);
    numColumns = length( labels );
else
    numColumns = length( parseDelimitedString(tline(10:end), sep) );
end


% Loop over data rows and read ...
arrayOut = cell( numRows, numColumns );
for ith = 1 : numRows
    tline = fgetl(fid);
    values = parseDelimitedString(tline, sep);
    for jth = 1 : numColumns
        arrayOut{ith,jth} = values{jth};
    end
end


% Clean up ...
fclose(fid); 


