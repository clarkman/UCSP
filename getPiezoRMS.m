function [ rmses ] = getPiezoRMS( arr, sensors )

sz = size(arr);
numExps = sz(1);

%voltsCorr = 2 * sqrt(2) / 2 
voltsCorr = sqrt(2);

sliceP = [ 24000, 48000 ];


pTmp = zeros( numExps, 2 );

expCtr = 0;
for ex = 1 : numExps

  switch arr(ex,1)
    case 2 % Cafeteria 1.388
      sliceP = [ 24000, 24000 + 1.388 * 24000 ];
    case 9 % Library .337
      sliceP = [ 24000, 24000 + .337 * 24000 ];
    case 1 % Office .254
      sliceP = [ 24000, 24000 + .254 * 24000 ];
    otherwise
      sliceP = [ 24000, 48000 ];
  end

  [ data, fNames ] = loadPiezoData( arr, ex, sensors );
  if isempty(data)
  	continue
  end
  expCtr = expCtr + 1;
  piezo = data{1};
  piezoCorr = undB(arr(ex,8)+arr(ex,9));
  pTmp(expCtr,1) = voltsCorr * rms(piezo(sliceP))/piezoCorr;
  %pTmp(expCtr,1) = pTmp(expCtr,1) ./ (sliceP(2)-sliceP(1)+1);
end

rmses = pTmp(1:expCtr,:);

