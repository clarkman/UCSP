function outObj = makeSinusoid( Ampl, fs, w, ph, lengthSecs )

%
% Ampl = amplitude
% fs   = samples/second
% w    = frequency, hz
% ph   = phase offset in Radians, typ. zero(0)
%
% USAGE:
% arf=makeSinusoid( 10.0, 32, 1, 0, 10 );
%

outObj = TimeData;

lengthSamps = lengthSecs * fs;

sine = zeros( 1, lengthSamps );

for ith = 1 : lengthSamps
    sine(ith) = Ampl * sin(2.0 * pi * (w/fs)*ith + ph );
end

outObj.sampleRate = fs;
outObj.samples = sine';
