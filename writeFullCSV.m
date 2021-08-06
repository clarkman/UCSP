function writeFullCSV( ex, expLbls, sens )

sz = size(ex);
nrows = sz(1);
ncols = sz(2);

fid = fopen( 'fullExp.csv', 'w' );
if fid == -1
  error( 'Open failed' );
end

srcKey = makeSrcKey;


fprintf( fid, 'datetime,' );
fprintf( fid, '%s,', expLbls{1} );
fprintf( fid, '%s,', expLbls{12} );
fprintf( fid, '%s,', expLbls{2} );
fprintf( fid, '%s,', expLbls{3} );
fprintf( fid, '%s,', expLbls{4} );
fprintf( fid, 'Sensor Hex,' );
fprintf( fid, '%s,', expLbls{5} );
fprintf( fid, '%s,', expLbls{6} );
fprintf( fid, '%s,', expLbls{7} );
fprintf( fid, '%s,', expLbls{8} );
fprintf( fid, '%s,', expLbls{9} );
fprintf( fid, '%s,', expLbls{11} );
fprintf( fid, '%s,', expLbls{13} );
fprintf( fid, '%s,', expLbls{14} );
fprintf( fid, '%s\n', expLbls{15} );

for r = 1 : nrows
  sensHex = sens(ex(r,17)).sensHex;
  dstr = datestr(ex(r,10),31);
  src = srcKey(ex(r,12)).name;
  fprintf( fid, '%s,%d,%s,%d,%d,%d,%s,%d,%g,%g,%g,%g,%g,%g,%d,%g\n', dstr, ex(r,1), src, ex(r,2), ex(r,3), ex(r,4), sensHex, ex(r,5), ex(r,6), ex(r,7), ex(r,8), ex(r,9), ex(r,11), ex(r,13), ex(r,14), ex(r,15) );
end

fclose('all');