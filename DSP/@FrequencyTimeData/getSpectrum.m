function out = getSpectrum (obj, atTime)
% Extract and return the spectrum closest in time to atTime.
% 
fs = obj.sampleRate;

index = (atTime - obj.DataCommon.timeOffset) * fs;
index = round(index);   % Get nearest time point

% Select the spectrum at index
samps = obj.samples;
samps = samps(:, index);

out = FrequencyData(obj.DataCommon, samps, obj.freqResolution);

out.title = ['Spectrum'];

out.valueType = 'Power';
out.valueUnit = 'dB';

% Adjust times
fftlen  = fs / out.freqResolution;
timespan = (fftlen-1) / fs;

actualTime = obj.DataCommon.timeOffset + (index-1) / fs;

out.timeOffset = actualTime - timespan/2;
out.timeEnd    = actualTime + timespan/2;

