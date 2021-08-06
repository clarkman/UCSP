function logLogPlot( x, y )

plot( x, y, 'LineStyle', 'none', 'Marker', 'o' )
set(gca,'XScale','log')
set(gca,'YScale','log')
set(gca,'XGrid','on')
set(gca,'YGrid','on')
