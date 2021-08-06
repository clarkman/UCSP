function datnum = mysql2datenum( mysqlDateTimeStr )

datnum = str2datenum(sql2stdDate(mysqlDateTimeStr));