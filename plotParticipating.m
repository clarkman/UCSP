function plotParticipating( hits, incs )

IncIDs = hits{3};
rounds = hits{2};
supprs = hits{6};
calibr = hits{5};


wins = find( IncIDs > 0 );
numShots = numel(wins);

incidents = incs(:,1);
sensorids = incs(:,2);
disposition = incs(:,8);

if ( numel(find(disposition<1)) > 0 )
	error('Non-participating found!')
end

sensorCounts = zeros(numShots,1);
axLabels = cell(numShots,1);
for ith = 1 : numShots
	incID = IncIDs(ith);
	axLabel = sprintf('%d',incID);
	shotSt = sprintf( ' = %d x %s', rounds(ith), calibr{ith} )
	if ~isempty(supprs{ith})
		axLabels{ith} = [ axLabel, '*', shotSt ];
	else
		axLabels{ith} = [ axLabel, shotSt ];
	end
	if( strcmp(axLabel,'-9999') )
		continue
	end
	incdnts = find(incidents==incID)
	sensorCounts(ith) = numel(unique(sensorids(incdnts)));
end

ids = 1 : numShots;
stem(sensorCounts);
set(gca,'XTick',ids);
set(gca,'XTickLabel',axLabels);
xtickangle(90);
%xlabel('IncidentID & Weapon');
ylabel('Average number of participating sensors per shot')
title('Participating sensors, Pittsfield, MA DQV, 2017-03-29');
set(gcf, 'OuterPosition', [ 400 500 1280 960 ] );
