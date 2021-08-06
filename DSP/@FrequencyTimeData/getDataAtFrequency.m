function out = getDataAtFrequency (obj, atFreq)
% Extract and return the amplitude data closest in frequency to atFreq.
% 

index = atFreq / obj.freqResolution;
index = round(index);   % Get nearest frequency point

% Select the time points at index
samps = obj.samples;
samps = samps(index, :);



out = TimeData(obj.DataCommon, samps, obj.sampleRate);

out = addToTitle(out, ['Time Data at ', num2str(atFreq), ' Hz'] );

out.valueType = obj.valueType;
out.valueUnit = obj.valueUnit;

