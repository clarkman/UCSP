function labjackCode = getLabjackCode( labjackTable, labjackString )

if ~iscell(labjackTable)
  error('1st arg must be cell array!')
end

sz = size(labjackTable);
numLabjackCodes = sz(2);

if nargin < 2
  % return number of ammo codes
  labjackCode = numLabjackCodes;
  return
end

for c = 1 : numLabjackCodes
  if strcmp( labjackTable{c}, labjackString )
    labjackCode = c;
    return
  end
end

error( [ 'Labjack: |', labjackString, '| not FOUND!' ] )
end
 
 
