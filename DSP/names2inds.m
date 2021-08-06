function [ n, s, c] = names2inds( net, sta, chn )
% Essential function for EventData

n = -1;
nets = networks;
for ith = 1 : length(nets)
    if strcmp( nets{ith}, net )
        n = ith;
        break;
    end
end
if( n == -1 )
    error( 'Network not found!!' );
end


switch n

case 1 % CalMagNet
    if strfind( sta, 'CMN' )
        sta = sta(4:6);
    end
    s = sscanf( sta, '%d' );
    if length(chn) == 8
        chn = chn(8);
    end
    c = sscanf( chn, '%d' );
    
case 2 % Berkeley
    stas = getBkStations;
    s = -1;
    for sth = 1 : length(stas)
        if( strcmp( stas{sth}, sta ) )
            s = sth;
        end
    end
    if( s == -1 )
        error( 'Berkeley Station not found!!' );
    end
    chns = getBkChannels;
    c = -1;
    for cth = 1 : length(chns)
        if( strcmp( chns{cth}, chn ) )
            c = cth;
        end
    end
    if( c == -1 )
        error( 'Berkeley Channel not found!!' );
    end

case 3 % ANSS
    s = 1;
    c = 1;
    
case 4 % DEMETER
	error( 'DEMETER not implemented yet' );

case 5 % goes
    s = sscanf( sta, '%d' );
    c = sscanf( chn, '%d' );

case 6 % Quakesat
	error( 'Quakesat not implemented yet' );

case 7 % Symres
    s = sscanf( sta, '%d' );
    c = sscanf( chn, '%d' );

case 8 % Kp
    s = 1;
    c = 1;

otherwise
	error( 'unknown' );

end
