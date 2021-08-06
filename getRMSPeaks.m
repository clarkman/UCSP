function [ peaks ] = getRMSPeaks( arr, sensors )

sz = size(arr);
numExps = sz(1);

%voltsCorr = 2 * sqrt(2) / 2 
voltsCorr = sqrt(2);

pTmp = zeros( numExps, 2 );

% Choppers
Fs = 24000;
numMSecs = 110;
c = [ Fs, Fs+numMSecs*Fs/1000 ];

expCtr = 0;
for ex = 1 : numExps
  [ data, fNames ] = loadData( arr, ex, sensors );
  expCtr = expCtr + 1;
  audio = data{1};
  piezo = data{2};
  audioCorr = undB(arr(ex,6)+arr(ex,7));
  piezoCorr = undB(arr(ex,8)+arr(ex,9));
  pTmp(expCtr,1) = voltsCorr * std(audio(c(1):c(2))./audioCorr);
  pTmp(expCtr,2) = voltsCorr * std(piezo(c(1):c(2))./piezoCorr);
end

peaks = pTmp(1:expCtr,:);

