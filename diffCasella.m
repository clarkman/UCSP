function diffCasella( truth, dare )

sz = size(dare);

unks = zeros(sz(1),1);
numUnks = 0;

for row = 1 : sz(1)
  idx = truth(row,2);
  val = truth(row,1);
  if idx == 0
    numUnks = numUnks + 1;
    unks(numUnks) = row;
    continue
  end
  idxs = find( dare(:,2) == idx );
  for ith = 1 : numel(idxs)
  	dareIdx = dare( idxs(ith), 2 );
  	dareVal = dare( idxs(ith), 1 );
  	if( dareVal ~= val && dareVal ~= 0.0 )
  	  error( sprintf( 'Miss at truth row: %d, idx: %d, val should be: %g, dareRow: %d, dareIdx %d is: %g', row, idx, val, idxs(ith), dareIdx, dareVal ) )
  	end
  end
end
