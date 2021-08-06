function [pCounts] = dCount( iLogger, incidentPulse )
%JOINDATA Joind two arrays created by readLabeledCSV and pluckData
%   Detailed explanation goes here

% Load and condition iLogger ground truth
guns = iLogger{19};
sensIL = iLogger{10};
incidentsIL = iLogger{4};

actualIncidents = find(incidentsIL~=-9999);
incidentsIL = incidentsIL(actualIncidents);
guns = guns(actualIncidents);
sensIL = sensIL(actualIncidents);

numInc = size(incidentsIL)

incs = incidentPulse{3};
serverTimes = incidentPulse{2};
pulseDateTimes = incidentPulse{5};
pulseTypes = incidentPulse{16};
dTs = zeros(numInc(1), 3)
pCounts = zeros(numInc(1), 5)
numHitsMax = 0;
numInc9mm = 0;
for inc = 1 : numInc
	if( strcmp( guns{inc}, 'Blank') || strcmp( guns{inc}, 'Pistol' ) )
		% 9mm
	else
		warning( [ 'Unknown gun type: ', guns{inc} ])
		continue
	end
	thisIncidentID = incidentsIL(inc);
	if(thisIncidentID == 0)
		continue
	end
	numInc9mm = numInc9mm + 1;
	hits = find( incs == thisIncidentID )
	sz = size(hits);
	numHits = sz(1)
	if numHits == 1
		if(pulseTypes(hits(1)) ~= 15)
			error('Whacko')
		end
	end
	numHitsMax = max(numHitsMax,numHits)
	numAudioMax = 0;
	numAccelMax = 0;
	numSWIRMax = 0;
	numMWIRMax = 0;
    for h = 1 : numHits
    	switch pulseTypes(hits(h))
    		case 15
    			numAudioMax = numAudioMax + 1;
    		case 16
    			numMWIRMax = numMWIRMax + 1;
    		case 17
    			numSWIRMax = numSWIRMax + 1;
    		case 18
    			numAccelMax = numAccelMax + 1;
    		otherwise
    			error('Bogus')
    	end
    end
    pCounts(numInc9mm,1) = thisIncidentID;
    pCounts(numInc9mm,2) = numAudioMax;
    pCounts(numInc9mm,3) = numMWIRMax;
    pCounts(numInc9mm,4) = numSWIRMax;
    pCounts(numInc9mm,5) = numAccelMax;
end

pCounts = pCounts(1:numInc9mm,:)
