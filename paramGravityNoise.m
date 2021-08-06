function paramGravityNoise( arr, lbls, site )

serverTimes = arr{1};

friendlyNumbers = arr{3};
uniqueFriendlyNumbers = unique(friendlyNumbers);
numSensors = numel(uniqueFriendlyNumbers);

paramIDs = arr{4};
uniqueParamIDs = unique(paramIDs);
numParamIDs = numel(uniqueParamIDs);
uniqueSers = unique(arr{2});

values = arr{5};


titl = [ 'Gravity Vector noise - ', site ];
plotName=[ site, 'gvector.jpg' ];
badActor = 1;

%figure;
minT = 10e10;
maxT = -1;
for s = 1 : numSensors
	foundXs = find( friendlyNumbers == uniqueFriendlyNumbers(s) & paramIDs == 152 );
	foundYs = find( friendlyNumbers == uniqueFriendlyNumbers(s) & paramIDs == 153 );
	foundZs = find( friendlyNumbers == uniqueFriendlyNumbers(s) & paramIDs == 154 );
	volts3V3 = find( friendlyNumbers == uniqueFriendlyNumbers(s) & paramIDs == 158 );
	numAccelX = numel(foundXs);
	numAccelY = numel(foundYs);
	numAccelZ = numel(foundZs);
	numVolts3 = numel(volts3V3);
	if( numAccelX ~= numAccelY || numAccelX ~= numAccelZ || numAccelX ~= numVolts3 )
		warning( sprintf( 'Accelerometer count mismatch %d/%d/%d/%d', numAccelX, numAccelY, numAccelZ, numVolts3 ) );
		continue
	end
	vals3V = values(volts3V3) / 2;
	valsX = values(foundXs);
	valsY = values(foundYs);
	valsZ = values(foundZs);
	for v = 1 : numAccelX
		valsX(v) = valsX(v) - vals3V(v);
		valsY(v) = valsY(v) - vals3V(v);
		valsZ(v) = valsZ(v) - vals3V(v);
	end
	meanX = mean(valsX);
	meanY = mean(valsY);
	meanZ = mean(valsZ);
	meanVec = [ meanX, meanY, meanZ ];
	dots = zeros( numAccelX, 1 );
	for v = 1 : numAccelX
		vec = [valsX(v), valsY(v), valsZ(v)];
		dots(v) = acosd(dot( meanVec/norm(meanVec), vec/norm(vec) ));
	end
	hold on;
	plot( serverTimes(foundXs), dots )
	minT = min( minT, min(serverTimes) );
	maxT = max( maxT, max(serverTimes) );
end

datetick('x',15);

xlabel('time')
ylabel('degrees')
title(titl);
set(gca,'YScale','log')
set(gca,'XLim',[minT maxT])
set(gca,'YLim',[1e-4 2])
set(gca,'YGrid','on')

print( gcf,'-djpeg100', '-noui', plotName );
