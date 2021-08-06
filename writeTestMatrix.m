function writeTestMatrix( m, fName, fmt, titl )

sz = size(m);
if sz(2) ~= 14
  error('Column miscount!')
end
numRows = sz(1);
numCols = sz(2);

switch fmt
  case 'csv'
  	fileName = [ fName, '.', fmt ];
  	metaName = [ fName, '.meta' ];
  otherwise
    error( [ 'Unknown format: ', fmt ] )
end

%testGetters();
testStrs = loadTestStrs()
gunStrs = loadGunStrs();
ammoStrs = loadAmmoStrs();
xducerStrs = getChannelCodes();
xducerSets = loadXducerSets();
labjackStrs = loadLabjackStrs();

fid = fopen( fileName, 'w' );
if( fid == -1 )
  error( [ 'File open fail for: ', fileName ] )
end

mfid = fopen( metaName, 'w' );
if( mfid == -1 )
  error( [ 'File open fail for: ', metaName ] )
end

display( sprintf('Writing %d rows into: %s', numRows, fileName ) );

numLbls = numCols+5; 
colLbls = {'TestName','TestIdx','NumChannels','RangeFt','Gun','Ammo','XducerSetIdx','Ch1Xducer','Ch2Xducer','Ch3Xducer','Ch4Xducer','DateTime','LabjackID','SWVersion','BinFile','Ch1File','Ch2File','Ch3File','Ch4File'};
for lbl = 1 : numLbls-1
  fprintf( fid, '%s, ', colLbls{lbl} );
end
fprintf( fid, '%s\n', colLbls{numLbls} );

for r = 1 : numRows
  fprintf( fid, '%s, %d, %d, %f, %s, %s, %d, %s, %s, %s, %s, %s, %s, ', ...
  	            getTestStr(testStrs,m(r,1)), m(r,2), m(r,3), m(r,4), ...
  	            getGunStr(gunStrs,m(r,5)), getAmmoStr(ammoStrs, m(r,6)), ... 
  	            m(r,7), getXducerStr( xducerStrs, m(r,8) ), ...
  	            getXducerStr( xducerStrs, m(r,9) ), ...
  	            getXducerStr( xducerStrs, m(r,10) ), ...
  	            getXducerStr( xducerStrs, m(r,11) ), ...
  	            datestr(m(r,12),31), getLabjackStr( labjackStrs, m(r,13) ) );

  if m(r,14) == 1
    rawName = checkFile( makeRawName( m(r,:), testStrs, gunStrs, ammoStrs, xducerStrs ) );
  elseif m(r,14) == 2
    rawName = makeRawName2( m(r,:), testStrs, gunStrs, ammoStrs, xducerStrs, labjackStrs );
  else
  	error( 'Unknown SW version' );
  end
  ch1Name = checkFile( [ rawName, '-', getXducerStr( xducerStrs, m(r,8) ), '.wav' ] );
  ch2Name = checkFile( [ rawName, '-', getXducerStr( xducerStrs, m(r,9) ), '.wav' ] );
  ch3Name = checkFile( [ rawName, '-', getXducerStr( xducerStrs, m(r,10) ), '.wav' ] );
  ch4Name = checkFile( [ rawName, '-', getXducerStr( xducerStrs, m(r,11) ), '.wav' ] );
  fprintf( fid, '%d, %s, %s, %s, %s, %s\n', m(r,14), rawName, ch1Name, ch2Name, ch3Name, ch4Name );
end

fclose( fid );