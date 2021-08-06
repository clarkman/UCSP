function gVec = computeExpectedGravity( sensorOrient )

switch sensorOrient
  case 'l'
    gVec = [ -1, 0, 0 ];
  case 'r'
    gVec = [ 1, 0, 0 ];
  case 't'
    gVec = [ 0, -1, 0 ];
  case 'b'
    gVec = [ 0, 1, 0 ];
  case 'c'
    gVec = [ 0, 0, -1 ];
  case 'na'
    gVec = [ 0, 0, 0 ];
    warning( 'Sensor has no accelerometer')
  otherwise
    error( [ 'Unknown sensor orientation: ', sensorOrient ] )
end 
