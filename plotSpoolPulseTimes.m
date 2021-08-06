function plotSpoolPulseRates( lbl, tbl, titl )

tcol = 2;
% 1           2          3          4              5             6        7         8         9           10           11       12          13
% PulseNumber,ServerTime,ComputerID,SensorIDNumber,PulseDateTime,Latitude,Longitude,Elevation,ArrivalTime,AcousticZone,UseCount,Disposition,Length,
% 14       15        16        17            18              19           20   21        22           23             24            25                   
% Strength,Sharpness,Asymmetry,SignalToNoise,PrelimPulseRate,DeltaTrigger,PDOP,PulseType,ReservedEnum,PrepulseEnviro,EnvelopeShape,EnvelopeConst,
% 26          27            28       29        30         31             32                33        34      35           36             37
% EnvelopeFit,FrequencyPeak,Distance,Direction,Confidence,IncidentTypeID,IncidentSubTypeID,ShotIndex,Azimuth,AzimuthError,ElevationAngle,ComputedAzimuth,
% 38                     39            40            41            42            43            44         45                46
% ComputedElevationAngle,PulseFeature0,PulseFeature1,PulseFeature2,PulseFeature3,PulseFeature4,RawAzimuth,RawElevationAngle,PulseFeatureSet,
% 47            48            49            50            51            52             53             54             55             56             57
% PulseFeature5,PulseFeature6,PulseFeature7,PulseFeature8,PulseFeature9,PulseFeature10,PulseFeature11,PulseFeature12,PulseFeature13,PulseFeature14,PulseFeature15

% Unique sensors
sids = unique(sids);
numSids = numel(sids)


% times & start/stop
pulseTimes = tbl{tcol};
begT = min(pulseTimes);
finT = max(pulseTimes);


for s = 1 : numSids
	figure;
	sidInds = find( tbl{4} == sids(s) );
	PulseDateTimes = tbl{5};
	PulseDateTimes = PulseDateTimes(sidInds);
	plot( pulseTimes(sidInds), PulseDateTimes );
	hold on;
	ArrivalTimes = tbl{9};
	ArrivalTimes = ArrivalTimes(sidInds);
	plot( pulseTimes(sidInds), ArrivalTimes, 'LineStyle', '--' );
	title( [ titl, ' ', 'time plot for ', sprintf('%lu',sids(s)) ] ); 
	fName = [ 'plots/', 'times', sprintf('%lu',sids(s)), titl, '.jpg' ];
	datetick('x',6);
	datetick('y',23);
	set(gca,'XLim', [begT, finT]);
	legend({'PulseDateTime','ArrivalTime'},'Location','best')
	saveas( gcf, fName, 'jpeg' );
	close('all');
end