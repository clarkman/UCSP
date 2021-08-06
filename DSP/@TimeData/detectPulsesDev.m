function  [ residual, meta ] = detectPulsesDev( seg, detector, meta, fid, filtr );
%
% Works with pulseWalker.m 
%
residual = -1;
tosssecs = 0;

%metaOut = meta;
segLenSecs = lengthSecs( seg );
if( segLenSecs <= detector.duration_min )
    return
end

display( [ 'Computing pulses for: ', seg.DataCommon.station, ' ', seg.DataCommon.channel, ' ', datenum2str(seg.DataCommon.UTCref) ] );

meta.ch_dur = meta.ch_dur + segLenSecs / 86400;

if( strcmp( seg.DataCommon.network, 'BK' ) )
    doBK = 1;
else
    doBK = 0;
end


channelDirName = seg.DataCommon.channel;
ch = channelDirName(end);
channel = sscanf(ch,'%d');

numSamps = length( seg );
if( strcmp( detector.type, 'abs' ) )
    Mean = ( detector.threshold_neg + detector.threshold_pos)/2;
elseif( strcmp( detector.type, 'thr' ) )
    Mean = channelMean( sscanf( seg.DataCommon.station, '%d' ), sscanf( ch, '%d' ),  seg.DataCommon.UTCref );
    seg = seg - Mean;
elseif( strcmp( detector.type, 'hp' ) || strcmp( detector.type, 'ltg' ) )
    seg = removeDC( seg );
    hp=highpass(double(seg),0.1,1373);
    tosssecs = 30;
    tosssamps = tosssecs*50;
    s = hp.samples;
    s = s(ceil(tosssecs*seg.sampleRate):end); %Throw away 30 secs for filter chargeup
    hp.DataCommon.UTCref = hp.DataCommon.UTCref + tosssecs/86400;
    hp.samples = s;
    seg = zeroCenter(hp);
    clear hp s;
    numSamps = length( seg );
    %seg
    Mean = 0;
    [thrLo, thrHi] = getPulseDetChanVals( detector, ch );
elseif( strcmp( detector.type, 'df' ) )
    tosssecs = 20;
    hp = seg;
    s=filter(filtr,double(hp));
    s = s(ceil(tosssecs*seg.sampleRate):end); %Throw away xx secs for filter chargeup
    hp.samples = s;
    hp.DataCommon.UTCref = hp.DataCommon.UTCref + tosssecs/86400;
    hp.samples = s;
    seg = hp;
    clear hp s;
    numSamps = length( seg );
    %seg
    Mean = 0;
    [thrLo, thrHi] = getPulseDetChanVals( detector, ch );
end
samps = seg.samples;


%  A re-roll of Matt's original.

xValues = zeros( 1, numSamps );
samplePeriod = (1.0/seg.sampleRate)/86400;
daBegTime = seg.DataCommon.UTCref;
for ith = 1 : numSamps 
    xValues(ith) = daBegTime + ith * samplePeriod;
end
xValues = xValues - 0.5 * samplePeriod;



%----------- First gather raw, all data ------------

% Test for Excursion Points
TopLine=( ones([numSamps,1]) * thrHi );
BottomLine=( ones([numSamps,1]) * thrLo );
TopEnd = gt( samps, TopLine ); % Boolean vector, if samp exceeds TopLine, else=0
BottomEnd = lt( samps, BottomLine );%Boolean vector,if Data Value exceeds NumSD=1, else=0
HighDiff=diff( TopEnd ); % =1 where exceeds, =-1 where returns, else=0
LowDiff=diff( BottomEnd ); % =1 where exceeds, =-1 where returns, else=0
% Now Count the High Excursions
HighExceeds=find(HighDiff==1);
HighReturns=find(HighDiff==-1);
% and the Low Excursions.
LowExceeds=find(LowDiff==1);
LowReturns=find(LowDiff==-1);



%----------- Trim beginning and end of listing ------------

% Now for the first hat trick.  Toss any excursion you're already in.
% If the last excursion runs to the end of this TimeData object, 
% (and meets time criteria) data placed into the residual TimeData 
% object and returned.  In this way, pulseWalker tries to sausage 
% together everything it can, and count each pulse once.

% First we count the high set of excursions.  Be thorough.
numExceeds = size(HighExceeds,1);
numReturns = size(HighReturns,1);
tailSecs = detector.duration_max*2+tosssecs;
if( abs( numExceeds - numReturns ) > 1 )
    error( '    - High Unaccountable situation!' );
elseif( numExceeds == 0 ) % None
    display( '    - High None situation!' );
    NumHighEx = 0;
elseif( numReturns == 0 )
    display( '    - High None, but leaves exceeded situation!' );
    NumHighEx = 0;
    residual = makeResidual( seg, HighExceeds(1), tailSecs );   
elseif( numExceeds == numReturns && HighReturns(1) < HighExceeds(1) && numExceeds ==1 )
    display( '    - High Enters exceeded, leaves exceeded situation!' );
    NumHighEx = 0;  % None here, but could be in next seg
    residual = makeResidual( seg, HighExceeds(1), tailSecs );
elseif( numExceeds == numReturns && HighReturns(1) > HighExceeds(1) )
    display( '    - High Normal situation!' );
    NumHighEx = numExceeds;
elseif( numExceeds == numReturns && HighReturns(1) < HighExceeds(1) )
    display( '    - High Trim head and tail situation!' );
    residual = makeResidual( seg, HighExceeds(end), tailSecs );
    HighExceeds = HighExceeds(1:end-1);
    HighReturns = HighReturns(2:end);
    NumHighEx = numExceeds - 1;
elseif( numReturns > numExceeds && HighReturns(1) < HighExceeds(1) )
    display( '    - High Trim Return from start situation!' );
    HighReturns = HighReturns(2:end);
    NumHighEx = numExceeds;
elseif( numReturns > numExceeds && HighReturns(1) >= HighExceeds(1) )
    error( '    - High Trim Return unknown situation!' );
elseif( numReturns < numExceeds && HighReturns(1) > HighExceeds(1) )
    display( '    - High Exceed at end trim situation!' );
    residual = makeResidual( seg, HighExceeds(end), tailSecs );
    HighExceeds = HighExceeds(1:end-1);
    NumHighEx = numReturns;
elseif( numReturns < numExceeds && HighReturns(1) <= HighExceeds(1) )
    error( '    - High Trim Return unknown situation!' );
else
    error( '    - High unknown situation!' );
end

% Sanity
for eth = 1 : NumHighEx
    if( HighReturns(eth) <= HighExceeds(eth) )
        error( 'Fump Duck Highs' );
    end
end


% Count the Low Excursions
LowExceeds=find(LowDiff==1);
LowReturns=find(LowDiff==-1);
numExceeds = size(LowExceeds,1);
numReturns = size(LowReturns,1);
if( abs( numExceeds - numReturns ) > 1 )
    error( '    - Low Unaccountable situation!' );
elseif( numExceeds == 0 ) % None at all, high or low
    if( ~NumHighEx ), return;, end;
    NumLowEx = 0;
elseif( numReturns == 0 )
    display( '    - Low None, but leaves exceeded situation!' );
    if( NumHighEx == 0 ||  LowExceeds(1) < HighExceeds(1) )
        residual = makeResidual( seg, LowExceeds(1), tailSecs );
    end
    NumLowEx = 0;
elseif( numExceeds == numReturns && LowReturns(1) < LowExceeds(1) && numExceeds ==1 )
    display( '    - Low Enters exceeded, leaves exceeded situation!' );
    %NumHighEx = 0;  % None here, but could be in next seg
    if( NumHighEx == 0 || LowExceeds(1) < HighExceeds(1) )
        residual = makeResidual( seg, LowExceeds(1), tailSecs );
    end
    NumLowEx = 0;
elseif( numExceeds == numReturns && LowReturns(1) > LowExceeds(1) )
    display( '    - Low Normal situation!' );
    NumLowEx = numExceeds;
elseif( numExceeds == numReturns && LowReturns(1) < LowExceeds(1) )
    display( '    - Low Trim head and tail situation!' );
    if( NumHighEx == 0 || LowExceeds(end) < HighExceeds(end) )
        residual = makeResidual( seg, LowExceeds(end), tailSecs );
    end
    LowExceeds = LowExceeds(1:end-1);
    LowReturns = LowReturns(2:end);
    NumLowEx = numExceeds - 1;
elseif( numReturns > numExceeds && LowReturns(1) < LowExceeds(1) )
    display( '    - Low Trim Return from start situation!' );
    LowReturns = LowReturns(2:end);
    NumLowEx = numExceeds;
elseif( numReturns > numExceeds && LowReturns(1) >= LowExceeds(1) )
    error( '    - Low Trim Return unknown situation!' );
elseif( numReturns < numExceeds && LowReturns(1) > LowExceeds(1) )
    display( '    - Low Exceed at end trim situation!' );
    if( NumHighEx == 0 || LowExceeds(end) < HighExceeds(end) )
        residual = makeResidual( seg, LowExceeds(end), tailSecs );
    end
    LowExceeds = LowExceeds(1:end-1);
    NumLowEx = numReturns;
elseif( numReturns < numExceeds && LowReturns(1) <= LowExceeds(1) )
    error( '    - Low Trim Return unknown situation!' );
else
    error( '    - Low unknown situation!' );
end

% Sanity
for eth = 1 : NumLowEx
    if( LowReturns(eth) <= LowExceeds(eth) )
        error( 'Fump Duck Lows' );
    end
end


%----------- Now we do validations ------------

% Time validation
numPassed = 0;
HiExcs=HighExceeds;
HiRets=HighReturns;
totalHiLength = 0;
for eth = 1 : NumHighEx
    pulseLength = ( HighReturns(eth) - HighExceeds(eth) ) / seg.sampleRate;
    if( pulseLength <= detector.duration_max && pulseLength >= detector.duration_min )
        numPassed = numPassed + 1;
        totalHiLength = totalHiLength + pulseLength;
        HiExcs(numPassed) = HighExceeds(eth);
        HiRets(numPassed) = HighReturns(eth);
    end
end
HighExceeds = HiExcs(1:numPassed);
HighReturns = HiRets(1:numPassed);
NumHighEx = numPassed;

numPassed = 0;
LoExcs=LowExceeds;
LoRets=LowReturns;
totalLoLength = 0;
for eth = 1 : NumLowEx
    pulseLength = ( LowReturns(eth) - LowExceeds(eth) ) / seg.sampleRate;
    if( pulseLength <= detector.duration_max && pulseLength >= detector.duration_min )
        numPassed = numPassed + 1;
        totalLoLength = totalLoLength + pulseLength;
        LoExcs(numPassed) = LowExceeds(eth);
        LoRets(numPassed) = LowReturns(eth);
    end
end
LowExceeds = LoExcs(1:numPassed);
LowReturns = LoRets(1:numPassed);
NumLowEx = numPassed;


if( length(HighExceeds) == 0 && length(HighReturns) == 0 && length(LowExceeds) == 0 && length(LowReturns) == 0 ) % None found
    display( 'No pulses found')
    return;
end

% Add metas
meta.pulse_count_lo = meta.pulse_count_lo + NumLowEx;
meta.pulse_count_hi = meta.pulse_count_hi + NumHighEx;
meta.pulse_dur_lo = meta.pulse_dur_lo + totalLoLength / 86400;
meta.pulse_dur_hi = meta.pulse_dur_hi + totalHiLength / 86400;

% Merge the two lists, perserving type

totalFound = NumLowEx + NumHighEx;
rows = zeros( totalFound, 11 );
rowCounter = 0;
for i = 1 : NumHighEx
    startIdx = HighExceeds(i);
    finishIdx = HighReturns(i);
    pulseLength = ( finishIdx - startIdx ) / seg.sampleRate; % Seconds
    thisPulse = samps(startIdx:finishIdx);
%      thisPulseStartT = seg.DataCommon.UTCref + ( startIdx - 0.5 ) * samplePeriod;
%      thisPulseFinishT = seg.DataCommon.UTCref + ( finishIdx + 0.5 ) * samplePeriod;
    thisPulseStartT = seg.DataCommon.UTCref + ( startIdx ) * samplePeriod;
    thisPulseFinishT = seg.DataCommon.UTCref + ( finishIdx ) * samplePeriod;
    [ peak, ith ] = max(thisPulse);
    numF = find( thisPulse == peak );
    countF = length( numF );
    if( countF > 1 )
      display( sprintf( 'Warning %d hi peaks found!!!', countF ) );
    end
    [ puke, eeth ] = min(thisPulse);
    numF = find( thisPulse == puke );
    countF = length( numF );
    if( countF > 1 )
      display( sprintf( 'Warning %d hi pukes found!!!', countF ) );
    end
    peakT = xValues( ith+startIdx );
    mag=sqrt(sum((thisPulse - Mean).^2));
    %fprintf( fid, '%s|%s|PULSE|UP|%s|%s|%6.4f|%d|%s|%d\n', datenum2str(thisPulseStartT,'sql'), datenum2str(thisPulseFinishT,'sql'), seg.DataCommon.station, seg.DataCommon.channel, pulseLength, peak, datenum2str(peakT,'sql'), mag );
    if( doBK )
        st = 1;
    else
        st = sscanf(seg.DataCommon.station,'%f');
    end
    rowCounter = rowCounter + 1;
    rows( rowCounter, : ) = [ thisPulseStartT, pulseLength, st, sscanf(ch,'%f'), 1.0, double(peak), double(puke), 0.0, 0.0, peakT, mag ];
    %nextRow = [ thisPulseStartT, thisPulseFinishT, 1.0, st, sscanf(ch,'%f'), pulseLength, double(peak), peakT, mag ];
    %display( nextRow )
    %fwrite(fid, nextRow, 'double');
end

for i = 1 : NumLowEx
    startIdx = LowExceeds(i);
    finishIdx = LowReturns(i);
    pulseLength = ( finishIdx - startIdx ) / seg.sampleRate; % Seconds
    thisPulse = samps(startIdx:finishIdx);
%      thisPulseStartT = seg.DataCommon.UTCref + ( startIdx - 0.5 ) * samplePeriod;
%      thisPulseFinishT = seg.DataCommon.UTCref + ( finishIdx + 0.5 ) * samplePeriod;
    thisPulseStartT = seg.DataCommon.UTCref + ( startIdx ) * samplePeriod;
    thisPulseFinishT = seg.DataCommon.UTCref + ( finishIdx ) * samplePeriod;
    [ peak, ith ] = min(thisPulse);
    numF = find( thisPulse == peak );
    countF = length( numF );
    if( countF > 1 )
      display( sprintf( 'Warning %d lo peaks found!!!', countF ) );
    end
    [ puke, eeth ] = min(thisPulse);
    numF = find( thisPulse == puke );
    countF = length( numF );
    if( countF > 1 )
      display( sprintf( 'Warning %d lo pukes found!!!', countF ) );
    end
    peakT = xValues( ith+startIdx );
    mag=sqrt(sum((thisPulse - Mean).^2));
    %fprintf( fid, '%s|%s|PULSE|DN|%s|%s|%6.4f|%d|%s|%d\n', datenum2str(thisPulseStartT,'sql'), datenum2str(thisPulseFinishT,'sql'), seg.DataCommon.station, ch, pulseLength, peak, datenum2str(peakT,'sql'), mag );	
    if( doBK )
        st = 1;
    else
        st = sscanf(seg.DataCommon.station,'%f');
    end
    rowCounter = rowCounter + 1;
    rows( rowCounter, : ) = [ thisPulseStartT, pulseLength, st, sscanf(ch,'%f'), -1.0, double(puke), double(peak), 0.0, 0.0, peakT, mag ];
    %nextRow = [ thisPulseStartT, thisPulseFinishT, -1.0, st, sscanf(ch,'%f'), pulseLength, double(peak), peakT, mag, count ];
    %display( nextRow )
    %fwrite(fid, nextRow, 'double');
end


%for p = 1 : totalFound
%    fwrite(fid, rows(p,:), 'double');
%end
%return


% Now sort by start time and toss chains
rows = sortrows( rows, 1 );
pulses = rows;
numPulses = 0;
detectorDayDur = detector.duration_max / 86400;
cap = 10000;
if( totalFound > cap )
  warning( sprintf( 'Total # found (%d) exceeds the cap of %d!! for site=%s, chan=%s', totalFound, cap, seg.DataCommon.station, seg.DataCommon.channel ) )
end
display( [ 'Candidates found = ', sprintf( '%d', totalFound ) ] );

epsilon = 0.02/86400;
if 1 % intense checks
  sz = size(rows);
  numPTotal = sz(1);
  for p = 1 : numPTotal-1
    if( pulses(p,1) >= pulses(p+1,1) )
      warning( 'Pulse mis-sequence found!!' );
    end
    if( pulses(p,1)+pulses(p,2)/86400 > pulses(p+1,1)+epsilon )
      display( sprintf( '#%d, pEnd = %s, pNext = %s', p, datenum2str(pulses(p,1)+pulses(p,2)/86400), datenum2str(pulses(p+1,1)) ) )
      display( sprintf( '#%d, pEnd = %6.9f, pNext = %6.9f', p, pulses(p,1)+pulses(p,2)/86400.0, pulses(p+1,1) ) )
      warning( 'Pulse overlap found!!' );
    end
  end
  for p = 1 : sz(1)
    if( pulses(p,10) < pulses(p,1)-epsilon )
      warning( sprintf( 'Pulse %d peak time early at %d: ! %s < %s !!', pulses(p,5), p, datenum2str(pulses(p,10)), datenum2str(pulses(p,1)-epsilon) ) );
    end
    if( pulses(p,10) > pulses(p,1)+(pulses(p,2)/86400)+epsilon )
      warning( sprintf( 'Pulse %d peak time tardy at %d: ! %s < %s!!', pulses(p,5), p, datenum2str(pulses(p,10)), datenum2str(pulses(p,1)+pulses(p,2)/86400+epsilon) ) );
    end
  end
end

if 1

  % New pulse train eliminator
  p = 1;
  while 1
      numInWind = 0;
      while( p+numInWind+1 <= numPTotal && rows(p+numInWind+1,1) - ( rows(p+numInWind,1) + rows(p+numInWind,2) / 86400 ) <= detectorDayDur )
	  numInWind = numInWind + 1;
      end
      
      if( numInWind > 0 )
	  if( p+numInWind > totalFound )
	      break;
	  else
              pulseSet = rows( p:p+numInWind, : );
	      numPulses = numPulses + 1;
	      pulses( numPulses, : ) = rows( p, : );
	      sz = size( pulseSet );
	      for pp = 1 : sz(1)
		if( pulseSet( pp, 5 ) > 0 )
		  pulses( numPulses, 8 ) = pulses( numPulses, 8 ) + 1;
		else
		  pulses( numPulses, 9 ) = pulses( numPulses, 9 ) + 1;
		end
	      end
	      %nextRow = [ thisPulseStartT, pulseLength, st, sscanf(ch,'%f'), -1.0, double(puke), double(peak), numPos, numNeg, peakT, mag ];
	      pulses( numPulses, 2 ) = (pulseSet(end,1)-pulseSet(1,1)) * 86400 + pulseSet(end,2);
	      [minn, idx] = min( pulseSet(:,6) );
	      pulses( numPulses, 6 ) = minn;
	      [maxx, idx] = max( pulseSet(:,7) );
	      pulses( numPulses, 7 ) = maxx;
	      pulses( numPulses, 10 ) = pulseSet( idx, 10 );
	      pulses( numPulses, 11 ) = sum( pulseSet(:,11) );
	      %display( [ 'Made: ' sprintf( '%d', numPulses ) ] )
	      p = p + numInWind + 1;
	  end
      else % One only
	  if( p+numInWind > totalFound )
	      break;
	  else
	      numPulses = numPulses + 1;
	      pulses( numPulses, : ) = rows( p, : );
              if( pulses( numPulses, 5 ) > 0 )
                pulses( numPulses, 8 ) = pulses( numPulses, 8 ) + 1;
              else
                pulses( numPulses, 9 ) = pulses( numPulses, 9 ) + 1;
              end
              p = p + 1;
	  end
      end
  end
  % Trim
  pulses = pulses( 1:numPulses, : );
else
  sz = size(pulses);
  numPulses = sz(1);
end
display( sprintf( '%d candidates was reduced to %d pulse trains.', numPTotal, numPulses ) );


% Trim anything during filter startup
if( strcmp( detector.type, 'hp' ) )
  filterChargedT = daBegTime + tosssecs/86400;
  numPulsesToToss = 0;
  while( numPulsesToToss < numPulses && pulses( numPulsesToToss+1, 1 ) < filterChargedT )
    numPulsesToToss = numPulsesToToss + 1;     
  end
  if( numPulsesToToss )
      pulses = pulses( numPulsesToToss:end, : );
      numPulses = numPulses - numPulsesToToss;
  end
end


% Re-check durations
pulsesOut = pulses;
numQuald = 0;
for pth = 1 : numPulses
    if( ( pulses(pth,2)/86400 ) <= detectorDayDur )
        numQuald = numQuald + 1;
        pulsesOut( numQuald, : ) = pulses( pth, : );
    else
        display( [ 'Punted for too lengthy duration = ', sprintf( '%d', pth ) ] );
    end
end
display( sprintf( 'Number of qualified pulses = %d', numQuald ) );
pulsesOut = pulsesOut( 1:numQuald, : );


% Mask out lightning
if( strcmp( detector.type, 'ltg' ) )
  pad = [ .2, 1 ] ./ 86400;
  [staNum, sid] = makeSid( seg.DataCommon.station );
  [ begMonStr, begMon ] = makeMoniker( datenum2moniker(daBegTime) ); 
  ltgMask = makeLightningMask( sid, begMon );
  sz = size( ltgMask );
  numBolts = sz(1);
  boltTimes = zeros( numBolts, 2 );
  boltTimes(:,1) = ltgMask(:,1) - pad(1);
  boltTimes(:,2) = ltgMask(:,1) + pad(2);
  numNotMasked = 0;
  pTmp = pulsesOut;

  display( sprintf( 'Pulses cover from %s -to- %s', datestr(min(pulsesOut(:,1))), datestr(max(pulsesOut(:,1))) ) )
  display( sprintf( 'Lightning bolts cover from %s -to- %s', datestr(min(ltgMask(:,1))), datestr(max(ltgMask(:,1))) ) )

if 1
  for p = 1 : numQuald

    pBegTime = pulsesOut(p,1);
    pFinTime = pBegTime + pulsesOut(p,2)/86400;

    %display( sprintf( 'Pulse %d length = %f secs', p, (pFinTime-pBegTime)*86400 ) )
    
    % fndIn = find( ( boltTimes(:,1) <= pBegTime & boltTimes(:,2) >= pBegTime ) | ( boltTimes(:,1) <= pFinTime & boltTimes(:,2) >= pFinTime ) | ( boltTimes(:,1) <= pBegTime & boltTimes(:,2) >= pFinTime ) )
    % if( isempty(fndIn))
    %   numNotMasked = numNotMasked + 1;
    %   pTmp(numNotMasked,:) = pulsesOut(p,:);
    % end

    fndIn = find( boltTimes(:,1) <= pBegTime & boltTimes(:,2) >= pBegTime );
    if( ~isempty(fndIn) )
      display( sprintf( 'Found pulse %d start in %d bolts', p, length(fndIn) ) )
      continue
    end

    fndIn = find( boltTimes(:,1) <= pFinTime & boltTimes(:,2) >= pFinTime );
    if( ~isempty(fndIn) )
      display( sprintf( 'Found pulse %d end in %d bolts', p, length(fndIn) ) )
      continue
    end

    fndIn = find( boltTimes(:,1) <= pBegTime & boltTimes(:,2) >= pFinTime );
    if( ~isempty(fndIn) )
      display( sprintf( 'Found pulse %d inside %d bolts', p, length(fndIn) ) )
      continue
    end

    numNotMasked = numNotMasked + 1;
    pTmp(numNotMasked,:) = pulsesOut(p,:);

  end
else
  for p = 1 : numQuald

    pBegTime = pulsesOut(p,1);
    pFinTime = pBegTime + pulsesOut(p,2)/86400;
       
    pMasked = 0;
    for b = 1 : numBolts

      % Completely spread out cases (optimize later)
      if( boltTimes(b,1) < pBegTime && boltTimes(b,2) >= pBegTime && boltTimes(b,2) <= pFinTime ) % case 1
        %display( 'Case 1' )
        pMasked = 1;
        continue;
      elseif( boltTimes(b,1) >= pBegTime && boltTimes(b,2) <= pFinTime ) % case 2
        %display( 'Case 2' )
        pMasked = 1;
        continue;
      elseif( boltTimes(b,1) >= pBegTime && boltTimes(b,1) <= pFinTime && boltTimes(b,2) >= pFinTime ) % case 3
        %display( 'Case 3' )
        pMasked = 1;
        continue;
      elseif( boltTimes(b,1) <= pBegTime && boltTimes(b,2) >= pFinTime ) % case 4
        %display( sprintf( 'Case 4: %f <= %f && %f >= %f', boltTimes(b,1), pBegTime, boltTimes(b,2), pFinTime ) )
        pMasked = 1;
        continue;
      end

    end

    if( pMasked == 0 )
      numNotMasked = numNotMasked + 1;
      pTmp(numNotMasked,:) = pulsesOut(p,:);
    end

  end
end

  display( sprintf( 'Number of pulses not masked out for lightning = %d', numNotMasked ) )
  pulsesOut = pTmp(1:numNotMasked,:);
  numQuald = numNotMasked;

end


% Now write
for p = 1 : numQuald
  fwrite(fid, pulsesOut(p,:), 'double');
end

display( sprintf( 'Num Pulses found = %d', numQuald ) );
if( isa( residual, 'TimeData' ) )
  display( sprintf( 'Residual sample pad = %d', length(residual) ) );
end
return;




