function results = loadSignalMatrix( inds, m, testStrs, gunStrs, ammoStrs, xducerStrs, labJackStrs, st )

results = zeros(1000,15);
sz = size(inds);
numInds = sz(1)
numShots = 0;

for d = 1 : numInds

  tdObjs = loadRow2( inds(d,1), m, testStrs, gunStrs, ammoStrs, xducerStrs, labJackStrs );
  tdObj = tdObjs{inds(d,2)-7};

  [ cnt, peaks, durs, onsets, decays, noisePeak, noiseRmsAvg ] = findImpulses( tdObj );
  cnts(d)=cnt;
  if cnt == 0 % Penalize
    for miss = 1 : 3
      row = miss + numShots;
      results(row,1) = inds(d);
      results(row,2) = 0;
      results(row,3) = 0;
      results(row,4) = 0;
      results(row,5) = 0;
      results(row,6) = noisePeak;
      results(row,7) = noiseRmsAvg;
      results(row,8) = 10*log10(1);
      results(row,9) = 10*log10(1);
      results(row,10) = m(inds(d,1),5);
      results(row,11) = m(inds(d,1),6);
      results(row,12) = m(inds(d,1),1);
      results(row,13) = m(inds(d,1),13);
      results(row,14) = m(inds(d,1),4);
      results(row,15) = m(inds(d,1),12);
    end
    numShots = numShots + 3;
  else
    for shot = 1 : cnt
      row = shot + numShots;
      results(row,1) = inds(d);
      results(row,2) = peaks(shot);
      results(row,3) = durs(shot);
      results(row,4) = onsets(shot);
      results(row,5) = decays(shot);
      results(row,6) = noisePeak;
      results(row,7) = noiseRmsAvg;
      results(row,8) = 10*log10(peaks(shot)^2 / noisePeak^2); % 10*log(Ps/Pw)
      results(row,9) = 10*log10(peaks(shot)^2 / noiseRmsAvg^2);
      results(row,10) = m(inds(d,1),5);
      results(row,11) = m(inds(d,1),6);
      results(row,12) = m(inds(d,1),1);
      results(row,13) = m(inds(d,1),13);
      results(row,14) = m(inds(d,1),4);
      results(row,15) = m(inds(d,1),12);
    end
    numShots = numShots + cnt;
  end

end
figure
results = results(1:numShots,:);
plot(results(:,13))
