function tdsOut = trimDigVol( tds )

szData = size(tds);
numExps = szData(1);
numSens = szData(2);

tdsTmp = tds;
div = undB(18);
for d = 1 : numExps
	for s = 1 : numSens
		display( sprintf('Correcting %d/%d',d,s) )
		td = tds{d,s,6};
		tdsTmp{d,s,6} = td ./ div;
	end
end

tdsOut = tdsTmp;