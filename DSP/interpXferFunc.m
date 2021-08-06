function [freq, mag, phase] = interpXferFunc( freqs, mags, phases, spFreq )

if( spFreq > 16.2 )
    error('Freq too high for interpolation!');
    % Phase wraps around from 16-32 Hz.
end

daLength = length( freqs );

ith = daLength;
while( freqs(ith) > spFreq )
    ith = ith - 1;
    if( ith == 0 )
        %error( 'Freq too low for interpolation!' );
        break;
    end
end

freqRange  = freqs(ith+1) - freqs(ith);
freqScalar = (spFreq-freqs(ith))/freqRange;
magDelta  = (mags(ith+1) - mags(ith)) * freqScalar;
phaseDelta  = (phases(ith+1) - phases(ith)) * freqScalar;
freqDelta  = (freqs(ith+1) - freqs(ith)) * freqScalar;

%mags(ith)+magDelta
%phases(ith)+phaseDelta

freq  = freqs(ith)+freqDelta;
mag   = mags(ith)+magDelta;
phase = phases(ith)+phaseDelta;


