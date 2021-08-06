function sqlDate = std2sqlDate( stdDate )

sqlDate = [ stdDate(7:10), '-', stdDate(1:2), '-', stdDate(4:5), stdDate(11:end) ];

