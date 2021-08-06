function arr = packNumeric( vals )


sz = size(vals);
numRows = sz(1);
numCols = sz(2);

arrTmp = zeros( sz(1), sz(2) );

for col = 1 : numCols
	arrTmp(:,col) = extractNumeric(vals,col);
end

arr = arrTmp;