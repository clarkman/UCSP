function dn = moniker2datenum( moniker, doPST )
%  $Id: moniker2datenum.m,v d4e01bc08f7c 2013/10/28 18:54:34 qcvs $

% Funny kind of floor
if( isnumeric( moniker ) )
  monStr = sprintf( '%08d', moniker );
else
  monStr = moniker;
end
if nargin > 1
  dn = str2datenum( [ monStr(1:4), '/', monStr(5:6), '/', monStr(7:8), ' 08:00:00' ] );
else
  dn = str2datenum( [ monStr(1:4), '/', monStr(5:6), '/', monStr(7:8), ' 00:00:00' ] );
end
