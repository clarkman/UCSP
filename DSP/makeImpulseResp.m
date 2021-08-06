function impulseOut = makeImpulseResp( xferFunc )

len = length( xferFunc );
numTimeSeriesSamples = (len-1) * 2;

% Assumes points are evenly spread in frequency!
freqRes = xferFunc(2) - xferFunc(1)
sampleRate = numTimeSeriesSamples * freqRes

for binth = 1 : len
    rad = xferFunc(binth,3) * pi/180.0;
    impulseFreq(binth) = complex( xferFunc(binth,2) * cos(rad), xferFunc(binth,2) * sin(rad) );
end

impulseNegFreqs = conj(impulseFreq(length(impulseFreq):-1:1));

freqSignal = [ impulseNegFreqs(1:len-1), impulseFreq ]';

lenImpulseNegFreqs = length( impulseNegFreqs )
lenImpulseFreq = length( impulseFreq )
lenFreqSignal = length( freqSignal )

%plot( abs(freqSignal) )

impulseOut = ifft( freqSignal );
