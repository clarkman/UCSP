function [ peaks, units ] = getAudioPeaks( arr, sensors, dBCorr )
%GETAUDIOPEAKS Computes peaks for all experiments in arr.
% 
% arr - Experiment array
%
% sensors - Sensor decoder struct array

sz = size(arr);
numExps = sz(1);

%voltsCorr = 2 * sqrt(2) / 2 
voltsCorr = sqrt(2);

pTmp = zeros( numExps, 2 );

expCtr = 0;
for ex = 1 : numExps
  [ data, fNames ] = loadAudioData( arr, ex, sensors );
  if isempty( data )
    continue;
  end
  expCtr = expCtr + 1;
  audio = data{1};
  audioCorr = undB(arr(ex,6)+arr(ex,7));
  pTmp(expCtr,1) = voltsCorr * max(abs(audio))/audioCorr;
  pTmp(expCtr,2) = arr(ex,11);
end

% 94 is reference to standard spec.
peaks = zeros(expCtr,2);
peaks(:,1) = 20 .* log10(pTmp(1:expCtr,1))+94-dBCorr;
peaks(:,2) = pTmp(1:expCtr,2)';

units = 'dB ~ SPL';

%extractRows( arr, find( peaks > 130 ) )
