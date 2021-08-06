function arrOut = knockoutStatZeros( arrIn )

nonZeroInds = find( arrIn(:,3) ~= 0 );

arrOut = extractRows( arrIn, nonZeroInds );