function plotPulseHistory( sid, sids, pType, pTypes, dns, strengths )

sIdxs = find( sids == sid & pTypes == pType );

stem(dns(sIdxs),strengths(sIdxs))
set(gcf, 'OuterPosition', [ 400 500 1920 1280 ] )
set(gca,'FontSize',14)

xlabel('Local Time - EST')
ylabel('Pulse Strength')

datetick('x',31);
ep = 0/24;
set(gca,'XLim',[min(dns)-ep max(dns)+ep])

set(gca, 'YGrid', 'on' )
set(gca, 'XGrid', 'on' )

