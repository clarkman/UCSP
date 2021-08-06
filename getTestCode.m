function testCode = getTestCode( testTable, testString )

if ~iscell(testTable)
  error('1st arg must be cell array!')
end

sz = size(testTable);
numTestCodes = sz(2);

if nargin < 2
  % return number of ammo codes
  testCode = numTestCodes;
  return
end

for c = 1 : numTestCodes
  if strcmp( testTable{c}, testString )
    testCode = c;
    return
  end
end

error( [ 'Test: |', testString, '| not FOUND!' ] )
end
 
 
