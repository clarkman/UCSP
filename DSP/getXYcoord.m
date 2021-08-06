function qfdcCoord = getXYcoord( procDir, coordName )

cmd = sprintf( '%s/getQFDCcoord.plx %s', procDir, coordName );
[status, coordStr] = system( cmd );
if( length( coordStr ) == 0 )
  display( [ 'Get ', coordName, ' coord FAILED!' ] );
  if( interactive ), return;, else, exit;, end
end
[vals, count] = sscanf( coordStr, '%f %f %f' );
qfdcCoord = vals(1:2);
