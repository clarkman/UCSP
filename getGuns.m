function gunIdxs = getGuns( truth, guns )
%GETGUNS exmaine a truth table and provide listing of gun indexes 

typeCol = 13;
calbCol = 14;

szGuns = size(guns);
numGuns = szGuns(1);
szTruth = size(truth);
numShots = szTruth(1);

numTotal = 0;
for gRow = 1 : numGuns
	thisGunIdxs = zeros(1,numShots);
	numFound = 0;
	for tRow = 1 : numShots
		if strcmp( guns{gRow,1}, truth{tRow,typeCol} ) && strcmp( guns{gRow,2}, truth{tRow,calbCol} )
			numTotal = numTotal + 1;
			numFound = numFound + 1;
			thisGunIdxs(numFound) = tRow;
			%display('match')
		end
	end
	if ~numFound
		display(sprintf('%s - %s not found',guns{gRow,1},guns{gRow,2}))
	end
	thisGunIdxs = thisGunIdxs(1:numFound);
	gunIdxsTmp{gRow} = thisGunIdxs;
end

if(numTotal ~= numShots)
	error('Incomplete match!')
end

gunIdxs = gunIdxsTmp;