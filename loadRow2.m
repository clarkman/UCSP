function tdObjs = loadRow2( row, m, testStrs, gunStrs, ammoStrs, xducerStrs, labJackStrs )
% Each transducer appears only once per row

fRoot = '/Users/cuz/Desktop/Projects/SST/Artemis';

mRow = m(row(1,1),:);

sampleRate = 24000;

if mRow(14) == 1
  fRoot = [ fRoot, '/2016-02-11' ];
  fName = checkFile( makeRawName( mRow, testStrs, gunStrs, ammoStrs, xducerStrs, fRoot ) );
elseif mRow(14) > 1
  fRoot = [ fRoot, '/', datestr(mRow(12),'yyyy-mm-dd') ];
  fName = checkFile( makeRawName2( mRow, testStrs, gunStrs, ammoStrs, xducerStrs, labJackStrs, fRoot ) );
else
  error( 'Unknown SW version' );
end

tdObjsTmp = readData( fName, sampleRate, mRow(3), mRow(12) );

for obj = 1 : numel(tdObjsTmp)
  td = tdObjsTmp{obj};
  td.channel = getXducerStr(xducerStrs,mRow(6+obj));
  td.UTCref = mRow(12);
  td.sampleRate = sampleRate;
  tdObjs{obj} = td;
end