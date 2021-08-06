function  [ residual, meta, numQuald ] = detectPulses( seg, detector, meta, fid, filtr );
%
% Works with pulseWalker.m 
%
%  $Id: detectPulses.m,v ee5036e83f4e 2015/04/02 19:18:28 cdunson $



residual = -1;
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
[staNum, sid] = makeSid(seg.DataCommon.station);
channelDirName = seg.DataCommon.channel;
[ch, channel] = makeCh(channelDirName(end));
dnStr = datenum2str(seg.DataCommon.UTCref);


% Prepare signals

numSamps = length( seg );
if( strcmp( detector.type, 'abs' ) )
    Mean = ( detector.threshold_neg + detector.threshold_pos)/2;
elseif( strcmp( detector.type, 'thr' ) )
    Mean = channelMean( sscanf( seg.DataCommon.station, '%d' ), sscanf( ch, '%d' ),  seg.DataCommon.UTCref );
    seg = seg - Mean;
elseif( strcmp( detector.type, 'hp' ) )
    display( [ 'Applying highpass filter for: ', staNum, ', ', ch, ', ', dnStr ] );
    if 0
        hp=highpass(double(seg),1,685);
        tosssecs = 15;
    else
        hp=highpass(double(seg),0.1,1373);
        tosssecs = 30;
    end
    s = hp.samples;
    s = s(ceil(tosssecs*seg.sampleRate):end); %Throw away 30 secs for filter chargeup
    hp.DataCommon.UTCref = hp.DataCommon.UTCref + tosssecs/86400;
    hp.samples = s;
    seg = hp;
    clear hp s;
    numSamps = length( seg );
    %seg
    Mean = 0;
    switch channel
      case 1
        thrHi = detector.ch1_Pos;
        thrLo = detector.ch1_Neg;
      case 2
        thrHi = detector.ch2_Pos;
        thrLo = detector.ch2_Neg;
      case 3
        thrHi = detector.ch3_Pos;
        thrLo = detector.ch3_Neg;
      otherwise
        error( [ 'Crazy channel: ', ch ]);
    end
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
    switch channel
      case 1
        thrHi = detector.ch1_Pos;
        thrLo = detector.ch1_Neg;
      case 2
        thrHi = detector.ch2_Pos;
        thrLo = detector.ch2_Neg;
      case 3
        thrHi = detector.ch3_Pos;
        thrLo = detector.ch3_Neg;
      otherwise
        error( [ 'Crazy channel: ', ch ]);
    end
end
samps = seg.samples;


%  A re-roll of Matt's original.

%----------- Compute time centers of samples ------------

xValues = zeros( 1, numSamps );
samplePeriod = (1.0/seg.sampleRate)/86400;
daBegTime = seg.DataCommon.UTCref;
for ith = 1 : numSamps 
    xValues(ith) = daBegTime + ith * samplePeriod;
end
xValues = xValues - 0.5 * samplePeriod;



%----------- First gather raw, all data ------------

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
    error( '    - High Unaccountable situation!' );
elseif( numExceeds == 0 ) % None
    display( '    - High None situation!' );
    NumHighEx = 0;
elseif( numReturns == 0 )
    display( '    - High None, but leaves exceeded situation!' );
    NumHighEx = 0;
    residual = makeResidual( seg, HighExceeds(1), detector.duration_max );   
elseif( numExceeds == numReturns && HighReturns(1) < HighExceeds(1) && numExceeds ==1 )
    display( '    - High Enters exceeded, leaves exceeded situation!' );
    NumHighEx = 0;  % None here, but could be in next seg
    residual = makeResidual( seg, HighExceeds(1), detector.duration_max );
elseif( numExceeds == numReturns && HighReturns(1) > HighExceeds(1) )
    display( '    - High Normal situation!' );
    NumHighEx = numExceeds;
elseif( numExceeds == numReturns && HighReturns(1) < HighExceeds(1) )
    display( '    - High Trim head and tail situation!' );
    residual = makeResidual( seg, HighExceeds(end), detector.duration_max );
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
    residual = makeResidual( seg, HighExceeds(end), detector.duration_max );
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
        residual = makeResidual( seg, LowExceeds(1), detector.duration_max );
    end
    NumLowEx = 0;
elseif( numExceeds == numReturns && LowReturns(1) < LowExceeds(1) && numExceeds ==1 )
    display( '    - Low Enters exceeded, leaves exceeded situation!' );
    %NumHighEx = 0;  % None here, but could be in next seg
    if( NumHighEx == 0 || LowExceeds(1) < HighExceeds(1) )
        residual = makeResidual( seg, LowExceeds(1), detector.duration_max );
    end
    NumLowEx = 0;
elseif( numExceeds == numReturns && LowReturns(1) > LowExceeds(1) )
    display( '    - Low Normal situation!' );
    NumLowEx = numExceeds;
elseif( numExceeds == numReturns && LowReturns(1) < LowExceeds(1) )
    display( '    - Low Trim head and tail situation!' );
    if( NumHighEx == 0 || LowExceeds(end) < HighExceeds(end) )
        residual = makeResidual( seg, LowExceeds(end), detector.duration_max );
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
        residual = makeResidual( seg, LowExceeds(end), detector.duration_max );
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


%----------- Now we do  validations ------------

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
    thisPulseStartT = seg.DataCommon.UTCref + ( startIdx - 0.5 ) * samplePeriod;
    thisPulseFinishT = seg.DataCommon.UTCref + ( finishIdx - 0.5 ) * samplePeriod;
    [ peak, ith ] = max(thisPulse);
    [ puke, eeth ] = min(thisPulse);
    peakT = xValues( ith+startIdx );
    mag=sqrt(sum((thisPulse - Mean).^2));
    rowCounter = rowCounter + 1;
    rows( rowCounter, : ) = [ thisPulseStartT, pulseLength, sid, channel, 1.0, double(peak), double(puke), 1.0, 1.0, peakT, mag ];
end

for i = 1 : NumLowEx
    startIdx = LowExceeds(i);
    finishIdx = LowReturns(i);
    pulseLength = ( finishIdx - startIdx ) / seg.sampleRate; % Seconds
    thisPulse = samps(startIdx:finishIdx);
    thisPulseStartT = seg.DataCommon.UTCref + ( startIdx - 0.5 ) * samplePeriod;
    thisPulseFinishT = seg.DataCommon.UTCref + ( finishIdx - 0.5 ) * samplePeriod;
    [ peak, ith ] = max(thisPulse);
    [ puke, eeth ] = min(thisPulse);
    peakT = xValues( ith+startIdx );
    mag=sqrt(sum((thisPulse - Mean).^2));
    st = sscanf(seg.DataCommon.station,'%f');
    rowCounter = rowCounter + 1;
    rows( rowCounter, : ) = [ thisPulseStartT, pulseLength, sid, channel, -1.0, double(peak), double(puke), 1.0, 1.0, peakT, mag ];
end

% Write 'em all ...
%for p = 1 : totalFound
%    fwrite(fid, rows(p,:), 'double');
%end
%return


% Now sort by start time and toss chains
rows = sortrows( rows, 1 );
pulses = rows; % Copy to build into
numPulses = 0;
detectorDayDur = detector.duration_max / 86400;
display( [ 'Candidates found = ', sprintf( '%d', totalFound ) ] );


% Pulse train eliminator
nextPulseTime = pulseEndTime( rows, 1 );
p = 0;
while 1

    p = p + 1;  % Next pulse index

    numInWind = 0;
    while nextPulseInWindow( rows, totalFound, nextPulseTime, p+numInWind, detectorDayDur )
        numInWind = numInWind + 1;
    end
    %numInWind
    
    if( numInWind > 0 ) % More than one
        if( p+numInWind > totalFound )
            display( 'All pulses in one window' );
            break;
        else
            if( ( rows( p+numInWind, 2 ) - nextPulseTime ) <= detectorDayDur )
                % Pack 'n ship ...
                numPulses = numPulses + 1;
                % Before ...
                % [               1,           2,   3,       4,    5,            6,            7,   8,   9,    10,  11 ]
                % [ thisPulseStartT, pulseLength, sid, channel,  1.0, double(peak), double(puke), 1.0, 1.0, peakT, mag ]
                pulses( numPulses, : ) = rows( p, : ); % Start with all
                pulses( numPulses, 2 ) = ( pulseEndTime( rows, p+numInWind ) - pulses( numPulses, 1 ) ) * 86400;  % Seconds
                pulseSet = rows( p:p+numInWind, : );
                sz = size( pulseSet );
                numInSet = sz(1);
                upPs = find( pulseSet(:,5) == 1.0 );
                numUps = length(upPs);
                dnPs = find( pulseSet(:,5) == -1.0 );
                numDns = length(dnPs);
                if( numUps+numDns ~= numInSet )
                  display( 'Uncharacterized pulses found !!!' );
                end
                [maxx, idxMax] = max( pulseSet(:,6) );
                pulses( numPulses, 6 ) = maxx;
                pulses( numPulses, 8 ) = idxMax;
                [minn, idxMin] = min( pulseSet(:,9) );
                pulses( numPulses, 7 ) = minn;
                pulses( numPulses, 9 ) = idxMin;
                if( pulseSet(:,5) == 1.0 ) % Compute peakT
                    pulses( numPulses, 10 ) = pulseSet( idxMax, 10 );
                else
                    pulses( numPulses, 10 ) = pulseSet( idxMin, 10 );
                end
                pulses( numPulses, 11 ) = sum( pulseSet(:,11) );
                nextPulseTime = pulses( numPulses, 2 ) + detectorDayDur;
                % After ...
                % [               1,           2,   3,       4,        5,    6,    7,      8,      9,    10,  11 ]
                % [ thisPulseStartT, pulseLength, sid, channel, polarity, maxx, minn, idxMax, idxMin, peakT, mag ]
            else
                nextPulseTime = pulseEndTime( rows, p+numInWind ) + detectorDayDur;                    
            end
            p = p + numInWind;
        end
    else % One only
        if( p+numInWind > totalFound )
            break;
        else
            numPulses = numPulses + 1;
            pulses( numPulses, : ) = rows( p, : );        
            nextPulseTime = pulseEndTime( pulses, numPulses ) + detectorDayDur;
        end
    end
end
display( [ 'Candidates remaining for final check = ', sprintf( '%d', numPulses ) ] );
% Trim to fit
pulses = pulses( 1:numPulses, : );



% Re-check durations
pulsesOut = pulses;
for pth = 1 : numPulses
    pDurDays = pulseEndTime( pulses, pth ) - pulses(pth,1);
    if( pDurDays <= detectorDayDur )
        numQuald = numQuald + 1;
        pulsesOut( numQuald, : ) = pulses( pth, : );
    else
        %display( [ 'Punted = ', sprintf( 'Pulse %d for duration %f/%f', pth, pDurDays*86400, pulses(pth,2) ) ] );
    end
end
pulsesOut = pulsesOut( 1:numQuald, : );


% Now write
for p = 1 : numQuald
    fwrite(fid, pulsesOut(p,:), 'double');
end

display( [ 'Num Pulses found = ', sprintf( '%d', numQuald ) ] );

return;



