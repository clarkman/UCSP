function makeXferTest()

signalLength = 64;
sampleRate = 32;

sig1 = makeSinusoid( 0.9, 32, 5, 0, signalLength/sampleRate );
sig2 = makeSinusoid( 2.0, 32, 1, 0, signalLength/sampleRate );
sig3 = makeSinusoid( 4.0, 32, 0.5, 0, signalLength/sampleRate );
sig4 = makeSinusoid( 10.0, 32, 0.1, 0, signalLength/sampleRate );
sig5 = makeSinusoid( 110.0, 32, 0.05, 0, signalLength/sampleRate );
sig6 = makeSinusoid( 1200.0, 32, 0.01, 0, signalLength/sampleRate );

sig = sig1+sig2+sig3+sig4+sig5+sig6;

figure; plot(sig);

sig1Fft = fft(sig, length(sig), 1);

plot(abs(sig1Fft));



if isreal(sig1Fft)
    error( 'FFT result s/b complex.' )
end

sizor = length(sig1Fft)

if( sizor ~= signalLength )
    error( 'FFT length s/b same.' )
end

%plot( sig1-arn )


freqRFes = 32 / signalLength;
numBins = (sizor/2)+1
binFreqs = zeros(numBins,1);
for fth = 1 : numBins
    binFreqs(fth) = ( (fth-1) * freqRFes);
end


xferArray = zongeXferFunc('U414SAR.DAT',sizor,binFreqs(2),binFreqs(numBins));

bins = zeros(numBins,2);
for nth = 2 : sizor
    bins(nth,1) = xferArray(nth,1);
    rads = xferArray(nth,3) * pi/180;
    bins(nth,2) = xferArray(nth,2)*cos(rads) + xferArray(nth,2)*sin(rads)*i;
end
bins(1,1) = 0.0;
bins(1,2) = 0.0 + 0.0*i;

off = 0;
for ith = numBins : -1 : 2
    sig1Fft(ith-1+256) = sig1Fft(ith-1+256) * bins(ith,2);
    %sig1Fft(numBins-ith+1) = sig1Fft(numBins-ith+1) * conj(bins(ith,2));
    sig1Fft(numBins-ith+1) = sig1Fft(numBins-ith+1) * bins(ith,2);
end

plot(abs(sig1Fft));

arn = ifft(sig1Fft)

figure; plot( real(arn) )
