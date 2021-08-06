function histCnts = plotCELStrength( testArr, tds, pulseArr, rangeArr )

szMeta = size(testArr);
szData = size(tds);
numExps = szMeta(2);

if( numExps ~= szData(1) )
	error( 'Meta and Data size mismatch')
end


linCEL=undB([testArr.CEL])

for d = 4 : numExps

end