function [ peaks, units ] = getIRPeaks( arr, sensors )
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
  [ data, fNames ] = loadData( arr, ex, sensors );
  if isempty( data )
  	continue;
  end
  expCtr = expCtr + 1;
  ir = data{3};
  pTmp(expCtr,1) = max(abs(ir));
  pTmp(expCtr,2) = arr(ex,11);
end

peaks = zeros(expCtr,2);
%peaks(:,1) = pTmp(1:expCtr,1);
%units = 'IR';
peaks(:,1) = 20 .* log10(pTmp(1:expCtr,1));
units = 'dB-IR';
peaks(:,2) = pTmp(1:expCtr,2)';

