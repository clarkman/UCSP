function sprdr = makeSpreader( inds, width )

halfWidth = abs(width) / 2;

numInds = numel( inds );

if numInds < 2
  sprdr = 0;
  return
end

sprdWidth = 0.5 / (numInds-1);

sprdr = zeros( numInds, 1 );
for ith = 0 : numInds-1
  sprdr(ith+1) = -halfWidth + ith * sprdWidth;
end
