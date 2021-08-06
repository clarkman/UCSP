function idNo = serialNo2IdNo( serialNo )

hyphs = strfind( serialNo, '-' );

numbah = serialNo(hyphs(3)+1:end);

idHex = [ '28d20562', numbah, '0000' ];

idNo = sscanf( idHex, '%lx' );
