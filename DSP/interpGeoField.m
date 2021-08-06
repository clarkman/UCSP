function fmsInterp = interpGeoField( spFreq )

freqs=[20,10,5,1,0.1,0.07,0.04,0.01,0.001];
freqs = fliplr( freqs );
fms=[0.0008,0.0008,0.0009,0.002,0.01,0.02,0.44,1.4,50];
fms = fliplr( fms );
%fns=[0.000022,0.000022,0.000028,0.0001,0.001,0.0017,0.003,0.017,0.2];


if( spFreq > 16 || spFreq < 0 )
    error('Freq off for interpolation!');
end

daLength = length( freqs );

ith = daLength;
while( freqs(ith) >= spFreq )
    ith = ith - 1;
    if( ith == 0 )
        error( 'Freq too low for interpolation!' );
    end
end

freqRange  = freqs(ith+1) - freqs(ith);
freqScalar = (spFreq-freqs(ith))/freqRange;
fmsDelta  = (fms(ith+1) - fms(ith)) * freqScalar;

%mags(ith)+magDelta
%phases(ith)+phaseDelta

fmsInterp = fms(ith)+fmsDelta;


