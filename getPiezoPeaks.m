function [ peaks, units ] = getPiezoPeaks( arr, sensors )
%GETPIEZOPEAKS Computes peaks for all experiments in arr (piezo).
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
  [ data, fNames ] = loadPiezoData( arr, ex, sensors );
  if isempty( data )
    continue;
  end
  expCtr = expCtr + 1;
  piezo = data{1};
  piezoCorr = undB(arr(ex,8)+arr(ex,9));
  pTmp(expCtr,1) = voltsCorr * max(abs(piezo))/piezoCorr;
  pTmp(expCtr,2) = arr(ex,11);
end

peaks = zeros(expCtr,2);
peaks(:,1) = 20 .* log10(pTmp(1:expCtr,1)')+168;
peaks(:,2) = pTmp(1:expCtr,2)';

units = 'dB Unknown';
