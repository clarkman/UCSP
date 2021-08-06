function spoolPlot( names, ts )

numNames = numel(names);
numTimes = numel(ts);

if numTimes ~= numNames
	error('DimMismatch')
end

colrs = get(gca,'ColorOrder')
sMax = 10
for sensor = 1 : numNames
	name = names{sensor};
	segs = ts{sensor};
	numSegs = numel(segs)
	for seg = 1 : numSegs
		thisSeg = segs{seg};
		ht = sMax - sensor;
		line([thisSeg(1),thisSeg(2)],[ht,ht],'Marker','o','Color',colrs(mod(sensor,7)+1,:))
	end
	%set(gca,'ColorOrderIndex', get(gca,'ColorOrderIndex')+1)
end
aa = get( gca, 'XLim');
for sensor = 1 : numNames
	ht = sMax - sensor;
	text(aa(1)+1,ht+0.35,names{sensor})
end

set(gca,'YLim', [0 10])
datetick('x',6)
%legend(names)