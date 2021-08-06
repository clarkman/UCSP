function xducerHits = buildXducerIndices( m )
 % Looking up transducers requires two indices per hit: row & col
 % Thus we return a cell array of 1x2 arrays.

chCodes = getChannelCodes();
numChCodes = length(chCodes);
sz = size(m);
numRows = sz(1);

whichLabjack = unique(m(:,13))
if numel(whichLabjack) > 1
  whichLabjack = 0;
end

for t = 1 : numChCodes

  chArray = [];
  chCode = getXducerCode( chCodes, chCodes{t,2} );

  % Data was collected on empty channels of b & c
  if chCode > 12 && whichLabjack > 1
  	xducerHits{t} = chArray;
  	continue
  end

  for col = 8 : 11
    chInds = find( m(:,col) == chCode );
    chHits = numel(chInds);
    display( sprintf( 'In col %02d, found %03d of %s', col, chHits, getXducerStr( chCodes, chCode )) )
    if chHits == 0
      continue;
    end
    colArray = zeros( chHits, 2 );
    colArray(:,1) = chInds;
    colArray(:,2) = col;
    chArray = [ chArray ; colArray ];
  end

  xducerHits{t} = chArray;
end

