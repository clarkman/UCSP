function stations = getStationSet()
%  $Id: getStationSet.m,v 50956b4903ae 2014/03/19 00:25:36 qcvs $



% Set up environment ...
[ host, user, passwd ] = getMYSQLenv();
try
  mym('open', host, user, passwd );
  mym('use', 'xweb');
  queryStatement = [ 'SELECT sid FROM ground_observatories' ];
  stations = mym( queryStatement );
  mym('close')
catch
  display( 'Could not fetch Sation Info ...' );
  display( 'FAILURE' );
  staInfo = -1;
end
