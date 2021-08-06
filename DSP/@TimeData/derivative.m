function dt = derivative( obj, n )
%
%
% Take derivative of signal, using boxcar with n points

nHalf=floor(n/2);
if( n-nHalf*2 ~= 0 )
    warning( sprintf( 'The odd number of point you specified: %d was rounded down to %d', n, nHalf*2 ) );
end

negHalf = zeros( 1, nHalf );
posHalf = negHalf;
posHalf = posHalf + 1;
negHalf = negHalf - 1;

c = [negHalf, posHalf]';

s = obj.samples;
dt= conv( s, c );
