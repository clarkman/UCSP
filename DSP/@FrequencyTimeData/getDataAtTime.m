function out = getDataAtTime( obj, atTime )
% Extract and return the frequency data closest in time to atTime.
% 

index = atTime * obj.sampleRate;
index = round(index);   % Get nearest frequency point

% Select the time points at index
samps = obj.samples;
samps = samps(:, index);

freqRes = 4.0 / ( (getNumFreqPts( obj ) - 1) *2 );

out = FrequencyData( obj.DataCommon, samps, freqRes );

out = addToTitle(out, ['Frequency Data at ', num2str(atTime), ' Secs'] );

out.valueType = 'Power';
out.valueUnit = '';

