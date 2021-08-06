function shotAmplRange( bldg, iLogger, incidentPulse, pulseType )

szIL = size( iLogger );
szIP = size( incidentPulse );


% Load and condition iLogger ground truth
guns = iLogger{19};
sensIL = iLogger{10};
incidentsIL = iLogger{4};
rangesIL = iLogger{14};

actualIncidents = find(incidentsIL~=-9999 &  rangesIL>0);
incidentsIL = incidentsIL(actualIncidents);
guns = guns(actualIncidents);
sensIL = sensIL(actualIncidents);
rangesIL = rangesIL(actualIncidents)

sz = size(guns);
numIncidents = sz(1);
gunsBlank = zeros(numIncidents,2);
gunsPistol = zeros(numIncidents,2);
numGunsBlank = 0;
numGunsPistol = 0;
for g = 1 : numIncidents
	if strcmp( guns{g}, 'Blank')
		numGunsBlank = numGunsBlank + 1;
		gunsBlank(numGunsBlank,1) = incidentsIL(g);
		gunsBlank(numGunsBlank,2) = rangesIL(g);
	elseif strcmp( guns{g}, 'Pistol')
		numGunsPistol = numGunsPistol + 1;
		gunsPistol(numGunsPistol,1) = incidentsIL(g);
		gunsPistol(numGunsPistol,2) = rangesIL(g);
	else
		warning( [ 'Unknown gun type: ', guns{g} ])
	end
end
gunsPistol = gunsPistol(1:numGunsPistol,:);
gunsBlank = gunsBlank(1:numGunsBlank,:);


% Load and condition incident pulse result
duration    = incidentPulse{11};
centroid    = incidentPulse{12};
sensIP      = incidentPulse{4};
incidentsIP = incidentPulse{3};
pulseTypes  = incidentPulse{16};


% Loop twice
numMatchedBlanks = 0;
blankShots = zeros( numGunsBlank, 3 );
for b = 1 : numGunsBlank
	foundBlanks = find( incidentsIP == gunsBlank(b) & pulseTypes == pulseType );
	if ~isempty(foundBlanks)
		numFoundBlanks = size(foundBlanks);
		if( numFoundBlanks > 1 )
			warning(sprintf('More than one optical pulse reported for incident %d', gunsBlank(b)))
		end
		for bb = 1 : numFoundBlanks
	  		numMatchedBlanks = numMatchedBlanks + 1;
	        blankShots(numMatchedBlanks,1) = gunsBlank(b,2);
	        blankShots(numMatchedBlanks,2) = duration(foundBlanks(bb));
	        blankShots(numMatchedBlanks,3) = centroid(foundBlanks(bb));   
	    end
	end
end
blankShots = blankShots(1:numMatchedBlanks,:)

numMatchedPistols = 0;
pistolShots = zeros( numGunsPistol, 3 );
for b = 1 : numGunsPistol
	foundPistols = find( incidentsIP == gunsPistol(b) & pulseTypes == pulseType );
	if ~isempty(foundPistols)
		numFoundPistols = size(foundPistols);
		if( numFoundPistols > 1 )
			warning(sprintf('More than one optical pulse reported for incident %d', gunsPistol(b)))
		end
		for bb = 1 : numFoundPistols
	  		numMatchedPistols = numMatchedPistols + 1;
	        pistolShots(numMatchedPistols,1) = gunsPistol(b,2);
	        pistolShots(numMatchedPistols,2) = duration(foundPistols(bb));
	        pistolShots(numMatchedPistols,3) = centroid(foundPistols(bb));   
	    end
	end
end
pistolShots = pistolShots(1:numMatchedPistols,:)

if 1
  col = 2;
  lbl = 'Strength';
else
  col = 3;
  lbl = 'Sharpness';
end  


figure;
stem( blankShots(:,1), blankShots(:,col), 'LineStyle','none'  )
hold on;
stem( pistolShots(:,1), pistolShots(:,col), 'LineStyle','none'  )

switch pulseType
          case 15
            pTypTxt = 'Audio';
          case 16
            pTypTxt = 'MWIR';
          case 17
            pTypTxt = 'SWIR';
          case 18
            pTypTxt = 'Accelerometer';
          otherwise
            error('Unknown pulseType.')
end



legend( { 'Blank', 'Pistol' } )
ylabel( ['Gunshot ', lbl ] )
xlabel('range - feet')
title( [ pTypTxt, ' Blank vs. Pistol Range/Strength ', lbl, ' at: ', bldg ] )

plotName=[ bldg, '.', pTypTxt, '.', lbl, '.Range.jpg' ];
print( gcf,'-djpeg100', '-noui', plotName );
