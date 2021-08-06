function outobj = freqTranslate(obj, freq)
%
% Frequency translates the input object by multiplying by a sinusoid at the
% specified freq (HZ).

    
% Initialize objects to be the same
outobj = obj;

fs = obj.sampleRate;
radiansPerSample = 2 * pi * freq / fs;

% Compute sinusoid
sinusoidPhase = 0 : length(obj.samples)-1;         % start at 0
sinusoidPhase = sinusoidPhase * radiansPerSample;  % in radians
sinusoidPhase = cos(sinusoidPhase);
sinusoidPhase = sinusoidPhase';

% Perform frequency translation
outobj.samples = obj.samples .* sinusoidPhase;

outobj = addToTitle(outobj, ['Freq. Translated by ', num2str(freq), ' Hz']);

