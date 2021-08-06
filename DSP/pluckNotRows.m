function rows = pluckNotRows( array, notInds )

sz = size( array );
nRows = sz(1);
nCols = sz(2);

sz = size( notInds );
if( sz(2) ~= 1 )
	error( sprintf( 'inds must be nx1!  Is: %dx%d', sz(1), sz(2) ) );
end
nInds = sz(1);
if( nInds < 1 )
  warning( 'Nothing to do!' );
  return
end
if( nInds == nRows )
  warning( 'Nothing to do!' )
  return
end
maxInd = max( notInds );
if( maxInd > nRows )
	error( sprintf( 'inds contains rows higher (%d) than number of rows in array (%d)', maxInd, nRows ) );
end
minInd = min( notInds );
if( minInd < 1 )
	error( sprintf( 'inds contains rows less than one (%d)', minInd ) );
end

rowsTmp = zeros( nRows - nInds, nCols );
for r = 1 : nInds
  rowsTmp(r,:) = array(notInds(r),:);
end

rows = rowsTmp;
