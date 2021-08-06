function [dTs] = dTime( iLogger, incidentPulse )
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
serverTimes = incidentPulse{9}./86400+datenum('1904-01-01 00:00:00')-4/24;
pulseDateTimes = incidentPulse{5};
pulseTypes = incidentPulse{16};
dTs = zeros(numInc(1), 8)
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
	audioPulseDateTime = 0;
	audioServerTime = 0;
	mwirPulseDateTime = 0;
	mwirServerTime = 0;
	swirPulseDateTime = 0;
	swirServerTime = 0;
	accelPulseDateTime = 0;
	accelServerTime = 0;
    for h = 1 : numHits
    	switch pulseTypes(hits(h))
    		case 15
    			audioPulseDateTime = pulseDateTimes(hits(h));
    			audioServerTime = serverTimes(hits(h));
    		case 16
   				mwirPulseDateTime = pulseDateTimes(hits(h));
    			mwirServerTime = serverTimes(hits(h));
    		case 17
				swirPulseDateTime = pulseDateTimes(hits(h));
    			swirServerTime = serverTimes(hits(h));
       		case 18
				accelPulseDateTime = pulseDateTimes(hits(h));
    			accelServerTime = serverTimes(hits(h));
       		otherwise
    			error('Bogus')
    	end
    end
    dTs(numInc9mm,1) = thisIncidentID;
    dTs(numInc9mm,2) = audioPulseDateTime;
    dTs(numInc9mm,3) = audioServerTime;
    dTs(numInc9mm,4) = mwirPulseDateTime;
    dTs(numInc9mm,5) = mwirServerTime;
    dTs(numInc9mm,6) = swirPulseDateTime;
    dTs(numInc9mm,7) = swirServerTime;
    dTs(numInc9mm,8) = accelPulseDateTime;
    dTs(numInc9mm,9) = accelServerTime;
end

dTs = dTs(1:numInc9mm,:)
