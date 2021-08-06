function plotSensorHistory( lbl, tbl, titl )

tcol = 3;
% 1                  2          3          4              5        6        7         8         9       10
% WGSSensorHistoryID,ComputerID,ServerTime,SensorIDNumber,StatTime,Latitude,Longitude,Elevation,Battery,Signal,
% 11          12   13    14      15        16         17        18            19              20
% Orientation,PDOP,Speed,Bearing,NoiseMean,NoiseSigma,WindSpeed,WindDirection,TemperatureDegC,UserStatus1,
% 21          22      23        24         25        26           27                       28
% UserStatus2,Weather,Reserved1,SensorMode,Condition,STATSequence,ExternalTriggerSharpness,SecondsSinceBoot,
% 29             30             31             32          33                34            35         36
% PrimaryMicGain,DroppedPackets,SequenceNumber,SpoolStatus,SensorStatusFlags,GPSSatellites,GPSMeanSNR,GPSSNR1,
% 37      38             39             40             41
% GPSSNR4,MagneticFieldX,MagneticFieldY,MagneticFieldZ,WGSSensorLinkHistoryID

% Which columns to plot.
cols = [ 5, 6, 7, 8, 9, 11, 12, 15, 16, 19, 27, 28, ];
numCols = numel( cols );

% Unique sensors
sids = unique(tbl{4});
numSids = numel(sids)

% times & start/stop
pulseTimes = tbl{tcol};
% tinds = find( pulseTimes > datenum(dateRange{1}) & pulseTimes < datenum(dateRange{2}) );
% pulseTimes = pulseTimes(tinds);
begT = min(pulseTimes);
finT = max(pulseTimes);

for s = 1 : numSids
	sidInds = find(tbl{4} == sids(s));
	sidtimes = tbl{3};
	sidtimes = sidtimes(sidInds);
	for ith = 1 : numCols
		col = cols(ith)
		items = tbl{col};
		items = items(sidInds);
		plotees = [ sidtimes, double(items) ];
		figure;
		plot( plotees(:,1), plotees(:,2) );
		title( [ titl, ' ', sprintf('%lu',sids(s)), ' ', lbl{col}, ' ', datestr(begT), ' to ', datestr(finT)  ] ); 
		fName = [ 'plots/', titl, ' history for ', sprintf('%lu',sids(s)), lbl{col}, '.jpg' ];
		datetick('x',6);
		set(gca,'XLim', [begT, finT]);
		saveas( gcf, fName, 'jpeg' );
		close('all');
	end
end