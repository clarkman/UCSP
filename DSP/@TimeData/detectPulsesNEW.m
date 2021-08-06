function  [ residual, meta, numQuald ] = detectPulses( seg, detector, meta, fid, filtr, outages );
%
% Works with pulseWalker.m 
%
%  $Id: detectPulsesNEW.m,v ee5036e83f4e 2015/04/02 19:18:28 cdunson $

residual = -1;

segLenSecs = lengthSecs( seg );
if( segLenSecs <= ( detector.duration_min - 1 ) / seg.sampleRate )
    return
end

begT=datenum2str(seg.DataCommon.UTCref);
finT=datenum2str(seg.DataCommon.UTCref+segLenSecs/86400);
display( [ 'Computing pulses for: ', seg.DataCommon.station, ' ', seg.DataCommon.channel, ' from: ', begT, ' -to- ', finT ] );

[staNum, sid] = makeSid(seg.DataCommon.station);
channelDirName = seg.DataCommon.channel;
[ch, channel] = makeCh(channelDirName(end));
dnStr = datenum2str(seg.DataCommon.UTCref);


% Prepare signals
fftL=4096;
tosssecs=124/2;


% But first keep residual in case needed.
numSamps = length(seg);
residualSegTail = slice( seg, numSamps-2.0*detector.duration_max, numSamps );

numSamps = length( seg );
if( strcmp( detector.type, 'abs' ) )
    Mean = ( detector.threshold_neg + detector.threshold_pos)/2;
elseif( strcmp( detector.type, 'thr' ) )
    Mean = channelMean( sscanf( seg.DataCommon.station, '%d' ), sscanf( ch, '%d' ),  seg.DataCommon.UTCref );
    seg = seg - Mean;
elseif( strcmp( detector.type, 'hp' ) )
    display( [ 'Applying highpass filter for: ', staNum, ', ', ch, ', ', dnStr ] );
    seg = zeroCenter(seg);
    origNumSamps = length(seg);
    keep = seg;
    s = seg.samples;
    hpSamps=filter(filtr,double(s));
    hpSamps = hpSamps(ceil(tosssecs*seg.sampleRate):end); % Throw away end for filter chargeup
    seg.samples = hpSamps;
    seg
    %seg.DataCommon.UTCref = seg.DataCommon.UTCref + tosssecs/86400;
    clear hpSamps s;
    numSamps = length( seg );
    Mean = 0;
elseif( strcmp( detector.type, 'df' ) )
    display( [ 'Applying differencing filter for: ', staNum, ', ', ch, ', ', dnStr ] );
    seg = zeroCenter(seg);
    origNumSamps = length(seg);
    s = seg.samples;
    lpSamps = filter(filtr,double(s));
    lpSamps = lpSamps(ceil(tosssecs*seg.sampleRate):end); % Throw away xx secs for filter chargeup
    lp = seg;
    lp.samples = lpSamps;
   % lp.DataCommon.UTCref = lp.DataCommon.UTCref + tosssecs/86400;
    s = seg.samples;
    seg.samples = s(1:end-ceil(tosssecs*seg.sampleRate)+1);
    %figure; plot2(seg,lp,seg-lp); legend({'orig','lowp','subtr'})
    keep = seg;
    seg = seg-lp;
    clear lp lpSamps s;
    numSamps = length( seg );
    Mean = 0;
end
%return
[thrLo, thrHi] = getPulseDetChanVals( detector, ch );


samps = seg.samples;
samplePeriod = (1.0/seg.sampleRate)/86400;
detMax = ( detector.duration_max - 1 ) / seg.sampleRate;

%  A re-roll of Matt's original.


%----------- First gather ye all data ------------

% Test for Excursion Points
display( [ 'Gathering all excursions for: ', staNum, ', ', ch, ', ', dnStr ] );
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

numQuald = 0;

%----------- Trim beginning and end of listing ------------

% Now for the first hat trick.  Toss any excursion you're already in.
% If the last excursion runs to the end of this TimeData object, 
% (and meets time criteria) data placed into the residual TimeData 
% object and returned.  In this way, pulseWalker tries to sausage 
% together everything it can, and count each pulse once.

% First we count the high set of excursions.  Be thorough.
numExceeds = size(HighExceeds,1);
numReturns = size(HighReturns,1);

if( abs( numExceeds - numReturns ) > 1 )
    error( '    - High Unaccountable situation!' );  % Hopefully, an impossibility
elseif( numExceeds == 0 ) % None
    display( '    - High None situation!' );
    NumHighEx = 0;
elseif( numReturns == 0 )
    display( '    - High None, but leaves exceeded situation!' );
    NumHighEx = 0;
    residual = makeResidual( residualSegTail, HighExceeds(1), detMax );   
elseif( numExceeds == numReturns && HighReturns(1) < HighExceeds(1) && numExceeds ==1 )
    display( '    - High Enters exceeded, leaves exceeded situation!' );
    NumHighEx = 0;  % None here, but could be in next seg
    residual = makeResidual( residualSegTail, HighExceeds(1), detMax );
elseif( numExceeds == numReturns && HighReturns(1) > HighExceeds(1) )
    display( '    - High Normal situation!' );
    NumHighEx = numExceeds;
elseif( numExceeds == numReturns && HighReturns(1) < HighExceeds(1) )
    display( '    - High Trim head and tail situation!' );
    residual = makeResidual( residualSegTail, HighExceeds(end), detMax );
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
    display( sprintf( '    - High Exceed at end trim situation = %d!', HighExceeds(end) ) );
    residual = makeResidual( residualSegTail, HighExceeds(end), detMax );
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
    display( '    - Low None situation!' );
    NumLowEx = 0;
elseif( numReturns == 0 )
    display( '    - Low None, but leaves exceeded situation!' );
    if( NumHighEx == 0 ||  LowExceeds(1) < HighExceeds(1) )
        residual = makeResidual( residualSegTail, LowExceeds(1), detMax );
    end
    NumLowEx = 0;
elseif( numExceeds == numReturns && LowReturns(1) < LowExceeds(1) && numExceeds ==1 )
    display( '    - Low Enters exceeded, leaves exceeded situation!' );
    %NumHighEx = 0;  % None here, but could be in next seg
    if( NumHighEx == 0 || LowExceeds(1) < HighExceeds(1) )
        residual = makeResidual( residualSegTail, LowExceeds(1), detMax );
    end
    NumLowEx = 0;
elseif( numExceeds == numReturns && LowReturns(1) > LowExceeds(1) )
    display( '    - Low Normal situation!' );
    NumLowEx = numExceeds;
elseif( numExceeds == numReturns && LowReturns(1) < LowExceeds(1) )
    display( '    - Low Trim head and tail situation!' );
    if( NumHighEx == 0 || LowExceeds(end) < HighExceeds(end) )
        residual = makeResidual( residualSegTail, LowExceeds(end), detMax );
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
    display( sprintf( '    - Low Exceed at end trim situation = %d!', LowExceeds(end) ) );
    if( NumHighEx == 0 || LowExceeds(end) < HighExceeds(end) )
        residual = makeResidual( residualSegTail, LowExceeds(end), detMax );
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

%if( length(HighExceeds) == 0 && length(HighReturns) == 0 && length(LowExceeds) == 0 && length(LowReturns) == 0 ) % None found
if( NumHighEx == 0 && NumLowEx == 0 ) % None found
    display( 'No pulses found, moving on.' );
    residual = residualSegTail;
    return;
end



%----------- Now we do validations ------------

% Time ... 
numPassed = 0;
numTossed = 0;
HiExcs=HighExceeds;
HiRets=HighReturns;
totalHiLength = 0;
for eth = 1 : NumHighEx
    pulseLength = ( HighReturns(eth) - HighExceeds(eth) );
    %pulseLength = ( HighReturns(eth) - HighExceeds(eth) - 1 ) / seg.sampleRate
    if( pulseLength <= detector.duration_max && pulseLength >= detector.duration_min )
        numPassed = numPassed + 1;
        totalHiLength = totalHiLength + pulseLength;
        HiExcs(numPassed) = HighExceeds(eth);
        HiRets(numPassed) = HighReturns(eth);
    else
        numTossed = numTossed + 1;
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
    pulseLength = ( LowReturns(eth) - LowExceeds(eth) );
    %pulseLength = ( LowReturns(eth) - LowExceeds(eth) - 1 ) / seg.sampleRate
    if( pulseLength <= detector.duration_max && pulseLength >= detector.duration_min )
        numPassed = numPassed + 1;
        totalLoLength = totalLoLength + pulseLength;
        LoExcs(numPassed) = LowExceeds(eth);
        LoRets(numPassed) = LowReturns(eth);
    else
        numTossed = numTossed + 1;
    end
end
LowExceeds = LoExcs(1:numPassed);
LowReturns = LoRets(1:numPassed);
NumLowEx = numPassed;
    
% Add metas
meta(1,6) = NumLowEx;
meta(1,7) = NumHighEx;

% Merge the two lists, perserving type
detName = detector.name;
detId = sscanf(detName(3:end),'%d');
totalFound = NumLowEx + NumHighEx;
rows = zeros( totalFound, 14 );
rowCounter = 0;
for i = 1 : NumHighEx
    startIdx = HighExceeds(i)+1;
    finishIdx = HighReturns(i);
    pulseLength = ( finishIdx - startIdx ) / seg.sampleRate; % Seconds
    thisPulse = samps(startIdx:finishIdx);
    thisPulseStartT = seg.DataCommon.UTCref + ( startIdx - 0.5 ) * samplePeriod;
    [ peak, ith ] = max(thisPulse);
    [ puke, eeth ] = min(thisPulse);
    peakT = thisPulseStartT + (ith-1) * samplePeriod;
    %peakT = xValues( startIdx+ith-1 );
    mag=sqrt(sum((thisPulse - Mean).^2));
    sz = size(thisPulse);
    pLen = sz(1);
    sumMag = 0;
    for pt = 1 : pLen -1
        sumMag = sumMag + trapArea( thisPulse(pt), thisPulse(pt+1), seg.sampleRate );
    end
    rowCounter = rowCounter + 1;
    rows( rowCounter, : ) = [ thisPulseStartT, pulseLength, sid, channel, detId, pLen, double(peak), double(puke), ith-1, peakT, sumMag, mag, numSamps, now ];
end

for i = 1 : NumLowEx
    startIdx = LowExceeds(i)+1;
    finishIdx = LowReturns(i);
    pulseLength = ( finishIdx - startIdx ) / seg.sampleRate; % Seconds
    thisPulse = samps(startIdx:finishIdx);
    thisPulseStartT = seg.DataCommon.UTCref + ( startIdx - 0.5 ) * samplePeriod;
    [ peak, ith ] = min(thisPulse);
    [ puke, eeth ] = max(thisPulse);
    peakT = thisPulseStartT + (ith-1) * samplePeriod;
    %peakT = xValues( startIdx+ith-1 );
    mag=sqrt(sum((thisPulse - Mean).^2));
    sz = size(thisPulse);
    pLen = sz(1);
    sumMag = 0;
    for pt = 1 : pLen -1
        sumMag = sumMag + trapArea( thisPulse(pt), thisPulse(pt+1), seg.sampleRate );
    end
    rowCounter = rowCounter + 1;
    rows( rowCounter, : ) = [ thisPulseStartT, pulseLength, sid, channel, -1.0*detId, pLen, double(peak), double(puke), ith-1, peakT, sumMag, mag, numSamps, now ];
end

% Now sort
rows = sortrows( rows, 1 );

% Compute meta
negPInds = find( rows(:,5) < 0 );
posPInds = find( rows(:,5) > 0 );
if( ~isempty(negPInds) )
  negPs = extractRows( rows, negPInds );
  meta(1,8) = sum( negPs(:,2) ) / NumLowEx;
  meta(1,10) = sum( negPs(:,11) ) / NumLowEx;
  meta(1,12) = sum( negPs(:,12) ) / NumLowEx;
  meta(1,14) = sum( negPs(:,7) ) / NumLowEx;
  meta(1,16) = numel( find( negPs(:,2) >= 1.0 ) );
  meta(1,18) = sum( (negPs(:,10) - negPs(:,1))*86400 ) / NumLowEx;
end
if( ~isempty(posPInds) )
  posPs = extractRows( rows, posPInds );
  meta(1,9) = sum( posPs(:,2) ) / NumHighEx;
  meta(1,11) = sum( posPs(:,11) ) / NumHighEx;
  meta(1,13) = sum( posPs(:,12) ) / NumHighEx;
  meta(1,15) = sum( posPs(:,7) ) / NumHighEx;
  meta(1,17) = numel( find( posPs(:,2) >= 1.0 ) );
  meta(1,19) = sum( (posPs(:,10) - posPs(:,1))*86400 ) / NumHighEx;
end

% Do outages
if ~isempty( outages )
  sz = size(outages);
  numOutages = sz(1);
  display( [ 'Applying ', sprintf( '%d', numOutages ), ' outages for site: ', staNum, ' chan: ', ch, ' for detector: ', detName ] );
  rowObj = PulseData( detector.name, sid, channel, rows );
  rowObj = filterOutages( rowObj, outages, 1 );
  rows = getPulses( rowObj );
  sz = size(rows);
  display( [ 'Pulses found after outages applied = ', sprintf( '%d/%d', sz(1), totalFound ), ' for: ', detName ] );
  totalFound = sz(1);
else
  display( [ 'Pulses found, no outages applied = ', sprintf( '%d', totalFound ), ' for: ', detName ] );
end

% Write 'em all ...
for p = 1 : totalFound
fwrite(fid, rows(p,:), 'double');
end
numQuald = totalFound;


draw = 0;
if draw
  dUTC=1;
  sz=size(rows);
  figure; hist(rows(:,2));
  title( sprintf( 'Histogram of %d pulse durations', sz(1) ) )
  figure; plot(spectrum(keep,fftL)); set(gca,'XScale','log'); set(gca,'YScale','log'); 
  hold on; plot(spectrum(seg,fftL),'Color',[0 0.6 0]);
    legend( {'orig', 'filtered'} )
  hold off;
  figure
  if dUTC
    plot2(keep,seg); legend( {'orig', 'filtered'} )
  else
    plot(seg);
  end
return
  for p = 1 : sz(1)
    dc = seg.DataCommon;
    if dUTC
      s=rows(p,1);
      pT=rows(p,10);
      f=s+rows(p,2)/86400;
    else
      s=(rows(p,1)-dc.UTCref)*86400;
      pT=(rows(p,10)-dc.UTCref)*86400;
      f=s+rows(p,2);
    end
    %f=s+rows(p,2)/86400;
    line([pT,pT],get(gca,'YLim'),'Color',[0 0 0 ]);
    line([s,s],get(gca,'YLim'),'Color',[0.618 0 0 ]);
    line([f,f],get(gca,'YLim'),'Color',[0 0.618 0 ]);
    line([s,f],[rows(p,7),rows(p,7)],'Color',[0.618 0.618 0 ])
    %text((f+s)/2,rows(p,7)/2,sprintf('peak=%f\nsumMag=%f\nmag=%f\npLen=%d',rows(p,7),rows(p,11),rows(p,12),rows(p,6)))
  end
  s=(min(rows(:,1))-dc.UTCref)*86400;
  f=(max(rows(:,1))-dc.UTCref)*86400+rows(p,2);
  lineHiStyle = '--';
  lineLoStyle = '--';
  line(get(gca,'XLim'),[thrLo, thrLo],'LineStyle',lineLoStyle,'Color',[0.2,0.2,0.2]);
  line(get(gca,'XLim'),[thrHi, thrHi],'LineStyle',lineHiStyle,'Color',[0.2,0.2,0.2]);
 % set(gca,'XLim',[s-10,f+10])
if 0
  btn = 1;
  while btn == 1
    [xi,yi,btn] = ginput(1)
    if( btn == 3 )
  %    close('all')
      break
    end
  end
end
end

%}



