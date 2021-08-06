function rows = extractNotRows( arr, inds )
% If inds empty, all

sz = size(inds);
if( isempty(inds) || sz(1) == 0 || sz(2) == 0 )
  rows = arr;
  return
end
if( sz(1) ~= 1 & sz(2) ~= 1 )
  error( 'inds must be nx1 or 1xn, where n >= 1' );
end
if( sz(2) > sz(1) ) % Juggle stuff
  inds = inds';
end

% Sort 
sz = size(inds); numInds = sz(1);
inds = sortrows( inds, 1 );

sz = size(arr);
if( sz(1) == 0 || sz(2) == 0 )
  warning( 'data array empty!!' );
  rows = arr;
  return
end

numRows = sz(1);
numCols = sz(2);

rowsT = zeros(numRows,numCols);
rowth = 0;
for r = 1 : numRows
  if isempty( find( inds == r ) ) % Take every non-match
    rowth = rowth + 1;
    rowsT(rowth,:) = arr(r,:);
  end
end

rows = rowsT(1:rowth,:);
