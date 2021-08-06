function analyzeWallSignal( tdObjs )

gRange = 6;
vdd = 4.05;

vddToG = gRange / vdd;

accelX = tdObjs{2};
accelY = tdObjs{3};
accelZ = tdObjs{4};

accelX.samples = accelX.samples .* vddToG;
accelY.samples = accelY.samples .* vddToG;
accelZ.samples = accelZ.samples .* vddToG;

xSamps = accelX.samples;
ySamps = accelY.samples;
zSamps = accelZ.samples;

plot3(xSamps,ySamps,zSamps)
%plot3(accelX.samples,accelY.samples,accelZ.samples,'Marker','o','LineStyle','none')
hold on;
plot3(xSamps(1:1),ySamps(1:1),zSamps(1:1),'Marker','o','LineStyle','none','Color',[1 0 0])
% minAx = 1;
% maxAx = 5;
% set(gca,'XLim',[minAx, maxAx]);
% set(gca,'YLim',[minAx, maxAx]);
% set(gca,'ZLim',[minAx, maxAx]);
set(gca,'XLim',[min(accelX.samples), max(accelX.samples)]);
set(gca,'YLim',[min(accelY.samples), max(accelY.samples)]);
set(gca,'ZLim',[min(accelZ.samples), max(accelZ.samples)]);

