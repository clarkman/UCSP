function tds = loadSSTDownload( dirName, sensors, chs )

numSensors = length(sensors);
numChs = length(chs);

files = cellstr(strsplit(ls( dirName ),'\n')');

tdsTmp = cell(numSensors,numChs);
for s = 1 : numSensors
  [ indsSensor, matchedSensor ] = matchStr( files, sensors{s} );
  if isempty(indsSensor)
  	continue
  end
  if length(indsSensor) ~= 6
    error( sprintf( 'Sensor count off = %d/%d', length(indsSensor), numSensors ) );
  end
  for c = 1 : numChs
  	[ indsChs, matchedCh ] = matchStr( matchedSensor, chs{c} );
    if length(indsChs) ~= 1
      error('Squawk Ch')
    end
    wavFile = matchedCh{1};
    dn = parseDatenum( wavFile );
    sn = parseSerialNo( wavFile );
    ch = parseCh( wavFile );
    chFileName = [ dirName, '/', wavFile ];
    samps = audioread( chFileName, 'native' );
    td = TimeData;
    td.source = wavFile;
    td.channel = ch;
    td.station = sn;
    td.UTCref = dn;
    td.samples = double(samps).* (1000/32768);
    td.sampleRate = 12000;
    tdsTmp{s,c} = td;
  end
end
tds = tdsTmp;