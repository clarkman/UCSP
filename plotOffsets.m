function plotOffsets( offs, sensors, testIdx )

szData = size(offs);
numExps = szData(1);
numSens = szData(2);
numChns = szData(3);

for s = 1 : numSens
	meanVals = zeros( numExps, numChns );
	figure;
	for c = 1 : numChns
		for d = 1 : numExps
			offSummary = offs{d,s,c};
			meanVals( d, c ) = offSummary(1);
			if meanVals( d, c ) == -9999
				meanVals( d, c ) = 0;
			end
		end
		hold on;
		plot(testIdx,meanVals(:,c),'Marker','o');
	end
	title( [ 'Signal centers for sensor: ', sensors{s} ] )
	legend( { 'IN1L - AccelX', 'IN1R - AccelY', 'IN2L - AccelZ', 'IN2R - Mic', 'IN3L - PbS', 'IN3R - Si'} )
	set(gca,'YLim',[-25 35])
	aa=get(gca,'YLim');
	horz = 3.5;
	line([horz,horz],aa,'Color','k','LineStyle','--');
	vert = aa(2)-0.05*(aa(2)-aa(1));
	text(horz,vert,'Gain change','Color','k','HorizontalAlignment','center');
	xlabel('Experiment')
	ylabel('Millivolt units')
	%set(gcf, 'OuterPosition', [ 400 500 1200 900 ] )
end
