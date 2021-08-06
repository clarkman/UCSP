FS = 44100;
closer = 0;

loadem = 0;
if loadem
  [controlSweepLin, FS]=audioread('controlSweepLin.wav');
  [controlSweepMic, FS]=audioread('controlSweepMic.wav');
  [controlToneLin, FS]=audioread('controlToneLin.wav');
  [controlToneMic, FS]=audioread('controlToneMic.wav');

  [pond20150519_1405, FS]=audioread('pond20150519_1405.wav');
  [pond20150519_1409, FS]=audioread('pond20150519_1409.wav');
  [pond20150519_1412, FS]=audioread('pond20150519_1412.wav');
  [pond20150519_1414, FS]=audioread('pond20150519_1414.wav');
  [pond20150519_1418, FS]=audioread('pond20150519_1418.wav');
  [pond20150519_1420, FS]=audioread('pond20150519_1420.wav');
  [pond20150519_1422, FS]=audioread('pond20150519_1422.wav');
  [pond20150519_1424, FS]=audioread('pond20150519_1424.wav');
end

chopem = 0;
if chopem
    
  quietA1 = pond20150519_1405(1:705069,1);
  quietA2 = pond20150519_1405(1:705069,2);
  quietB1 = pond20150519_1405(1072229:1699884,1);
  quietB2 = pond20150519_1405(1072229:1699884,2);
  bkgrnd1 = pond20150519_1405(2529953:3635944,1);
  bkgrnd2 = pond20150519_1405(2529953:3635944,2);
  
  rockin1 = pond20150519_1405(841820:1190734,1);
  rockin2 = pond20150519_1405(841820:1190734,2);
  
  hz1kTone1 = pond20150519_1409(608210:696892,1);
  hz1kTone2 = pond20150519_1409(608210:696892,2);
  
  ctrSweepA1 = pond20150519_1418(472123:1762198,1);
  ctrSweepA2 = pond20150519_1418(472123:1762198,2);
  
  ctrSweepB1 = pond20150519_1420(355400:1458016,1);
  ctrSweepB2 = pond20150519_1420(355400:1458016,2);
  
  leftSweep1 = pond20150519_1422(639665:2999306,1);
  leftSweep2 = pond20150519_1422(639665:2999306,2);
  
  truck1 = pond20150519_1422(52419:673387,1);
  truck2 = pond20150519_1422(52419:673387,2);
  
  rightSweep1 = pond20150519_1422(598754:1829755,1);
  rightSweep2 = pond20150519_1422(598754:1829755,2);
  
end


clearem = 0;
if clearem
  clear pond*
end


plotts = 0;
if plotts
  plotStereoTimeSeries(quietA1,quietA2,FS,1e-2,'Quiet Background 1')
    print( gcf,'-djpeg100', '-noui', 'quietA.jpg' );
  plotStereoTimeSeries(quietB1,quietB2,FS,1e-2,'Quiet Background 2')
    print( gcf,'-djpeg100', '-noui', 'quietB.jpg' );
  plotStereoTimeSeries(bkgrnd1,bkgrnd2,FS,5e-2,'background')
    print( gcf,'-djpeg100', '-noui', 'background.jpg' );
  plotSpectrogram(quietA1(:,1),FS,1e-2,'Quiet Background 1')
    print( gcf,'-djpeg100', '-noui', 'quietA.jpg' );
  if closer, close('all'), end;
end

plot1000Hz = 0;
if plot1000Hz
    tdTone1 = TimeData; tdTone1.sampleRate = FS;
    tdTone1.samples = hz1kTone1;
    tdTone2 = TimeData; tdTone2.sampleRate = FS;
    tdTone2.samples = hz1kTone2;
    spect1 = spectrum(tdTone1,4096);
    spect2 = spectrum(tdTone2,4096);
    axVec = freqVector(spect1);
    figure; plot(axVec,spect1.samples,'Color',[0.8 0 0]);
    hold on; plot(axVec,spect2.samples,'Color',[0 0.8 0]);
    set(gca,'XScale','log');
    set(gca,'YScale','log');
    set(gca,'XGrid','on');
    set(gca,'YGrid','on');
    set(gca,'XLim',[20,FS/2]);
    xlabel( [ spect1.axisLabel, '   (',num2str(spect1.freqResolution), ' Hz resolution)' ] );
    ylabel( [ spect1.valueType, ' (', spect1.valueUnit, ')' ] );
    title('Spectrum of 1000 Hz signal generator');
    print( gcf,'-djpeg100', '-noui', 'plot1000Hz.jpg' );
    %saveas( gcf, outputImageName, 'jpg' );
    if closer, close('all'), end;
    clear tdTone1 tdTone2 spect1 spect2 axVec
end

plotSNR = 1;
if plotSNR
  % Controls
  plotStereoSpectrumSNR(controlSweepMic(:,1),controlSweepMic(:,2),FS)
    title('Control segment, 20-20,000 Hz Sweep, Mic Inputs, SNR plot')
    print( gcf,'-djpeg100', '-noui', 'controlSweepMicSNR.jpg' );
  plotStereoSpectrumSNR(controlToneMic(:,1),controlToneMic(:,2),FS)
    set(gca,'YLim',[1, 10000]);
    set(gca,'YTickLabels',{'1:1','10:1','100:1','1k:1','10k:1'});
    title('Control segment, 1,000 Hz Tone, Mic Inputs, SNR plot')
    print( gcf,'-djpeg100', '-noui', 'controlToneMicSNR.jpg' );

  % Ponds
  plotStereoSpectrumSNR(quietA1,quietA2,FS)
    title('First quiet segment, SNR plot')
    print( gcf,'-djpeg100', '-noui', 'quietSNR_A.jpg' );
  plotStereoSpectrumSNR(quietB1,quietB2,FS)
    title('Second quiet segment, SNR plot')
    print( gcf,'-djpeg100', '-noui', 'quietSNR_B.jpg' );
  plotStereoSpectrumSNR(bkgrnd1,bkgrnd2,FS)
    title('Waterfall segment, SNR plot')
    print( gcf,'-djpeg100', '-noui', 'bkgrndSNR.jpg' );
  if closer, close('all'), end;
end

plotPSD = 1;
if plotPSD
  % Controls
  plotStereoSpectrumPSD(controlSweepMic(:,1),controlSweepMic(:,2),FS);
    set(gca,'YLim',[1e-12 1e-2]);
    title('Control segment, 20-20,000 Hz Sweep, Mic Inputs, PSD plot')
    print( gcf,'-djpeg100', '-noui', 'controlSweepMicPSD.jpg' );
  plotStereoSpectrumPSD(controlToneMic(:,1),controlToneMic(:,2),FS)
    set(gca,'YLim',[1e-12 1e-2]);
    title('Control segment, 1,000 Hz Tone, Mic Inputs, PSD plot')
    print( gcf,'-djpeg100', '-noui', 'controlToneMicPSD.jpg' );

  % Ponds
  plotStereoSpectrumPSD(quietA1,quietA2,FS)
    title('First quiet segment, PSD plot')
    print( gcf,'-djpeg100', '-noui', 'quietPSD_A.jpg' );
  plotStereoSpectrumPSD(quietB1,quietB2,FS)
    title('Second quiet segment, PSD plot')
    print( gcf,'-djpeg100', '-noui', 'quietPSD_B.jpg' );
  plotStereoSpectrumPSD(bkgrnd1,bkgrnd2,FS)
    title('Waterfall segment, SNR plot')
    print( gcf,'-djpeg100', '-noui', 'bkgrndPSD.jpg' );
    
  if closer, close('all'), end;
end


plotBP = 1;
if plotBP
  
  if 0
    ctrfreq = 1000;
    passbandwidth = 50;
    filtlen=511;
    
    lSw1 = factoryTimeData( leftSweep1, FS );    
    lSw2 = factoryTimeData( leftSweep2, FS );
    rSw1 = factoryTimeData( rightSweep1, FS );    
    rSw2 = factoryTimeData( rightSweep2, FS ); 
    
    lSw1BP = bandpass(lSw1, ctrfreq, passbandwidth, filtlen)
    lSw2BP = bandpass(lSw2, ctrfreq, passbandwidth, filtlen)
    rSw1BP = bandpass(rSw1, ctrfreq, passbandwidth, filtlen)
    rSw2BP = bandpass(rSw2, ctrfreq, passbandwidth, filtlen)
    lSw1BP = lSw1BP.samples;
    lSw2BP = lSw2BP.samples;
    rSw1BP = rSw1BP.samples;
    rSw2BP = rSw2BP.samples;
  else
    bP = bandp;
    lSw1BP=filter(bP,leftSweep1);
    lSw2BP=filter(bP,leftSweep2);
    rSw1BP=filter(bP,rightSweep1);
    rSw2BP=filter(bP,rightSweep2);
  end
  plotStereoTimeSeries(lSw1BP,lSw2BP,FS,0,'Arrival Times - Left')
  plotStereoTimeSeries(rSw1BP,rSw2BP,FS,0,'Arrival Times - Right')
    

  if closer, close('all'), end;
end


clear plot1000Hz chopem loadem clearem closer plotSNR plotPSD