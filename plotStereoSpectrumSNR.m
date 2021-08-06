function plotStereoSpectrumPSD(ch1,ch2,FS,fftl)

if nargin < 4
    fftl = 4096;
end

%Time Domain
td1 = factoryTimeData( ch1, FS );
td2 = factoryTimeData( ch2, FS );
diff = zeroCenter(td1)-zeroCenter(td2);
diff = diff.samples ./ sqrt(2);
tdN = factoryTimeData( diff, FS );

spect1 = spectrum(td1,fftl);
spect2 = spectrum(td2,fftl);
spectN = spectrum(tdN,fftl);

%noise = (spect1 - spect2) ./ sqrt(2)

axVec = freqVector(spect1);
figure;
spect1 = spect1 ./ spectN;
spect2 = spect2 ./ spectN;
hold on;
plot(axVec,spect1.samples,'Color',[0.8 0 0]);
plot(axVec,spect2.samples,'Color',[0 0 0.8]);

set(gca,'XScale','log');
set(gca,'YScale','log');
set(gca,'YGrid','on');
set(gca,'XGrid','on');
set(gca,'XLim',[axVec(1), axVec(end)]);
set(gca,'YLim',[1, 100]);
set(gca,'YTickLabels',{'1:1','10:1','100:1'});

xlabel( [ spect1.axisLabel, '   (',num2str(spect1.freqResolution), ' Hz resolution)' ] );
ylabel( 'Signal : Noise Ratio (SNR)' );


legend({'ch1','ch2'})



