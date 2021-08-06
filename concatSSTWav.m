function outName = concatSSTWav( dirname )

sensors = { '2168', '778', '1940', '756' };

currDir = pwd;
try cd( dirname )
  assy = [ dirname, '/Assy' ];
catch
  warning( [ 'Could not cd into: ', dirname ] )
  outName = '';
  return;
end

numSensors = numel(sensors);

for s = 1 : numSensors
  system( [ 'rm -fr ' assy ] );
  system( [ 'mkdir ' assy ] );
  dirn = [ dirname, '/', sensors{s} ];
  cmd = [ 'find  ', sensors{s}, ' -type f -name \*.zip -exec cp {} ', assy, ' \;' ];
  system( cmd );
  assynames = dir(assy);
  numfs = numel(assynames);
  cd( assy );
  for f = 1 : 20
  	thisZip = assynames(f).name;
  	stat = system( [ 'unzip ' assy, '/', thisZip ] )
    system( [ 'rm ', thisZip ] )
  end
  wavNames = dir;
  numWavs = numel( wavNames )
  for w = 1 : numWavs

  end
  return
end


cd( currDir )