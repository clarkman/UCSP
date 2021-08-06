function pass = checkEvents( inObj );

minT=str2datenum('1984/01/01 00:00:00.0000');
maxT=str2datenum('2084/01/01 00:00:00.0000');

pass = 0;

evts = inObj.events;

sz=size(evts);
for r = 1 : sz(1)
    display( [ 'Checking event: ', sprintf( '%d', r ) ] );
    if( evts(r,1) > evts(r,2) )
        error( 'Event end time precedes event start time!' );
    end
    if( evts(r,1) < minT || evts(r,1) > maxT )
        error( 'Event start time crazy!' );
    end
    if( evts(r,2) < minT || evts(r,2) > maxT )
        error( 'Event end time crazy!' );
    end
    [ n, s, c ] = inds2names( evts(r,3), evts(r,4), evts(r,5) );
    [eType,eSubtype] = idx2Evt( n, evts(r,6) );
end

pass = 1;
