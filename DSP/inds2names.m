function [ n, s, c ] = inds2names( net, sta, chn )
% Essential function for EventData

nets = networks;
if net < 0 || net > length(nets)
    error( 'Specified net out of range!');
end
n=nets{net};


switch net

case 1 % CalMagNet
    s=sprintf( '%03d', sta );
    c=sprintf( 'CHANNEL%01d', chn );
    
case 2 % Berkeley
    stas = getBkStations;
    if sta < 0 || sta > length(stas)
        error( 'Specified sta out of range!');
    end
    s=stas{sta};
    chns = getBkChannels;
    if chn < 0 || chn > length(chns)
        error( 'Specified sta out of range!');
    end
    c=chns{chn};

case 3 % ANSS
    s = '1';
    c = '1';
    
case 4 % DEMETER
	error( 'DEMETER not implemented yet' );

case 5 % goes
    s = sprintf( sta, '%d' );
    c = sprintf( chn, '%d' );

case 6 % Quakesat
	error( 'Quakesat not implemented yet' );

case 7 % Symres
    s = '1';
    c = '1';

case 8 % Kp
    s = '1';
    c = '1';

otherwise
	error( 'unknown' );

end
