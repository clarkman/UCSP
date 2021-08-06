function dn = spoolNametoDN( fileName )

dashes = strfind(fileName,'-');
dots = strfind(fileName,'.');

timeStr = fileName(dashes(1)+1:dots(1)-2);
ds = strfind(timeStr,'-');
clkTime = timeStr(ds(3)+1:end);
sqlTime = [ timeStr(1:ds(3)-1), ' ', clkTime(1:2), ':', clkTime(3:4), ':', clkTime(5:6) ];
dn = datenum( sqlTime );
