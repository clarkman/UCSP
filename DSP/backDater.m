function bd = backDater( dayMoniker, offset )
% Takes a moniker such as 20090823

rtnNum = 0;
if( isnumeric( dayMoniker ) )
    dayMoniker = sprintf( '%08d', dayMoniker );
    rtnNum = 1;
end

[ status, procDir ] = system( 'echo -n $CMN_PROC_ROOT' );
if( status ), error('$CMN_PROC_ROOT must be defined'), end;
cmd = [ procDir, '/backDater', ' ',  dayMoniker, ' ', sprintf( '%d', offset ) ];

[stat bd]=system( cmd );

bd = bd(1:end-1); % Chomp

if( rtnNum )
    bd = sscanf( bd, '%d' );
end

