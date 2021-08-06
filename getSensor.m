function sensor = getSensor( sensorArray, sensorNumber )

sz = size(sensorArray)

for s = 1 : sz(2)
  if sensorArray(s).sensId == sensorNumber
  	break;
  end
end

sensor = sensorArray(s);