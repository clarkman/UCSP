function [ peaks ] = getAccelPwr( arr, sensors, ch )

sz = size(arr);
numExps = sz(1);

Fs = 5000;
sliceP = [ 5000, 10000 ];

pTmp = zeros( numExps, 1 );

expCtr = 0;
for ex = 1 : numExps
  % Find gravity (x = transverse; y = up/down; z = in/out)
  [ data, fNames ] = loadAccelData( arr, ex, sensors );
  chData=data{1};
  [ val, ith ] = max( abs(gravityEstimator( chData(:,2:4) )));
  switch ch    
    case 3 % z Axis invariant unless ceiling mounted (none at NMHS)
      if ith == 3
      	figure
      	plot(chData(:,4))
      	title(sprintf('Sensor = %d',arr(ex,4)))
      	error('Sanity check: z Axis invariant unless ceiling mounted (none at NMHS)')
      end
      loadCh = 4;
    case 2
      if ith == 2
        loadCh = 3;
      else
        loadCh = 2;
      end
    case 1
      if ith == 2
        loadCh = 2;
      else
        loadCh = 3;
      end
    otherwise
      error('Crazy')
  end

  expCtr = expCtr + 1;
  accel = chData(:,loadCh);
  if ch == 2
  	Fs=5000;
  	sliceInds = [ 0.15*Fs, 0.19*Fs ];
    yHat = mean(accel(sliceInds(1):sliceInds(2)));
    accel = accel - yHat;
  end

  pTmp(expCtr,1) = std(accel(sliceP).^2);
end

peaks = pTmp(1:expCtr,:);

