function stdDate = sql2stdDate( sqlDate )

stdDate = sqlDate;

stdDate(5) = '/';
stdDate(8) = '/';
