function out = celMat( in )
sz1 = size(in);
sz2 = size(in{1});

if nargin < 2
	bound = 1
end

outArr = zeros(sz1(1),sz2(1));

for s = 1 : sz1(1)
	row = in{s}';
	scalor = max( abs(max(row)), abs(min(row)) )
	outArr(s,:) = row ./ scalor;
end

out = outArr;