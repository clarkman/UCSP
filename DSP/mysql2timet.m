function timet = mysql2timet( mysqlDateTimeStr )

dn = str2datenum(sql2stdDate(mysqlDateTimeStr));

timet = ( dn - str2datenum('1970/01/01 00:00:00') ) * 86400;
