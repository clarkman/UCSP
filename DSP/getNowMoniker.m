function mon = getNowMoniker()

nowStr = datenum2str( now );
mon = sscanf( [ nowStr(7:10) nowStr(1:2) nowStr(4:5) ], '%d' );
