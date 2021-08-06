function plotPulseRates( pTimes, pTypes, pType )

pLbls = { 'Audio', 'MWIR', 'SWIR', 'Accel' };

%pTypes = extractNumeric(pulses,9);
%pTimes = extractNumeric(pulses,2);

startx = min(pTimes);
display(sprintf('Pulses cover from %s to %s',datestr(startx),datestr(max(pTimes))))

hourFract=12;

dayth = 1/(24*hourFract);

dur = ceil((max(pTimes) - min(pTimes))*24*hourFract);
% Pulses cover from 29-Dec-2016 09:58:15 to 03-Jan-2017 10:39:37
bins = zeros(dur,2);

pInds = find( pTypes == pType );
numPulses = numel(pInds);
display( sprintf('%d %s pulses',numPulses,pLbls{pType-14}) )
pTimes = sortrows(pTimes(pInds));
for c = 1 : dur
	timth = startx + c * dayth;
	%datestr(timth)
	binth = numel( find(pTimes >= timth & pTimes < (timth + dayth) ) );
	bins(c,1) = timth;
	bins(c,2) = binth;
end

plot(bins(:,1),bins(:,2))
set(gcf, 'OuterPosition', [ 400 500 1920 1280 ] )
axPos = [ 0.075 0.075 0.9-0.025 0.9-0.025 ];
set(gca, 'Position', axPos )

set(gca,'FontSize',14)

datetick('x',6)
xlabel('date (midnight)')
ylabel('pulse rate per 15 min')
set(gca,'YScale','log')
set(gca,'XGrid','on')
set(gca,'YGrid','on')
title('Pulse Rates at SCAD Atlanta')
