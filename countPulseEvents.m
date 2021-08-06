function [ counts, sensorSet, pulseSet ] = countPulseEvents(sids,pTypes)

pSliver = 0.1
pOffs=linspace(0,pSliver*3,4);

sensorSet=unique(sids);
numSensors = numel(sensorSet);

pulseSet=unique(pTypes);
numPulseTypes=numel(pulseSet);

counts = zeros(numSensors,numPulseTypes);
for s = 1 : numSensors
	sensor = sensorSet(s);
	sInds = find( sids == sensor );
	sensorPulses = sids(sInds);
	pulseTypes = pTypes(sInds);
	display( sprintf('%ld has %d pulses', sensor, numel(sensorPulses) ) )
	for p = 1 : numPulseTypes
		pulseType = pulseSet(p);
		pInds = find( pulseTypes == pulseType );
		if ~isempty(pInds)
			counts(s,p) = numel(pInds);
		end
	end
end