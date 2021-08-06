function [ outArr, outInds ] = getGunInds(testArr,guns)

outArrTmp = testArr;

numExps = length(testArr);
indsTmp = zeros(1,numExps);

numGuns = length(guns)

numFound = 0;
for g = 1 : numGuns
	gun = guns{g};
	for ex = 1 : numExps
		if strcmp( testArr(ex).Weapon, gun )
			numFound = numFound + 1;
			sprintf( 'Found %s', gun );
			outArrTmp(numFound) = testArr(ex);
			indsTmp(numFound) = ex;
		end
	end
end

outArr = outArrTmp(1:numFound);
outInds = indsTmp(1:numFound);
