function nz = findNonZero( arr )
% Column major
sz = size( arr );
if( sz(2) > 1 )
  error( 'One by only!' );
end

inds = find( arr ~= 0 );
sz = size( inds );
numFound = sz(1);
nz0 = zeros( numFound, 1 );
numth = 1;
for i = 1 : numFound
  nz0(numth)=arr(inds(i));
  numth = numth + 1;
end

nz = nz0;