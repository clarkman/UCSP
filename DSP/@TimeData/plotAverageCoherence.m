function plotAverageCoherence()

div = 2;
stepr = 1;

ch1 = rand(84,1)/div + 0 * stepr;
ch2 = rand(84,1)/div + 1 * stepr;
ch3 = rand(84,1)/div + 2 * stepr;
ch4 = rand(84,1)/div + 3 * stepr;
ch5 = rand(84,1)/div + 4 * stepr;
ch6 = rand(84,1)/div + 5 * stepr;
ch7 = rand(84,1)/div + 6 * stepr;
ch8 = rand(84,1)/div + 7 * stepr;
ch9 = rand(84,1)/div + 8 * stepr;
ch10 = rand(84,1)/div + 0 * stepr;

hold on;
	plot( ch1 );
hold off;

set( gca, 'YLim', [-stepr, 11*stepr] )