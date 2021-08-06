function plotStereoSpectrumPSD(ch1,ch2,FS)

%Time Domain
if isa( ch1, 'TimeData')
  td1 = ch1;
else
  td1 = factoryTimeData( ch1, FS );
end

if isa( ch2, 'TimeData')
  td2 = ch2;
else
  td2 = factoryTimeData( ch2, FS );
end

diff = zeroCenter(td1)-zeroCenter(td2);
diff = diff.samples ./ sqrt(2);
tdN = factoryTimeData( diff, FS );

spect1 = spectrum(td1,4096);
spect2 = spectrum(td2,4096);
spectN = spectrum(tdN,4096);

%noise = (spect1 - spect2) ./ sqrt(2)

axVec = freqVector(spect1);
figure;
plot(axVec,spectN.samples,'Color',[0.65 0.65 0.65]);
hold on;
plot(axVec,spect1.samples,'Color',[0.6 0 0.6]);
plot(axVec,spect2.samples,'Color',[0 0.5 0.0]);

set(gca,'XScale','log');
set(gca,'YScale','log');
set(gca,'YGrid','on');
set(gca,'XGrid','on');
set(gca,'XLim',[axVec(1), axVec(end)]);
%set(gca,'YLim',[1e-14, 1e-7]);

xlabel( [ spect1.axisLabel, '   (',num2str(spect1.freqResolution), ' Hz resolution)' ] );
ylabel( [ spect1.valueType, ' (', spect1.valueUnit, ')' ] );

legend({'bkgnd','ch1','ch2'})



