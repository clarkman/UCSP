function plotPSD( varargin )

fftLen = 4096*4;

figure; 
for d = 1 : nargin
	td=varargin{d};

	% tdSamps=td.samples(48000:end);
	% td.samples=tdSamps;
	fd=spectrum(zeroCenter(double(td)),fftLen);
	hold on;
    plot(freqVector(fd),fd.samples);
    leg{d} = td.DataCommon.channel;
end 
set(gca,'XGrid','on'); 
set(gca,'YGrid','on'); 
set(gca,'XScale','log'); 
set(gca,'YScale','log');
set(gca,'XLim',[fd.freqResolution, td.sampleRate/2])
xlabel( [ fd.axisLabel, '   (',num2str(fd.freqResolution), ' Hz resolution)' ] );
ylabel( [ 'Volts/root(Hz)', ' (', fd.valueUnit, ')' ] );
legend(leg, 'Interpreter', 'none');

if nargin == 1
	title( makePlotTitle(td), 'Interpreter', 'none' );
	print( gcf,'-djpeg100', makeSaveName( td, 'psd.jpg' ) );
end