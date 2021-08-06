function qfdcColor = getRGBcolor( procDir, colorName )

cmd = sprintf( '%s/getQFDCcolor.plx %s', procDir, colorName );
[status, colorStr] = system( cmd );
if( length( colorStr ) == 0 )
  display( [ 'Get ', colorName, ' color FAILED!' ] );
  if( interactive ), return;, else, exit;, end
end
[vals, count] = sscanf( colorStr, '%f %f %f' );
qfdcColor = vals(2:4) ./ 255;
