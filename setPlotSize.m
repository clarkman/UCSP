function setPlotSize()

pixelDims = [ 960, 706 ];
xAxStart = [ 60, 60 ];
xAxEnd = [ 900, 60 ];
yAxStart = [ 60, 60 ];
yAxEnd = [ 60, 640 ];

corner = 160;

figLeft = xAxStart(1);
figRight = xAxEnd(1);
figBottom = yAxStart(2);
figTop = yAxEnd(2);
figWidth = pixelDims(1)-2*figLeft;
figHeight = pixelDims(2)-2*figBottom;

set(gcf,'Position', [corner, corner, pixelDims(1), pixelDims(2)]);
set(gcf,'PaperPositionMode','auto');
set(gca,'Units','pixels');
set(gca,'Position', [figLeft+20, figBottom, figWidth, figHeight]);
