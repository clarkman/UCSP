function peaks = loadSignalPeaks( m, testStrs, gunStrs, ammoStrs, xducerStrs, labJackStrs, xducerCode )

sz = size(m);
numInds = sz(1);
results = zeros(numInds,1);

for d = 1 : numInds

  xducerCol = 0;
  for c = 1 : 4
    if m(d,c+7) == xducerCode
      xducerCol = c;
      break;
    end
  end
  if xducerCol == 0
    % No need to load
    warning('Should not be here!')
    continue
  end

  tdObjs = loadRow2( d, m, testStrs, gunStrs, ammoStrs, xducerStrs, labJackStrs );
  tdObj = tdObjs{xducerCol};
  results(d) = max(abs(tdObj));

end

peaks = results;