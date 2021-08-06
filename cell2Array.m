function [ arr ] = cell2Array( cel )
%CELL2ARRAY Convert cellular vector of numeric vectors to two dimensional array
%   Works with the output of pluckArray
%   Vector must be 1 x M or M x 1 
%   Each array in vector must be N x 1 or 1 x N
%   Each array in vector must the same dimensions
%   Each array in vector must be numeric
%   For 1 x M cell vector, output will be N x M
%   For M x 1 cell vector, output will be M x N

% Get dimensions
[ rows, cols ] = size(cel);

if rows ~= 1 && cols ~= 1
	error('cell2Array does not deal in more than 2 dimensional arrays!');
end

if rows == 1
    transpose = 1;
else
    transpose = 0;
end

idx = max( rows, cols );

testr = cel{1};
sz0 = size(testr);
% Checks. 
for id = 1 : idx
    arrTmp = cel{id};
    if ~isnumeric(arrTmp)
        error('cell2Array only works on numeric values!')
    end
    sz = size(arrTmp);
    if( sz(1) ~= 1 && sz(2) ~= 1 )
        error('cell2Array requires all numeric vectors to be one dimensional!')
    end
    if( sz0(1) ~= sz(1) || sz0(2) ~= sz(2) )
        error('cell2Array requires all numeric vectors to be the same size!')
    end
end
% Free memory
clear arrTmp sz testr

% Calculate array size and create
idy = max(sz0);
arrTmp = zeros(idy,idx);

for x = 1 : idx
    arrTmp(:,x) = cel{x};
end

arr = arrTmp;
