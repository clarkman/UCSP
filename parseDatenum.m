function dn = parseDatenum( fName )

seps = strfind( fName, '_' );
date = fName(seps(1)+1:seps(2)-1);
time = fName(seps(2)+1:seps(3)-1);
datetime = [ date, ' ', time(1:2), ':', time(3:4), ':', time(5:6) ];
dn = datenum(datetime);
