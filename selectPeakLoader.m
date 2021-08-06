function [ loader, chan, exps, dBCorr ] = selectPeakLoader( exps, chKey, ch, loadExpsName )

[ chMoniker, chName ] = findChKey(chKey,ch);

dBCorr = 0.0;

chan = 0;
switch chMoniker
  case 'mic' % All microphone signals
    loader = '[ aPeaks, units ] = getAudioPeaks( arr, sens );';
  case 'piezo'
    loader = '[ aPeaks, units ] = getPiezoPeaks( arr, sens );';
  case 'accelX'
    chan = 1;
    accInds = find( exps(:,13) > 107 & exps(:,4) > 205 & exps(:,4) < 9000 );
    exps = extractRows( exps, accInds )
    loader = '[ aPeaks, units ] = getAccelPeaks( arr, sens, chan );';
  case 'accelY'
    chan = 2;
    accInds = find( exps(:,13) > 107 & exps(:,4) > 205 & exps(:,4) < 9000 );
    exps = extractRows( exps, accInds )
    loader = '[ aPeaks, units ] = getAccelPeaks( arr, sens, chan );';
  case 'accelZ'
    chan = 3;
    accInds = find( exps(:,13) > 107 & exps(:,4) > 205 & exps(:,4) < 9000 );
    exps = extractRows( exps, accInds )
    loader = '[ aPeaks, units ] = getAccelPeaks( arr, sens, chan );';
  case 'rev4IR'
    r4Inds = find( exps(:,4) == 205 ); 
    exps = extractRows( exps, r4Inds ); 
    loader = '[ aPeaks, units ] = getIRPeaks( arr, sens );';
  case 'swIR'
    error([ chName ' not tied in yet!'])
  case 'mwIR'
    error([ chName ' not tied in yet!'])
  case 'Casella'
    loader = '[ aPeaks, units ] = arr(:,11);';
  case 'rev4Mic'
    r4Inds = find( exps(:,4) == 205 ); 
    exps = extractRows( exps, r4Inds );
    dBCorr = -38;
    loader = '[ aPeaks, units ] = getAudioPeaks( arr, sens, dBCorr );';
  case 'revAMic'
    rAInds = find( exps(:,4) > 500 & exps(:,4) < 9000 ); 
    exps = extractRows( exps, rAInds ); 
    dBCorr = -46;
    loader = '[ aPeaks, units ] = getAudioPeaks( arr, sens, dBCorr );';
  case 'knowles'
    kInds = find( exps(:,4) > 9000 ); 
    exps = extractRows( exps, kInds );
    dBCorr = -58.58;
    loader = '[ aPeaks, units ] = getAudioPeaks( arr, sens, dBCorr );';
  case 'accelXNoFloat'
    chan = 1;
    accInds = find( exps(:,13) > 107 & exps(:,4) > 205 & exps(:,4) ~= 1024 & exps(:,4) < 9000 );
    exps = extractRows( exps, accInds )
    loader = '[ aPeaks, units ] = getAccelPeaks( arr, sens, chan );';
  case 'accelYNoFloat'
    chan = 2;
    accInds = find( exps(:,13) > 107 & exps(:,4) > 205 & exps(:,4) ~= 1024 & exps(:,4) < 9000 );
    exps = extractRows( exps, accInds )
    loader = '[ aPeaks, units ] = getAccelPeaks( arr, sens, chan );';
  case 'accelZNoFloat'
    chan = 3;
    accInds = find( exps(:,13) > 107 & exps(:,4) > 205 & exps(:,4) ~= 1024 & exps(:,4) < 9000 );
    exps = extractRows( exps, accInds )
    loader = '[ aPeaks, units ] = getAccelPeaks( arr, sens, chan );';
  otherwise
  	error('Made a boo boo!')
end

