function plotRails( offs, sensors )

szData = size(offs);
numExps = szData(1);
numSens = szData(2);
numChns = szData(3);

for s = 1 : numSens
	maxVals = zeros( numExps, numChns );
	minVals = zeros( numExps, numChns );
	figure;
	for c = 1 : numChns
		for d = 1 : numExps
			offSummary = offs{d,s,c};
			minVals( d, c ) = offSummary(7);
			if minVals( d, c ) == -9999
				minVals( d, c ) = 0;
			end
			maxVals( d, c ) = offSummary(8);
			if maxVals( d, c ) == -9999
				maxVals( d, c ) = 0;
			end
		end
		hold on;
		plot(minVals(:,c));
		%plot(maxVals(:,c));
	end
	title( [ 'Maxima for sensor: ', sensors{s} ] )
	legend( { 'IN1L - AccelX', 'IN1R - AccelY', 'IN2L - AccelZ', 'IN2R - Mic', 'IN3L - PbS', 'IN3R - Si'} )
	%set(gca,'YScale','log')
	set(gca,'YGrid','on')
   % set(gca,'YLim',[-0.7 0.7])
	aa=get(gca,'YLim');
	horz = 3.5;
	line([horz,horz],aa,'Color','k','LineStyle','--');
	vert = aa(2)-0.05*(aa(2)-aa(1));
	text(horz,vert,'Gain change','Color','k','HorizontalAlignment','center');
end
