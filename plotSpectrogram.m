function plotSpectrogram(ch,FS,fftl)

%Time Domain
td = factoryTimeData( ch, FS );
%noise = (spect1 - spect2) ./ sqrt(2)

plot(log10(spectrogram(td,fftl,0.75)))

%set(gca,'YGrid','on');
%set(gca,'XGrid','on');
%set(gca,'XLim',[axVec(1), axVec(end)]);
%set(gca,'YLim',[1, 100]);



