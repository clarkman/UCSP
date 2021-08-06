function JohnsonNoise( noiseBandwidth )

vals = zeros( 33, 4 );

% Boltzmann's constant
k = 1.38e-23;
% Coulomb's constant
q = 1.602e-19;

cold = (20 - 32) * (5/9) + 273;
room = (72 - 32) * (5/9) + 273;
hot  = (100- 32) * (5/9) + 273;

countr = 0;
for ith = 1 : 0.25 : 9
    countr = countr + 1;
    vals( countr, 1 ) = 10 ^ ith;
    vals( countr, 2 ) = sqrt( 4 * k * room * vals( countr, 1 ) * noiseBandwidth );
end

plot(  vals( :, 1 ),  vals( :, 2 ) )
set( gca, 'XScale', 'log' );
set( gca, 'YScale', 'log' );
xlabel('Ohms')
ylabel('Volts RMS')
title('Johnson Noise for QF-1005');
set( gca, 'XGrid', 'on' );
set( gca, 'YGrid', 'on' );
set( gca, 'XLim', [vals( 1, 1 ), vals( end, 1 )] );
set( gca, 'YLim', [vals( 1, 2 ), vals( end, 2 )]  );
a = 40/2^24;
line( [vals( 1, 1 ), vals( end, 1 )], [a a] )

countr = 0;
% Current Noise
for ith = 1 : 0.25 : 9
    countr = countr + 1;
    vals( countr, 3 ) = sqrt( 4 * k * cold * noiseBandwidth / vals( countr, 1 ) );
end

figure;
vals( :, 3 ) = vals( :, 3 ) * 1e12
plot(  vals( :, 1 ),  vals( :, 3 ))
set( gca, 'XScale', 'log' );
set( gca, 'YScale', 'log' );
ylabel('pA/rootHz')
xlabel('Ohms')
title('Johnson current Noise for QF-1005');
set( gca, 'XGrid', 'on' );
set( gca, 'YGrid', 'on' );
set( gca, 'XLim', [vals( 1, 1 ), vals( end, 1 )] );
set( gca, 'YLim', [vals( end, 3 ), vals( 1, 3 )]  );


countr = 0;
% Shot Noise
for ith = 1 : 0.25 : 9
    countr = countr + 1;
    vals( countr, 1 ) = 10 ^ (ith/4);
    vals( countr, 4 ) = sqrt( 2 * q * vals( countr, 1 ) * noiseBandwidth );
end


figure;
vals( :, 4 ) = vals( :, 4 ) * 1e12
plot(  vals( :, 1 ),  vals( :, 4 ) )
set( gca, 'XScale', 'log' );
set( gca, 'YScale', 'log' );
set( gca, 'XGrid', 'on' );
set( gca, 'YGrid', 'on' );
set( gca, 'XLim', [vals( 1, 1 ), vals( end, 1 )] );
set( gca, 'YLim', [vals( 1, 4 ), vals( end, 4 )]  );
ylabel('pA/rootHz')
xlabel('DC Amps')
title('Shot noise current for QF-1005');



