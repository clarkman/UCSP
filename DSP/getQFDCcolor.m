function qfdcColor = getQFDCcolor( colorName )


% Get QFDC color
[ host, user, passwd ] = getMYSQLenv();
try
  mym('open', host, user, passwd );
  mym('use', 'xweb');
  queryStatement = [ 'SELECT * FROM qfdc_colors WHERE qc_name =''' colorName '''' ];
  qfdcColor = mym( queryStatement );
  mym('close');
catch
  display( 'Could not fetch QFDC color!!!' );
  display( 'FAILURE' );
  qfdcColor = -1;
end
