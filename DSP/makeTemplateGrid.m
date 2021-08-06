function makeTemplateGrid( outFileName )


% Set up environment ...
[status, procDir] = system( 'echo -n $QFDC_PROC_PATH' );
if( length( procDir ) == 0 )
  display( 'env must contain QFDC_PROC_PATH variable' );
  if( interactive ), return;, else, exit;, end
end

% Open output file
fid = fopen( outFileName, 'w' );
if( fid == -1 )
  display( 'Could open output file for writing ...' );
  if( interactive ), return;, else, exit;, end
end

% Get dimensions
pixelDims = getXYcoord( procDir, 'upperRightCorner' );
xAxStart = getXYcoord( procDir, 'xAxisOrigin' );
xAxEnd = getXYcoord( procDir, 'xAxisInsertion' );
yAxStart = getXYcoord( procDir, 'yAxisOrigin' );
yAxEnd = getXYcoord( procDir, 'yAxisInsertion' );

leftMidnight = xAxStart(1) - 1;
rightMidnight = pixelDims(1) - leftMidnight - 2;
plotWidth = rightMidnight - leftMidnight;
plotHourStep = plotWidth / 24;

lowVolt = yAxStart(1) + 1;
hiVolt = pixelDims(2) - lowVolt + 2;
plotHeight = hiVolt - lowVolt;
plotVoltsStep = plotHeight / 10

fprintf( fid, '<?xml version="1.0" standalone="no"?>\n' );
fprintf( fid, '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">\n' );

fprintf( fid, '<image xlink:href="20071022.CMN.609.jpg" type="image/jpg" x="0" y="0" width="940" height="706" preserveAspectRatio="xMinYMin meet" />\n' );

fprintf( fid, '<image xlink:href="20071022.kp.svg" type="image/svg+xml" x="0" y="0" width="940" height="706" preserveAspectRatio="xMinYMin meet" />\n' );
%fprintf( fid, '<object data="20071022.kp.svg" type="image/svg+xml" height="940" width="706"> <img src="image-png.png" height="48" width="48" alt="this is a PNG" /> </object>\n' );

for lineth = 0 : 24
  x = leftMidnight + lineth * plotHourStep;
 % fprintf( fid, '  <line x1="%d" y1="%d" x2="%d" y2="%d" stroke="black" stroke-width="0.5"/>\n', x, lowVolt, x, hiVolt  );
end

fprintf( fid, '\n' );

for lineth = 0 : 10
  y = lowVolt + lineth * plotVoltsStep;
 % fprintf( fid, '  <line x1="%d" y1="%d" x2="%d" y2="%d" stroke="blue" stroke-width="0.5"/>\n', leftMidnight, y, rightMidnight, y  );
end

fprintf( fid, '</svg>\n' );

fclose( fid );
