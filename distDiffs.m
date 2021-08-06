function distArr = distDiffs(arr);

sz = size(arr);
numRows = sz(1) - 1; % One less for diffs

distArrTmp = zeros(numRows,3); % datenum, diff-Km

for r = 2 : sz(1)
	currRow = r - 1;
	distArrTmp(r-1,1) = arr(r,2);
	distArrTmp(r-1,2) = earthDistance([arr(r,3) arr(r,4)], [arr(currRow,3) arr(currRow,4)]);
	distArrTmp(r-1,3) = arr(r,6);	
end

distArr = distArrTmp;