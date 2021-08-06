function plotNoise( offs, sensors, testIdx )

szData = size(offs);
numExps = szData(1);
numSens = szData(2);
numChns = szData(3);

for s = 1 : numSens
	noiseVals = zeros( numExps, numChns );
	figure;
	for c = 1 : numChns
		for d = 1 : numExps
			offSummary = offs{d,s,c};
			noiseVals( d, c ) = offSummary(3);
			if noiseVals( d, c ) == -9999
				noiseVals( d, c ) = 0;
			end
		end
		hold on;
		plot(testIdx,noiseVals(:,c),'Marker','o');
	end
	title( [ 'Noise floors (std) for sensor: ', sensors{s} ] )
	legend( { 'IN1L - AccelX', 'IN1R - AccelY', 'IN2L - AccelZ', 'IN2R - Mic', 'IN3L - PbS', 'IN3R - Si'} )
	set(gca,'YScale','log')
	set(gca,'YGrid','on')
    set(gca,'YLim',[0.01 100])
	aa=get(gca,'YLim');
	horz = 3.5;
	line([horz,horz],aa,'Color','k','LineStyle','--');
	vert = aa(2)-0.05*(aa(2)-aa(1));
	text(horz,vert,'Gain change','Color','k','HorizontalAlignment','center');
	xlabel('Experiment')
	ylabel('\sigma millivolt units')
end
