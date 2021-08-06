function xducerCode = getXducerCode( xducerTable, xducerString )

if ~iscell(xducerTable)
  error('First argument must be transducer table!');
end

sz = size( xducerTable );
numXducerCodes = sz(1);

if nargin < 2
  % return number of transducer codes
  xducerCode = numXducerCodes;
  return
end

for c = 1 : numXducerCodes
  if strcmp( xducerTable{c,2}, xducerString )
    xducerCode = c;
    return
  end
end

error( [ 'Transducer: |', xducerString, '| not FOUND!' ] )
