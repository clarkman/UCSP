function secs = getPlotLength()

aa = get( gca, 'XLim' );
secs = aa(2) - aa(1);