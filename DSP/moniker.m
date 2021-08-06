function monik = moniker( dn, doInt )

% Funny kind of floor
dnStr = datenum2str( dn );

monik = [ dnStr(7:10), dnStr(1:2), dnStr(4:5)  ];

if( nargin > 1 )
    monik = sscanf( monik, '%d' );
end
