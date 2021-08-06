function [ num ] = extractNumeric( cel, col, fmt )
% EXTRACTDATENUM Pull numeric values from cell array created by pluckVals

sz = size(cel);
numRows = sz(1)

if nargin < 3
  numTmp = zeros(numRows,1);
else
  numTmp = zeros( numRows, 1, fmt );
end
for r = 1 : numRows
    numTmp(r) = cel{r,col};
end
num = numTmp;

