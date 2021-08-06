function paramHistory( arr, lbls, parameter, site )
% PARAMHISTORY plot parameters from Parameter History table
% Dump 


serverTimes = arr{1};

friendlyNumbers = arr{3};
uniqueFriendlyNumbers = unique(friendlyNumbers);
numSensors = numel(uniqueFriendlyNumbers);

paramIDs = arr{4};
uniqueParamIDs = unique(paramIDs);
numParamIDs = numel(uniqueParamIDs);
uniqueSers = unique(arr{2});

values = arr{5};



switch parameter
case 156
	titl = [ 'SWIR DC voltages - ', site ];
	plotName=[ site, 'SWIRDC.jpg' ];
	badActor = 1;
case 157
	titl = [ 'MWIR DC voltages - ', site ];
	plotName=[ site, 'MWIRDC.jpg' ];
	badActor = 5;
case 158
	titl = [ '3v3 Vdd Supply voltages - ', site ];
	plotName=[ site, '3V3.jpg' ];
	badActor = 5;
end

figure;
for s = 1 : numSensors
	foundInds = find( friendlyNumbers == uniqueFriendlyNumbers(s) & paramIDs == parameter );
	hold on;
	vals = values(foundInds);
	maxVal =  max(vals);
	if( maxVal > 0.7 )
		display( sprintf('|%d|%s|%g|', uniqueFriendlyNumbers(s), uniqueSers{s}, maxVal ) )
	end
	plot( serverTimes(foundInds), vals )
end

datetick('x',15)
set(gca,'XLim',[min(serverTimes) max(serverTimes)])
set(gca,'YLim',[0 2])

xlabel('time')
ylabel('Volts DC')
title(titl);

print( gcf,'-djpeg100', '-noui', plotName );
