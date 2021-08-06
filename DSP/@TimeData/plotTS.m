function plotTS( varargin )

fftLen = 4096;

s = inputname(1);

td=varargin{1};

figure; 
plot(td); 

title( makePlotTitle(td), 'Interpreter', 'none' );

print( gcf,'-djpeg100', makeSaveName( td, 'ts.jpg' ) );
set(gca,'YLim',[-1, 1]);
print( gcf,'-djpeg100', makeSaveName( td, 'fs.ts.jpg' ) );
