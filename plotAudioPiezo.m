function hndl = plotAudioPiezo( tAx, segs, titl )

hndl = figure;
plot(tAx,segs(:,1));
hold on;
plot(tAx,segs(:,2));
hold off;
setPlotSize();
xlabel('Time (secs)')
ylabel('Amplitude')
set(gca,'YTick',[-1.0, -0.9, -0.8, -0.7, -0.6, -0.5, -0.4, -0.3, -0.2, -0.1, 0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 ])
set(gca,'YTickLabel',{'-1.0', '-0.9', '-0.8', '-0.7', '-0.6', '-0.5', '-0.4', '-0.3', '-0.2', '-0.1', '0', '+0.1', '+0.2', '+0.3', '+0.4', '+0.5', '+0.6', '+0.7', '+0.8', '+0.9', '+1.0' })
title( titl )
set(gca,'YLim', [-1.05, 1.05])
legend( { 'audio', 'piezo' } )

