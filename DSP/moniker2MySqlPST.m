function dn = moniker2MySqlPST( moniker )

% Funny kind of floor
monStr = sprintf( '%08d', moniker );
dn = [ monStr(1:4), '-', monStr(5:6), '-', monStr(7:8), ' 08:00:00' ];

