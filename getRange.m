function range = getRange( ranges, fp, sensor )

rIdx = find( ranges(1,:) == fp & ranges(2,:) == sensor );

range = ranges( 3, rIdx );
