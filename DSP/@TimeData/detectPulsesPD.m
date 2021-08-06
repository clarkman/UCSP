function  [ residual, meta ] = detectPulsesPD( seg, detector, meta, fid );
%
% Works with pulseWalker2.m
%
%
%
residual = -1;

[ satMin, satMax ] = getSaturationLevels( seg.DataCommon.station );

minSamps = floor(detector.duration_min * seg.sampleRate);
maxSamps = ceil(detector.duration_max * seg.sampleRate);

segLenSecs = lengthSecs( seg );
if( segLenSecs <= detector.duration_min )
    return;
end

display( [ 'Computing pulses for: ', seg.DataCommon.station, '', seg.DataCommon.channel, ' ', datenum2str(seg.DataCommon.UTCref) ] );

meta.ch_dur = meta.ch_dur + segLenSecs / 86400;

if( strcmp( seg.DataCommon.network, 'BK' ) )
    doBK = 1;
else
    doBK = 0;
end

channelDirName = seg.DataCommon.channel;
ch = channelDirName(end);
channel = sscanf(ch,'%d');

meta.num_segs = meta.num_segs + 1;
s=seg.samples;
sz=size(s);
numSamples = sz(1); 
ids = find( s > satMax );
sz=size(ids);
meta.day_sat = meta.day_sat + sz(1);
ids = find( s < satMin );
sz=size(ids);
meta.day_sat = meta.day_sat + sz(1);
clear s;

[ centered, ctr ] = zeroCenter( seg );
fprintf( fid, '<seg_ctr segNum="%d">%d</seg_ctr>\n', meta.num_segs, round(ctr) );
% Gather ye a whole bunch of local minima maxima 
% These two arrays are sorted by index [index,ampl]
[maxtab, mintab]=peakdet( centered.samples, detector.threshold_pos*1.618 );
%Sanity check # 1 non-concurrency
c = intersect( maxtab(:,1), mintab(:,1) );
sz=size(c);
if( sz(1) )
  display( sprintf( 'Detector failure!!!  Identical indices found in %d cases!!!', sz(1) ) );
  return
end

% Assemble values array
fullSet = [ maxtab' mintab' ]';
% Now sort by index (chronologically) and count.
fullSet = sortrows( fullSet, 1 );
sz=size(fullSet);
numPulses = sz(1)
meta.day_count_raw = meta.day_count_raw + numPulses;
%Sanity check # 2 threshold
%  for p = 1 : numPulses
%    if( abs(fullSet(p,2)) < detector.threshold_pos )
%      display( sprintf( 'Detector failure!!!  Pulse found less than threshold at %d, amplitude = %f, threshold = %f!!!', p, fullSet(p,2), detector.threshold_pos ) );
%      %return
%    end
%  end

% Now build up composite matrix: idx - peak - ampl - pwr3 - pBin - seq - inter
pulses = zeros( numPulses, 7 ); 
pulses(:,1:2) = fullSet;
% P index
pulses(:,6) = 1:numPulses;
pulses(1,7) = 0;  % Bigger than a day
diffs = pulses(2:end,1)-pulses(1:end-1,1);
pulses(2:end,7) = diffs;
 

display( [ 'Raw Num Pulses found = ', sprintf( '%d', numPulses ) ] );

% Compute ampl and pwr3:
s=centered.samples;
pulses(:,3) = abs(pulses(:,2)); % Amplitude
for pth = 1 : numPulses
  idx=pulses(pth,1);
  pulses(pth,4)=sqrt((s(idx)^2+s(idx-1)^2+s(idx+1)^2)/3.0);
end
clear s;

sortCol = 3;
pmags = sortrows( pulses, -sortCol );

thisPulse = 1;
while( pmags(thisPulse,sortCol) > detector.threshold_pos )
  curr=pmags(thisPulse,6);
  % "curr is the first of the ensemble
  if( pulses(curr,5) ) % taken
    %display( 'Pulse Taken' );
    thisPulse = thisPulse + 1;
    continue;
  end
  if( pulses(curr,7) > maxSamps )
    %display( 'Clearly separated' )
    pulses(curr,5) = 2;
  else
    %display( 'Clearly NOT separated' )
    pulses(curr,5) = 1;
  end
  next = curr;
  while 1
    next = next + 1;
    if( next > numPulses )
      break;
    end
    if( pulses(next,7) > maxSamps || pulses(next,5) )
      break;
    end
    pulses(next,5) = -1;
  end
  thisPulse = thisPulse + 1;
end

numth = thisPulse-1;
pulses = pulses( 1:numth, : );
% Now computed residual ...
for ith = numth : -1 : 1
  if(  pulses( ith, 7 ) > maxSamps )
    residual = offset( slice( seg, pulses( ith, 1 ), numSamples ) );
    break
  end
end
ith

pulses = pulses( 1:ith-1, : );

%pulses( 1:20, : )
pulses
maxSamps
%pulses
plotPeakDetTest( centered, maxtab, mintab, pulses, detector.threshold_pos, maxSamps ) 

return;




