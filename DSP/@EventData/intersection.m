function obj = intersection( A, B, slop, timeOffset )
%basic intersection--events in A that have any time overlap with B

if ~strcmpi( class(A), 'EventData' )
    error( 'First input argument must be an EventData object!' )
end

if ~strcmpi( class(B), 'EventData' )
    error( 'Second input argument must be an EventData object!' )
end

%optional input arguments
if nargin > 4;
    error( 'Too many input arguments!' )
end

if nargin >= 3;
    if ~isnumeric( slop )
        error( sprintf( 'Slop must be numeric and its current class is %s', class( slop ) ) )
    elseif ndims( slop ) > 2 | size( slop ) ~= [ 1, 1 ];
        error( 'Slop input argument not recognized! (it must be a scalar)' )
    elseif slop < 0
        warning( 'Slop must be positive...' )
        slop = abs( slop );
    end
    %if it passes these...
    slop = double( slop );
else
    slop = 0;
end

if nargin == 4;
    if ~isnumeric( timeOffset )
        error( sprintf( 'Time offset input argument must be numeric and its current class is %s', class( timeOffset ) ) )
    elseif ndims( timeOffset ) > 2 | size( timeOffset ) ~= [ 1, 1 ];
        error( 'Time offset input argument not recognized! (it must be a scalar)' )
    end
    %if it passes these...
    timeOffset = double( timeOffset );
else
    timeOffset = 0;
end

fprintf( 'Allowable slop is %s seconds\n ', num2str( slop ) );
slop = slop/86400;
fprintf( 'Time offset is %s seconds\n ', num2str( timeOffset ) );
timeOffset = timeOffset/86400;
%end optional input arguments

tstart = tic;

A = sort( A );
B = sort( B );

setA = A.events;
setB = B.events;
numRecsA = size( setA, 1 );
numRecsB = size( setB, 1 );

% Adding slop to both sides
setA( :, 1 ) = setA( :, 1 ) - slop;
setA( :, 2 ) = setA( :, 2 ) + slop;

% Add time offset
setB( :, 1 ) = setB( :, 1 ) + timeOffset;
setB( :, 2 ) = setB( :, 2 ) + timeOffset;

obj = A;
obj.events = [ ];

count = 1;
evnts = [];
Jstart = 1;
for i = 1 : numRecsA;
    sTime = setA( i, 1 );
    eTime = setA( i, 2 );
    for j = Jstart : numRecsB;
        T1 = setB( j, 1 );
        T2 = setB( j, 2 );
        %case 1
        if sTime <= T1 & eTime >= T2;
            evnts( count, : ) = setA( i, : );
            count = count + 1;
            Jstart = j;
            break
        end
        %case 2
        if sTime >= T1 & eTime <= T2;
            evnts( count, : )=setA( i, : );
            count = count + 1;
            Jstart = j;
            break
        end
        %case 3
        if sTime >= T1 & sTime <= T2;
            evnts( count, : ) = setA( i, : );
            count = count + 1;
            Jstart = j;
            break
        end
        %case 4
        if sTime <= T1 & eTime >= T1;
            evnts( count, : ) = setA( i, : );
            count = count + 1;
            Jstart = j;
            break
        end
    end
end

obj.events = evnts;
if count > 1;
    obj = updateTimes( obj );
end

fprintf( 'Elapsed time %s seconds\n', num2str( toc( tstart ) ) );

end
