function plotPulseInterarrTimes( sid, sids, pTypes, dns, strengths )

sIdxs = find( sids == sid & pTypes == 17 );

dn=dns(sIdxs);

diffTs = (dn(2:end) - dn(1:end-1))*86400;

diffTs = diffTs(find(diffTs<=1));

h = histogram(diffTs,4000)
y=h.Values;
pd = fitdist(y','Exponential')
x=h.BinEdges(1:end-1);


histogram(diffTs,1000);

xlabel('Inter-Arrival times in seconds')
ylabel('Counts')
title('Histogram of pulse inter-arrival times, SWIR, 010420, 4th floor SCAD-ATL 1600 bldg.');

set(gcf, 'OuterPosition', [ 400 500 1920 1280 ] )
%set(gca,'XLim',[0 100])
%set(gca,'YLim',[0 10])

return

stem(dns(sIdxs),strengths(sIdxs))





datetick('x',31);
ep = 1/24;
set(gca,'XLim',[min(dns)-ep max(dns)+ep])

set(gca, 'YGrid', 'on' )
set(gca, 'XGrid', 'on' )

