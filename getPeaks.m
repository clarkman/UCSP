function [ peaks ] = getPeaks( arr, sensors )

sz = size(arr);
numExps = sz(1);

%voltsCorr = 2 * sqrt(2) / 2 
voltsCorr = sqrt(2);

pTmp = zeros( numExps, 2 );

expCtr = 0;
for ex = 1 : numExps
  [ data, fNames ] = loadData( arr, ex, sensors );
  expCtr = expCtr + 1;
  audio = data{1};
  piezo = data{2};
  audioCorr = undB(arr(ex,6)+arr(ex,7));
  piezoCorr = undB(arr(ex,8)+arr(ex,9));
  pTmp(expCtr,1) = voltsCorr * max(abs(audio))/audioCorr;
  pTmp(expCtr,2) = voltsCorr * max(abs(piezo))/piezoCorr;
end

peaks = pTmp(1:expCtr,:);

