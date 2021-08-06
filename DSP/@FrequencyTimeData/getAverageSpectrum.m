function out = getAverageSpectrum (obj, time1, time2)
% Average the spectra between time1 and time2 and return the averaged spectrum.
% 
fs = obj.sampleRate;

index1 = (time1 - obj.DataCommon.timeOffset) * fs;
index1 = ceil(index1);   % Get spectrum after time1
index1 = max(index1, 1);

index2 = (time2 - obj.DataCommon.timeOffset) * fs;
index2 = floor(index2);   % Get spectrum before time2
index2 = min( index2, size(obj.samples,2) );

if (index1 > index2)
    error('No spectrum within that time window');
end

% Select the spectra
samps = obj.samples(:, index1:index2);

% Convert from dB back to linear, average them, and convert back to dB
samps = 10 .^ (samps/20);
samps = mean(samps,2);
samps = 20*log10(samps);

out = FrequencyData(obj.DataCommon, samps, obj.freqResolution);

out.title = [num2str(index2-index1+1), ' Averaged Spectra'];

out.valueType = 'Power';
out.valueUnit = 'dB';

% Adjust times
fftlen  = fs / out.freqResolution;
timespan = (fftlen-1) / fs;

actualTime1 = obj.DataCommon.timeOffset + (index1-1) / fs;
actualTime2 = obj.DataCommon.timeOffset + (index2-1) / fs;

out.timeOffset = actualTime1 - timespan/2;
out.timeEnd    = actualTime2 + timespan/2;

