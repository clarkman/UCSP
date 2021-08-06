function offs = getOffsets( hists )

szData = size(hists);
numExps = szData(1);
numSens = szData(2);
numChns = szData(3);

numBins = 4;

offsTmp = cell( numExps, numSens, numChns );

for d = 1 : numExps
	for s = 1 : numSens
		for c = 1 : numChns
			offSummary = zeros(8,1)-9999; 
			histTab = hists{d,s,c};
			histTab = histTab'; % Transpose
			nonEmptyIdx = find( histTab(:,1) ~= -9999 );
			if isempty(nonEmptyIdx)
				warning(sprintf('No data Found for: %d/%d/%d',d,s,c))
			else
				histTab = extractRows( histTab, nonEmptyIdx );
				histSort = sortrows( histTab, 3 );
				offSummary(1,1) = mean(histSort(1:numBins,1));
				offSummary(2,1) = mean(histSort(1:numBins,2));
				offSummary(3,1) = mean(histSort(1:numBins,3));
				offSummary(4,1) = mean(histSort(1:numBins,4));
				offSummary(5,1) = mean(histSort(1:numBins,5));
				offSummary(6,1) = mean(histSort(1:numBins,6));
				offSummary(7,1) = mean(histSort(1:numBins,7));
				offSummary(8,1) = mean(histSort(1:numBins,8));
			end		
			offsTmp{d,s,c} = offSummary;
		end
	end
end

offs = offsTmp;