function amData = amDemod(obj, centerFreq)
%
% AM demodulates by a frequency translation of -centerFreq, and lowpass
% filtering. The output has the same units as the input.
% 

% Initialize objects to be the same
amData = obj;

fs = obj.sampleRate;

amData.samples = demod(obj.samples, centerFreq, fs, 'am', 1);

amData = addToTitle(amData, ['AM Detect @ ', num2str(centerFreq), ' Hz']);
