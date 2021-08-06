function ok = writeJpegFile( outputDir, fileName )

ok = false;

if system( [ 'ls ', outputDir ' > /dev/null' ] )
  error([ 'Output directory: ', outputDir, ' does not exist or you do not have permission!'])
end

if outputDir(end) ~= '/' % Be nice ...
  outputDir = [ outputDir, '/' ];
end

outPath = [ outputDir, fileName ];

setPlotSize();
orient portrait;

print( gcf, '-djpeg100', '-noui', outPath );

ok = true;