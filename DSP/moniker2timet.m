function timet = moniker2timet( moniker )

monStr = sprintf( '%08d', moniker );
dnStr = [ monStr(1:4), '/', monStr(5:6), '/', monStr(7:8), ' 08:00:00' ];
dn = str2datenum( dnStr );

timet = ( dn - str2datenum('1970/01/01 00:00:00') ) * 86400;
