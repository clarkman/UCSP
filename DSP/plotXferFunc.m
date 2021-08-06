function xferArray = plotXferFunc( baseObj, xferArray )


figure;
subplot(2,1,1);

szz = size( xferArray );

hold on;
    plot(xferArray(:,1),xferArray(:,2));    
hold off;
title( [ 'Transfer Function of ' sprintf( '%d', szz(1) )  ' points for ' baseObj.network ' ' baseObj.station ' ' baseObj.channel] );
set(gca, 'XLim', [0 16] );
set(gca, 'XScale', 'log' );
set(gca, 'YScale', 'log' );
set(gca, 'XGrid', 'on' );
set(gca, 'YGrid', 'on' );
ylabel('Gain');
subplot(2,1,2);

hold on;
    plot(xferArray(:,1),xferArray(:,3));
hold off;
set(gca, 'XLim', [0 16] );
set(gca, 'XScale', 'log' );
set(gca, 'XGrid', 'on' );
set(gca, 'YGrid', 'on' );
ylabel('Phase');
xlabel('Hz');
