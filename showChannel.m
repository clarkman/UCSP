function showChannel( fName )


%ipAddr = '192.168.1.7';
ipAddr = '10.10.102.70';
usr = 'cuz';
ljPath = '/home/cuz/src/afusion/trunk/labjack/'
ljExec = [ ljPath, 'labjackBurst' ];
ljOutFile = 'a.dat';
collLen = '400000'

% Clean prior ...
cmd = [ 'ssh ', usr, '@', ipAddr, ' rm -f /home/cuz/', ljOutFile ] 
system( cmd ) 

cmd = [ 'ssh ', usr, '@', ipAddr, ' ', ljExec, ' ', collLen ] 
system( cmd ) 

cmd = [ 'scp ', usr, '@', ipAddr, ':/home/cuz/', ljOutFile, ' ', fName ] 
system( cmd )

sampRate = 50000;
fftL = 2048;
adcRange = 20;

tdObj=readData( fName, sampRate );
plot(tdObj);
ylabel('Volts');

uVect = unique(tdObj.samples);
bitsRes = uVect(end)-uVect(end-1);
LSB = adcRange / bitsRes;
bits = round(log2(LSB));
title( sprintf( '%s, SR= %d, res = %fV, bits=%d, mean=%f, std=%f', fName, sampRate, bitsRes, bits, mean(tdObj), std(tdObj) ) );
orient portrait
print( gcf,'-djpeg100', [ fName, '.ts.jpg' ] );


[outBins, histBinWidth] = histogram(tdObj,1000);
xlabel('Volts');
ylabel('Qty');
title( sprintf( '%s, Sample Rate = %d, bitRes = %f Volts, res=%d', fName, sampRate, bitsRes, bits ) )
print( gcf,'-djpeg100', [ fName, '.hist.jpg' ] );


figure;
fdObj = spectrum(zeroCenter(tdObj),fftL);
freq=freqVector(fdObj);
fdObj.valueType = 'Volts^2/Hz'
plot(fdObj);
set(gca,'XScale','log')
set(gca,'YScale','log')
set(gca,'XLim',[freq(1),freq(end)])
title( sprintf( '%s, Sample Rate = %d, bitRes = %f Volts, res=%d', fName, sampRate, bitsRes, bits ) );
orient portrait
set(gca,'YLim',[min(fdObj.samples),max(fdObj.samples)])
print( gcf,'-djpeg100', [ fName, '.fft.zoomed.jpg' ] );
set(gca,'YLim',[1e-12,1e-4])
print( gcf,'-djpeg100', [ fName, '.fft.jpg' ] );


plot(log10(spectrogram(zeroCenter(tdObj),fftL,0.75)));
orient portrait
print( gcf,'-djpeg100', [ fName, '.sgram.jpg' ] );

