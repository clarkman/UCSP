function outObj = periodogram( obj )
%
% Compute and return the fft. (One sided)
%

objLength = length( obj );

if ( objLength == 0 )
    error( [' TimeData object for ', obj.DataCommon.source, ' has no samples'] );
end

fs = obj.sampleRate;
fftlen = objLength;

if( mod(fftlen,2) )
    error('Odd number of points');
end

% True resolution based on neg & positive frequencies!
freqRes = fs / fftlen;

% One sided result.
[Pxx,f] = periodogram( obj.samples, hamming(fftlen), fftlen, fs );

% Construct frequency data object.
outObj = FrequencyData( obj.DataCommon, Pxx, freqRes );


out.valueType = 'Power / Hz';
out.valueUnit = 'counts';
