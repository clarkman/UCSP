function [ peaks, units ] = getAccelPeaks( arr, sensors, ch )

sz = size(arr);
numExps = sz(1);

pTmp = zeros( numExps, 3 );

expCtr = 0;
for ex = 1 : numExps
  % Find gravity (x = transverse; y = up/down; z = in/out)
  [ data, fNames ] = loadAccelData( arr, ex, sensors );
  if isempty( data )
    continue;
  end
  chData=data{1};
  %szAccel = size(chData)
  %arr(ex,:)
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

  Fs = 5000;
  switch arr(ex,1)
    case 2 % Cafeteria 1.388
      sliceP = [ Fs, Fs + 1.388 * Fs ];
    case 12 % Cafeteria 1.388
      sliceP = [ Fs, Fs + 1.388 * Fs ];
    case 9 % Library .337
      sliceP = [ Fs, Fs + .337 * Fs ];
    case 10 % Library .337
      sliceP = [ Fs, Fs + .337 * Fs ];
    case 1 % Office .254
      sliceP = [ Fs, Fs + .254 * Fs ];
    case 11 % Office .254
      sliceP = [ Fs, Fs + .254 * Fs ];
    otherwise
      sliceP = [ Fs, 2*Fs ];
  end


  expCtr = expCtr + 1;
  accel = chData(:,loadCh);
  if ch == 2
  	Fs=5000;
  	sliceInds = [ 0.15*Fs, 0.19*Fs ];
    yHat = mean(accel(sliceInds(1):sliceInds(2)));
    accel = accel - yHat;
  end

  pTmp(expCtr,1) = 20.*log10(max(abs(accel)));
  pTmp(expCtr,2) = arr(ex,11);
  pTmp(expCtr,3) = 20.*log10(rms(accel(sliceP)));
end

peaks = pTmp(1:expCtr,:);
units = 'dB |G''s|';

