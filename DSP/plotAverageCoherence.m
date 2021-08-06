function plotAverageCoherence()

div = 2;
stepr = 1;
offr = 0.5;

ch1 = rand(84,1)/div + 0 * stepr + offr;
ch2 = rand(84,1)/div + 1 * stepr + offr - 0.2;
ch3 = rand(84,1)/div + 2 * stepr + offr;
ch4 = rand(84,1)/div + 3 * stepr + offr;
ch5 = rand(84,1)/div + 4 * stepr + offr;
ch6 = rand(84,1)/div + 5 * stepr + offr;
ch7 = rand(84,1)/div + 6 * stepr + offr - 0.3;
ch8 = rand(84,1)/div + 7 * stepr + offr;
ch9 = rand(84,1)/div + 8 * stepr + offr;
ch10 = rand(84,1)/div + 9 * stepr + offr;

hold on;
	plot( ch1 );
hold off;
hold on;
	plot( ch2 );
hold off;
hold on;
	plot( ch3 );
hold off;
hold on;
	plot( ch4 );
hold off;
hold on;
	plot( ch5 );
hold off;
hold on;
	plot( ch6 );
hold off;
hold on;
	plot( ch7 );
hold off;
hold on;
	plot( ch8 );
hold off;
hold on;
	plot( ch9 );
hold off;
hold on;
	plot( ch10 );
hold off;

xT = 0.1
yT = 0.6;
text( xT, yT + 0, '600' );
text( xT, yT + 1, '601' );
text( xT, yT + 2, '602' );
text( xT, yT + 3, '603' );
text( xT, yT + 4, '604' );
text( xT, yT + 5, '605' );
text( xT, yT + 6, '606' );
text( xT, yT + 7, '607' );
text( xT, yT + 8, '608' );
text( xT, yT + 9, '609' );


set( gca, 'XLim', [0, 84] );
set( gca, 'YLim', [0, 10.5*stepr] );

normQ = 0.5;
line( get( gca, 'XLim' ), [ 0 + normQ, 0 + normQ ], 'LineStyle', '--', 'Color', [0 0 0] )
line( get( gca, 'XLim' ), [ 1 + normQ, 1 + normQ ] - 0.2, 'LineStyle', '--', 'Color', [0 0 0] )
line( get( gca, 'XLim' ), [ 2 + normQ, 2 + normQ ], 'LineStyle', '--', 'Color', [0 0 0] )
line( get( gca, 'XLim' ), [ 3 + normQ, 3 + normQ ], 'LineStyle', '--', 'Color', [0 0 0] )
line( get( gca, 'XLim' ), [ 4 + normQ, 4 + normQ ], 'LineStyle', '--', 'Color', [0 0 0] )
line( get( gca, 'XLim' ), [ 5 + normQ, 5 + normQ ], 'LineStyle', '--', 'Color', [0 0 0] )
line( get( gca, 'XLim' ), [ 6 + normQ, 6 + normQ ] - 0.3, 'LineStyle', '--', 'Color', [0 0 0] )
line( get( gca, 'XLim' ), [ 7 + normQ, 7 + normQ ], 'LineStyle', '--', 'Color', [0 0 0] )
line( get( gca, 'XLim' ), [ 8 + normQ, 8 + normQ ], 'LineStyle', '--', 'Color', [0 0 0] )
line( get( gca, 'XLim' ), [ 9 + normQ, 9 + normQ ], 'LineStyle', '--', 'Color', [0 0 0] )


set( gca, 'XTick', [0, 21, 42, 63, 84] );
set( gca, 'XTickLabel', { '12AM', '6', '12PM', '6', '12AM' } );
set( gca, 'YTickLabel', {} );

title( 'Daily Coherence Plot for 2008/09/24' );