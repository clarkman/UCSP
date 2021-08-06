function tNum = parseTestNum( dirName )

sepL = strfind( dirName, '(test' );
sepR = strfind( dirName, ')' );
dirName(sepL(1)+5:sepR(1)-1)
tNum = sscanf( dirName(sepL(1)+5:sepR(1)-1),'%d');
