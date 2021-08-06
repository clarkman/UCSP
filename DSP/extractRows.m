function rows = extractRows( arr, inds )
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

rowsT = arr;
rowth = 0;
for x = 1 : numInds
  rowth = rowth + 1;
  rowsT(rowth,:) = arr(inds(x),:);
end

rows = rowsT(1:rowth,:);
