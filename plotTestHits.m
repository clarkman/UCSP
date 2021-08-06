function histCnts = plotTestHits( testArr, tds, pulseArr, rangeArr )

% Leave a gap for missed tests:
highestTestNo = max([testArr.Test]);
xAxis = 1 : highestTestNo;

szMeta = size(testArr);
szData = size(tds);
numExps = szMeta(2);

if( numExps ~= szData(1) )
	error( 'Meta and Data size mismatch')
end

numSens = szData(2);
numChns = szData(3);
numSensChns = numSens * numChns;
pulseTimes = [pulseArr.PulseDateTime];
SensorIDNumbers = [pulseArr.SensorIDNumber];
taps = [testArr.Taps];

histCnts = zeros(2,highestTestNo);
histCnts(1,:) = xAxis;

% Plot firing positions 
found2 = 0;
found1 = 0;
for d = 1 : numExps
	if ~found2 & testArr(d).FP == 2
		found2 = d;
	end
	if ~found1 & testArr(d).FP == 1
		found1 = d;
	end
end
figure
line([found1,found1]-0.5,[0,100],'Color','k','LineStyle','--');
line([found2,found2]-0.5,[0,100],'Color','k','LineStyle','--');
line([21.5,21.5],[0,100],'Color','k','LineStyle','--');

% Gun colorizer
uniqueGuns = unique({testArr.Weapon});
numUniqueGuns = numel(uniqueGuns);

cmap = zeros(7,3);
cmap(1,:) = [ 0.9139    0.7258    0.3063 ];
cmap(2,:) = [ 0.9022    0.2376    0.5712 ];
cmap(3,:) = [ 0.0420    0.9481    0.5033 ];
cmap(4,:) = [ 0.0267    0.6642    0.7607 ];
cmap(5,:) = [ 0.6022    0.4376    0.5712 ];
cmap(6,:) = [ 0.5    0.5    0.5 ];


fPos = [rangeArr.fp];
fLos = [rangeArr.los];
fRng = [rangeArr.ft];
fSN = {rangeArr.sn};

posDat = zeros(4,numel(fPos));
posDat(1,:)=fPos;
posDat(2,:)=fLos;
posDat(3,:)=fRng;
for r = 1 : numel(fPos)
	posDat(4,:) = serialNo2IdNo(fSN{r});
end

doAll = 0;
if doAll
	startID = 4;
    titl = 'July 25 tests, Percentage hits, all tests'
else
	startID = 4;
    titl = 'July 25 tests, Percentage hits, line-of-sight tests'
end


for d = startID : numExps
	
	% Numerator
	td = tds{d,1,1}; % Hack
	dnBeg = td.UTCref;
	dnEnd = dnBeg + 4/86400; % (4 sec data)
	pInds = find( pulseTimes(:) >= dnBeg & pulseTimes(:) <= dnEnd );

	% Denominator
	numTaps = taps(d);
	maxSens = numSensChns;
	for s = 1 : numSens
		for c = 1 : numChns
			if isempty(tds{d,s,c})
				maxSens = maxSens - 1;
			end
		end
	end
	firingPosition = testArr(d).FP;
	fpInds = find( posDat(1,:) == firingPosition & posDat(2,:) == 0 );
	if doAll
		numBlocked = 0; %Force all
	else
		numBlocked = numel(fpInds);
	end
	if numBlocked
		display( sprintf( 'filtering non-LOS: %d', d ) );
		blocked = extractRows(posDat',fpInds);
		numerator = numel(pInds);
		pDets = extractRows(SensorIDNumbers',pInds);
		for b = 1 : numBlocked  % Reduce Numerator
			fInds = find(pDets == blocked(4,b));
			if numel(fInds) > 2
				error('Too many!')
			end
            numerator = numerator - numel(fInds);
			for s = 1 : numSens
				for c = 1 : numChns
					td = tds{d,s,c};
					if isempty(td)
						continue
					end
					if serialNo2IdNo(td.station) == blocked(4,b)
						maxSens = maxSens - numTaps;
					end
				end
			end
		end
	else
		numerator = numel(pInds);
	end
	maxTaps = ( maxSens / 6 ) * numTaps;
	% Quotient
	histCnts(2,testArr(d).Test) = 100.0 * ( numerator / maxTaps );

end

hold on;
for d = 1 : numExps
	for g = 1 : numUniqueGuns
		if strcmp(uniqueGuns{g},testArr(d).Weapon)
			%display( [ 'Found: ', testArr(d).Weapon, ' matching: ', uniqueGuns{g} ] );
			break
		end
	end
    stem( histCnts(1,d), histCnts(2,d), 'Color', cmap(g,:) )
end
xlabel('Test Number','FontSize',14);
ylabel('% Hit','FontSize',14);
set(gca,'XLim', [0 24])
set(gcf, 'OuterPosition', [ 400 500 1200 900 ] )

for t = 1 : numUniqueGuns
	text( 1, t*5+65, uniqueGuns{t}, 'Color', cmap(t,:), 'FontSize', 14 )
end
title(titl,'FontSize',14)

greyer = 0.218;
text( 12.5/2, 95, 'FP3', 'Color', [greyer,greyer,greyer], 'FontSize', 14, 'HorizontalAlignment', 'center' );
text( 14.5, 95, 'FP1', 'Color', [greyer,greyer,greyer], 'FontSize', 14, 'HorizontalAlignment', 'center' );
text( (21.5-16.5)/2+16.5, 95, 'FP2', 'Color', [greyer,greyer,greyer], 'FontSize', 14, 'HorizontalAlignment', 'center' );
text( (24-21.5)/2+21.5, 95, 'FP3', 'Color', [greyer,greyer,greyer], 'FontSize', 14, 'HorizontalAlignment', 'center' );

