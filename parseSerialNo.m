function sn = parseSerialNo( fName )

seps = strfind( fName, '_' );
sn = fName(seps(4)+1:seps(5)-1);
