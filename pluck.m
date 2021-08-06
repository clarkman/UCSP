function incidentIDs = pluck(incidentSet,incidentSelect)

numSelect = length(incidentSelect)

numInSet = length(incidentSet);

numFound = 0;
outArr = [];

for ith = 1 : numSelect
	fnd = find( incidentSet == incidentSelect(ith) );
	numFound = length(fnd) + numFound
	display(sprintf('Num found for %d = %d', incidentSelect(ith), length(fnd) ) )
	outArr = [ outArr ; fnd ];
end

incidentIDs = outArr;