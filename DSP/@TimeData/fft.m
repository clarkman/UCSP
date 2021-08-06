function outObj = fft( obj, fftlen, includeNegFreqs )
%
% Compute and return the fft. (One sided)
%

if nargin >= 3
   makeNegs = includeNegFreqs;
else
   makeNegs = 0;
end

objLength = length( obj );

if ( objLength == 0 )
    error( [' TimeData object for ', obj.DataCommon.source, ' has no samples'] );
end

fs = obj.sampleRate;
if( nargin == 1 )
    fftlen = objLength;
else
    if( objLength < fftlen )
        warning( 'fftlength longer than data series, zero padding!' );
    end
end

if( mod(fftlen,2) )
    error( 'Odd number of points' );
end

freqRes = fs / fftlen;



%hamm = kaiser(objLength);
%hamm = blackman(objLength);
%hamm = hanning(objLength);
blak = hamming(fftlen);

%samps = fftshift(fft(obj.samples));
daSamps = slice( obj, 1, fftlen );
%daSamps = removeDC( daSamps )
%fftBins = fft( daSamps.samples, fftlen );
fftBins = fft( (daSamps.samples .* blak), fftlen );
numBins = length( fftBins );

%plot( real(fftBins) ); hold on;
%plot( imag(fftBins) ); hold off;

%fftBins = 20 * log10( fftBins );

isComplex = isreal( fftBins )

if( makeNegs )
    outObj = FrequencyData( obj.DataCommon, fftBins, freqRes );
else
    outObj = FrequencyData( obj.DataCommon, fftBins(1:fftlen/2+1), freqRes );
end
%outObj = FrequencyData( obj.DataCommon, abs(fftBins(1:fftlen/2+1)), freqRes );


out.valueType = 'Power';
out.valueUnit = 'dB';
