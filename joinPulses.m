function tbl = joinPulses( truth, pulse )


sz = size(truth);
numTruthRows = sz(1);
numTruthCols = sz(2);
sz = size(pulse);
numPulseRows = sz(1);
numPulseCols = sz(2);

if numPulseRows < numTruthRows
	error('Conceptual')
end

truthTimes = extractNumeric( truth, 4 );
pulseTimes = extractNumeric( pulse, 2 );
% datestr(min(pulseTimes))
% datestr(max(pulseTimes))

truthIDs = extractNumeric( truth, 7, 'uint64' );
pulseIDs = extractNumeric( pulse, 4, 'uint64' );

incIds = extractNumeric( truth, 3 );


epBeg = 2/86400;
epFin = 4/86400;
% Don't duplicate SensorID
rth = 0;
numOutCols = numTruthCols+numPulseCols-1;
%tblTmp = cell( numPulseRows, numTruthCols+numPulseCols-1 );
for r = 1 : numTruthRows
	if incIds(r) < 0
		continue
	end
	tTime = truthTimes(r);
	tID = truthIDs(r);
	pInds = find( pulseTimes >= tTime-epBeg & pulseTimes < tTime+epFin & tID == pulseIDs );
	if isempty( pInds )
		error('Conceptual')
	end
	numHits = length(pInds);
	for hit = 1 : numHits
		rth = rth+1;
		for c = 1 : numTruthCols
			tblTmp{rth,c} = truth{r,c};
		end
		for c = numTruthCols+1 : numOutCols
			tblTmp{rth,c} = pulse{pInds(hit),c-numTruthCols};
		end
	end
end

size(tblTmp)

tbl = tblTmp;