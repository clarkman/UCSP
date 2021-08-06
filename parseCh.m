function ch = parseCh( fName )

sepL = strfind( fName, '(' );
sepR = strfind( fName, ')' );
ch = fName(sepL(1)+1:sepR(1)-1);
