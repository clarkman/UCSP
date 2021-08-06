function tdObjs = readData( fName, sampRate, numChans, kickoffTime )

fid = fopen( fName );
if( fid == -1 )
  error( [ 'Could not open: ' fName ] );
end

samps = fread( fid, [numChans inf],'double');

fclose( fid );

%size(samps)
for chan = 1 : numChans
  %samps(chan,1:10)
  tdObj = TimeData;
  tdObj.source = fName;
  tdObj.UTCref = kickoffTime;
  tdObj.sampleRate = sampRate;
  tdObj.samples = samps(chan,:)';
  tdObjs{chan} = tdObj;
end
