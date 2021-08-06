function rows = extractNoRows( arr, inds )
%  $Id: extractNoRows.m,v d4e01bc08f7c 2013/10/28 18:54:34 qcvs $
% If inds empty, null

sz = size(inds);
if( isempty(inds) || sz(1) == 0 || sz(2) == 0 )
  rows = zeros(0,0);
  return
end
if( sz(1) ~= 1 & sz(2) ~= 1 )
  error( 'inds must be nx1 or 1xn, where n >= 1' );
end
if( sz(2) > sz(1) )
  inds = inds';
end

sz = size(inds); numInds = sz(1);
inds = sortrows( inds, 1 );

sz = size(arr);
if( sz(1) == 0 || sz(2) == 0 )
  warning( 'data array empty!!' );
  rows = arr;
  return
end
numRows = sz(1);

if( numRows < inds(end) )
  error( 'inds higher than size of arr found!!' );
end

msk=zeros(numRows,1)+1;
for ind = 1 : numInds
  msk( inds(ind) ) = 0;
end

rowsT = arr;
rowth = 0;
for x = 1 : numRows
  if( msk(x) == 0 )
    continue
  end
  rowth = rowth + 1;
  rowsT(rowth,:) = arr(x,:);
end

rows = rowsT(1:rowth,:);
