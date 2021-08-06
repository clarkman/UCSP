function monik = mysql2moniker( mysqlDateTimeStr )

monik = moniker( floor(str2datenum(sql2stdDate(mysqlDateTimeStr))), 1 );