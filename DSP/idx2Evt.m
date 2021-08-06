function [ type, subtype ] = idx2Evt( net, evtIdx )

% Check env
[ status, rootDir ] = system( 'echo -n $QFDC_ROOT' );
if( length( rootDir ) == 0 )
    error( 'env must contain QFDC_ROOT variable' );
end
procDir = [ rootDir, '/tools/scripts' ];

% Get event table codes ...
cmd = [ procDir, '/getEventType.plx ', net, ' ', sprintf( '%d', evtIdx ) ];
[status, type] = system( cmd );
if( length( type ) == 0 )
    error( 'Event Type fetch Problem' );
end
cmd = [ procDir, '/getEventSubType.plx ', net, ' ', sprintf( '%d', evtIdx ) ];
[status, subtype] = system( cmd );
if( length( subtype ) == 0 )
    error( 'Event Subtype fetch Problem' );
end
