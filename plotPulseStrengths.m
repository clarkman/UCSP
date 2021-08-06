function plotPulseStrengths( truth, pulse, dateRange, plotName )


[ truth, pulse ] = timeChop( truth, pulse, dateRange );

tbl = joinPulses( truth, pulse );
sz = size(tbl);
lbls = [ 'Time', 'range', 'muzzle angle', 'LOS.BI', '[gun, caliber]', 'strength', 'sharpness', 'type' ];
data = zeros(sz(1),7);

guns = { 'StarterPistol', '6mm'; 'StarterPistol', '9mm'; 'Pistol', '9mm'; 'Pistol', '0.45'; 'Rifle', '0.22' };
gunIdxs = getGuns(tbl,guns);
szGuns = size(gunIdxs)
numGuns = szGuns(2);
gunColors = [ 0.6,0.2,0.2; 0.2,0.6,0.2; 0.2,0.2,0.6; 0.6,0.6,0.0; 0.4,0.2,0.4 ]

data(:,1) = extractNumeric( tbl, 4 );   % Time
data(:,2) = extractNumeric( tbl, 10 );  % range
data(:,3) = extractNumeric( tbl, 11 );  % IR FOV angle
data(:,4) = extractNumeric( tbl, 12 );  % LOS.BI
data(:,5) = extractNumeric( tbl, 21 );  % Strength
data(:,6) = extractNumeric( tbl, 22 );  % Sharpness
data(:,7) = extractNumeric( tbl, 19 );  % Type


%PulseType	Description
%15	IndoorAudioHHR
%16	IndoorMWIR
%17	IndoorSWIR
%18	IndoorAccel
pTypes = {'Audio','MWIR','SWIR','Accel'};
for pulseType = 15 : 18

    chan = pTypes{pulseType-14};
	figure;
	numGunsFound = 0;
	for gun = 1 : numGuns

		gunInds = gunIdxs{gun};
		gunRows = extractRows(data,gunInds);
		numGunRows = numel(gunRows);

		if ~isempty(gunRows)
			numGunsFound = numGunsFound + 1;
			pulseInds = find( gunRows(:,7) == pulseType );
			numPulses = numel( pulseInds );
			pulseRows = extractRows(gunRows,pulseInds);
			%p = polyfit(pulseRows(:,2),pulseRows(:,5),2);
			%x = 1 : ceil(max(pulseRows(:,2)));
			%y = polyval(p,x);
			hold on;
			plot(pulseRows(:,2),pulseRows(:,5), 'LineStyle', 'none', 'Marker', 'o','Color',gunColors(gun,:));
			%plot(x,y,'Color',gunColors(gun,:));
			hold off;
			lgnd{numGunsFound} = sprintf('%s %s - %d pulses total',guns{gun,2},guns{gun,1},numPulses);
			%lgnd{numGunsFound} = sprintf( 'fit = %f, %f, %f', p(1), p(2), p(3) );
		end

	end
	aa = get(gca,'YLim');
	set(gca,'YLim',[0, aa(2)]);
	legend(lgnd);
	xlabel('range - ft.')
	ylabel('Strength')
	title([ plotName, ' - ', chan]);
	%axis tight;
    set(gcf, 'OuterPosition', [ 400 500 1920 1280 ] )
    print( gcf,'-djpeg100', [ plotName, '.', chan '.jpg' ] );

end