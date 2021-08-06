function outObj = ifft(obj)
%
% Compute and return the power spectral density, and corresponding 
%   frequency vector, in power (dB) per Hz, based on the given FFT length.
%

if( length(obj.samples) == 0 )
    error([' TimeData object for ', obj.DataCommon.source, ' has no samples']);
end

if ( isreal(obj) )
    error([' TimeData object for ', obj.DataCommon.source, ' is not complex']);
end

args=ifft(obj.samples);

outObj = TimeData;
outObj.DataCommon = obj.DataCommon;
outObj.sampleRate = (length(obj))*obj.freqResolution;
outObj.samples = args;
