function plotPulseEvents( sids, pTypes, sensors )

[ counts, sensorSet, pulseSet ] = countPulseEvents( sids, pTypes );

sz = size(counts);
numSensors = sz(1);
numPulses = sz(2);

pSliver = 0.1;
pOffs=linspace(0,pSliver*(numPulses-1),numPulses);

ssids = linspace(1,numSensors,numSensors);
sensorIDs=extractNumeric(sensors,1,'uint64');
friendlies=extractNumeric(sensors,2);
for s = 1 : numSensors
	sInd = find( sensorIDs == sensorSet(s) );
	xlbl(s,:) = sprintf('%06d',friendlies(sInd(1)));
end

pLbls = { 'Audio', 'MWIR', 'SWIR', 'Accel' };
for p = 1 : numPulses
	pId = pulseSet(p);
	pInds = find( pTypes == pId );
	lgnd{p} = sprintf('%d,%s has %d total pulses.',pId,pLbls{p},numel(pInds));
	stem(ssids+pOffs(p),counts(:,p))
	hold on;
end

legend(lgnd)
title( 'Total Pulse Counts SCAD - Atlanta 2016-11-30 12:58:59 to 2016-12-05 13:03:31')
title( 'Total Pulse Counts NMHS - Newark 2016-11-30 13:54:14 to 2016-12-05 14:41:16')

xlabel('Sensor friendly number');
ylabel('Pulse count');
set(gca,'YScale','log');
set(gca,'YGrid','on');

set(gca,'XTick',ssids);
set(gca,'XTickLabel',xlbl,'XTickLabelRotation',45);
set(gcf, 'OuterPosition', [ 400 500 1920 1280 ] )

