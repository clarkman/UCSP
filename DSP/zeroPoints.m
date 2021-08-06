function zeroedObj = zeroPoints( inObj, t, pad )

% Window
t0 = t - pad;
t1 = t + pad;

zeroedObj = inObj;
dataBeg = inObj.UTCref;
dataEnd = inObj.UTCref + inObj.timeEnd/86400;

sampsPerDay = inObj.sampleRate*86400;


if t1 < dataBeg || t0 > dataEnd
  warning( 't missed the data!' )
  return
end

% Actually going to do something now ...
samps = zeroedObj.samples;

% Window overlaps beginning of data.
if t0 < dataBeg && t1 >= dataBeg
  % Trim beginning
t1 - inObj.UTCref
  n = ceil( ( t1 - inObj.UTCref ) * sampsPerDay )
  if n
    samps(1:n) = 0;
  end
  zeroedObj.samples = samps;
  %display( sprintf( 'Zeroed beginning samples 1:%u', n ) );
  return
end

% Window overlaps end of data.
if t0 <= dataEnd && t1 > dataEnd
  % Trim beginning
  n = floor( ( t0 - inObj.UTCref ) * sampsPerDay )
  if n
    samps(n:end) = 0;
  end
  zeroedObj.samples = samps;
  %display( sprintf( 'Zeroed end samples %u:end', n ) );
  return
end

% Trim beginning
n0 = ceil( ( t0 - inObj.UTCref ) * sampsPerDay );
n1 = floor( ( t1 - inObj.UTCref ) * sampsPerDay );
if n0 && n1
  samps(n0:n1) = 0;
  zeroedObj.samples = samps;
  %display( sprintf( 'Zeroed samples %u:%u', n0, n1 ) );
else
  warning( sprintf( 'Zero index n0 = %u, n1 = %u' ) )
end


