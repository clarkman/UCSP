function rows = pluckRows( array, inds, sortem )
%  $Id: pluckRows.m,v d4e01bc08f7c 2013/10/28 18:54:34 qcvs $

sz = size( array );
nRows = sz(1);
nCols = sz(2);

sz = size( inds );
nInds = sz(1);
if( nInds < 1 )
  warning( 'Nothing to do, no inds supplied!' );
  rows = array;
  return
end
if( sz(2) ~= 1 )
  warning( sprintf( 'inds must be nx1!  Is: %dx%d', sz(1), sz(2) ) );
  rows = array;
  return
end
if( nInds == nRows )
  warning( 'Nothing to do, row & Ind counts match!' )
  rows = array;
  return
end

maxInd = max( inds );
if( maxInd > nRows )
	error( sprintf( 'inds contains rows higher (%d) than number of rows in array (%d)', maxInd, nRows ) );
end
minInd = min( inds );
if( minInd < 1 )
	error( sprintf( 'inds contains rows less than one (%d)', minInd ) );
end

if nargin > 3
	inds = sortrows( inds );
end

rowsTmp = zeros( nInds, nCols );
for r = 1 : nInds
  rowsTmp(r,:) = array(inds(r),:);
end

rows = rowsTmp;
