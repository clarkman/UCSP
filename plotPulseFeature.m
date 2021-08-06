function plotPulseFeature( truth, pulse, dateRange, colName )


[ truth, pulse ] = timeChop( truth, pulse, dateRange );

tbl = joinPulses( truth, pulse );
sz = size(tbl);


lbls = [ 'Time', 'range', 'muzzle angle', 'LOS.BI', '[gun, caliber]', 'strength', 'sharpness' ];
data = zeros(sz(1),7);

data(:,1) = extractNumeric( tbl, 4 );   % Time
data(:,2) = extractNumeric( tbl, 10 );  % range
data(:,3) = extractNumeric( tbl, 11 );  % IR FOV angle
data(:,4) = extractNumeric( tbl, 12 );  % LOS.BI
data(:,5) = extractNumeric( tbl, 21 );  % Strength
data(:,6) = extractNumeric( tbl, 22 );  % Sharpness
data(:,7) = extractNumeric( tbl, 19 );  % Type

audio = find(data(:,7)==17);
numAudio = numel(audio)
audioEvents = extractRows(data,audio);

plot(data(:,2),data(:,5), 'LineStyle', 'none', 'Marker', 'o')
%set(gca,'YScale','log')
