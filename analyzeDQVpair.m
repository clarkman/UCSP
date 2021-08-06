function props = analyzeDQVpair( rev4Segs, revASegs, props )
%function [ wavAudio, mp3Audio, wavPiezo, mp3Piezo ] = analyzeDQVaudio( rootName, writeDir, signal, noise )


% 96000
Fs = 24000;
secsLength = 4;
signalLength = secsLength * Fs;

sz1 = size( rev4Segs(:,1) );
sz2 = size( rev4Segs(:,2) );
sz3 = size( revASegs(:,1) );
sz4 = size( revASegs(:,2) );
if sz1(1) ~= sz2(1) || sz1(1) ~= sz3(1) || sz1(1) ~= sz4(1) 
  warning( 'Audio length mismatch!' )
  return
end
if sz1(2) ~= 1 || sz2(2) ~= 1 || sz3(2) ~= 1 || sz4(2) ~= 1
  warning( 'Multi-Channel or empty load detected!' )
  return
end
if sz1(1) ~= signalLength
  warning( 'Loaded size unexpected!' )
  return
else
  numSamps = signalLength;
end
display( sprintf( 'Four audio signals of %d samples each, OK', numSamps ) );


% Compute time axis ...
tAx = (0:1/Fs:4-1/Fs)';
fftL = 256;
mintDur = fftL*2/Fs;

vCorr = 2.83/2;

doTS=0;
if doTS

% hndl = plotAudioPiezo( tAx, rev4Segs, makePlotTitle( inputname(1) ) );
% [ signalR4, noiseR4 ] = grabSignalAndNoise(mintDur);
% [ audioPropsR4, piezoPropsR4 ] = annotatePlot( tAx, rev4Segs, Fs, signalR4, noiseR4 )
% writeAndClosePlot( hndl, 'TimeSeries', inputname(1), 'ts', 'jpg' );

% hndl = plotAudioPiezo( tAx, revASegs, makePlotTitle( inputname(2) ) )
% [ signalRA, noiseRA ] = grabSignalAndNoise(mintDur);
% [ audioPropsRA, piezoPropsRA ] = annotatePlot( tAx, revASegs, Fs, signalRA, noiseRA )
% writeAndClosePlot( hndl, 'TimeSeries', inputname(2), 'ts', 'jpg' );


hndl = figure;
plot(tAx,rev4Segs(:,2).*vCorr);
hold on;
plot(tAx,revASegs(:,2).*vCorr);
hold off;
setPlotSize();
xlabel('Time (secs)')
ylabel('Volts')
set(gca,'YTick',[-1.0, -0.9, -0.8, -0.7, -0.6, -0.5, -0.4, -0.3, -0.2, -0.1, 0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 ])
set(gca,'YTickLabel',{'-1.0', '-0.9', '-0.8', '-0.7', '-0.6', '-0.5', '-0.4', '-0.3', '-0.2', '-0.1', '0', '+0.1', '+0.2', '+0.3', '+0.4', '+0.5', '+0.6', '+0.7', '+0.8', '+0.9', '+1.0' })
title( titl )
set(gca,'YLim', [-1.05, 1.05])
legend( { 'rev4 piezo', 'revA piezo' } )

timeBounds=[0.98, 1.2];
set(gca,'XLim',timeBounds)



return
% 1. signal(1) Rev4
% 2. signal(2) Rev4
% 3. noise(1) Rev4
% 4. noise(2) Rev4
% 5. pctClip Rev4 Audio
% 6. sigRMS Rev4 Audio
% 7. noiseRMS Rev4 Audio
% 8. pctClip Rev4 Piezo
% 9. sigRMS Rev4 Piezo
% 10. noiseRMS Rev4 Piezo
% 11. signal(1) RevA
% 12. signal(2) RevA
% 13. noise(1) RevA
% 14. noise(2) RevA
% 15. pctClip RevA Audio
% 16. sigRMS RevA Audio
% 17. noiseRMS RevA Audio
% 18. pctClip RevA Piezo
% 19. sigRMS RevA Piezo
% 20. noiseRMS RevA Piezo


props = [ signalR4, noiseR4, audioPropsR4, piezoPropsR4, signalRA, noiseRA, audioPropsRA, piezoPropsRA ];

end

%Trim signals
ch=2;

% Make into TD objs
audioSignalR4 = TimeData;
audioSignalR4.sampleRate=Fs;
audioSignalR4.samples=rev4Segs(:,ch).*vCorr;
audioSignalR4.valueType='Volts';
audioSignalR4 = segment( audioSignalR4, props(1), props(2)-0.2875 );
audioNoiseR4 = TimeData;
audioNoiseR4.sampleRate=Fs;
audioNoiseR4.samples=rev4Segs(:,ch).*vCorr;
audioNoiseR4.valueType='Volts';
audioNoiseR4 = segment( audioNoiseR4, props(3), props(4) );

audioSignalRA = TimeData;
audioSignalRA.sampleRate=Fs;
audioSignalRA.samples=revASegs(:,ch).*vCorr;
audioSignalRA.valueType='Volts';
audioSignalRA = segment( audioSignalRA, props(11), props(12)-0.2875 );
audioNoiseRA = TimeData;
audioNoiseRA.sampleRate=Fs;
audioNoiseRA.samples=revASegs(:,ch).*vCorr;
audioNoiseRA.valueType='Volts';
audioNoiseRA = segment( audioNoiseRA, props(13), props(14) );


% Plots PSD
figure;
plot(spectrum(audioSignalR4,fftL)); set(gca,'YScale','log')
hold on; plot(spectrum(audioNoiseR4,fftL));
plot(spectrum(audioSignalRA,fftL));
plot(spectrum(audioNoiseRA,fftL));
setPlotSize();
legend({'rev4 Signal','rev4 Noise','revA Signal','revA Noise'})
set(gca,'XScale','log')
set(gca,'XLim',[80 12500])
return

% Plots PSD
piezoSpectraDir = [ outDir, '/piezoSpectra' ];
piezoSpectraPath = [ piezoSpectraDir, '/', outNameRoot, '.piezoPSD.jpg' ];
system( [ 'mkdir -p ', piezoSpectraDir ] );
figure('visible','off');
plot(spectrum(wavPiezoObj,fftL)); set(gca,'YScale','log')
hold on; plot(spectrum(mp3PiezoObj,fftL));
setPlotSize();
legend({'wav','mp3'})
title( [ 'Audio PSD mp3 & wav: ', outNameRoot ], 'Interpreter', 'none'  )
saveas( gcf, piezoSpectraPath, 'jpeg' );
close('all')


% Trim to signal & noise segments
wavAudioSignalObj = segment( wavAudioObj, signal(1), signal(2) ); 
wavAudioNoiseObj = segment( wavAudioObj, noise(1), noise(2) );
mp3AudioSignalObj = segment( mp3AudioObj, signal(1), signal(2) ); 
mp3AudioNoiseObj = segment( mp3AudioObj, noise(1), noise(2) );
wavPiezoSignalObj = segment( wavPiezoObj, signal(1), signal(2) ); 
wavPiezoNoiseObj = segment( wavPiezoObj, noise(1), noise(2) );
mp3PiezoSignalObj = segment( mp3PiezoObj, signal(1), signal(2) ); 
mp3PiezoNoiseObj = segment( mp3PiezoObj, noise(1), noise(2) );


audioSpectraSNDir = [ outDir, '/audioSpectraSN' ];
audioSpectraSNPath = [ audioSpectraSNDir, '/', outNameRoot, '.audioSN.jpg' ];
system( [ 'mkdir -p ', audioSpectraSNDir ] );
figure('visible','off');
plot(spectrum(wavAudioSignalObj,fftL));
hold on; 
plot(spectrum(mp3AudioSignalObj,fftL));
plot(spectrum(wavAudioNoiseObj,fftL));
plot(spectrum(mp3AudioNoiseObj,fftL));
hold off;
orient portrait;
set(gca,'YScale','log');
setPlotSize();
legend({'wavAudioSignal','mp3AudioSignal','wavAudioNoise','mp3AudioNoise'})
title('Audio noise & quiet spectra compressed vs. uncompressed');
saveas( gcf, audioSpectraSNPath, 'jpeg' );
close('all')


piezoSpectraSNDir = [ outDir, '/piezoSpectraSN' ];
piezoSpectraSNPath = [ piezoSpectraSNDir, '/', outNameRoot, '.piezoSN.jpg' ];
system( [ 'mkdir -p ', piezoSpectraSNDir ] );
figure('visible','off');
plot(spectrum(wavPiezoSignalObj,fftL));
hold on; 
plot(spectrum(mp3PiezoSignalObj,fftL));
plot(spectrum(wavPiezoNoiseObj,fftL));
plot(spectrum(mp3PiezoNoiseObj,fftL));
hold off;
orient portrait;
set(gca,'YScale','log');
setPlotSize();
legend({'wavPiezoSignal','mp3PiezoSignal','wavPiezoNoise','mp3PiezoNoise'})
title('Piezo noise & quiet spectra compressed vs. uncompressed');
saveas( gcf, piezoSpectraSNPath, 'jpeg' );
close('all')


wavAudioSNR=spectrum(wavAudioSignalObj,2048)./spectrum(wavAudioNoiseObj,2048);
mp3AudioSNR=spectrum(mp3AudioSignalObj,2048)./spectrum(mp3AudioNoiseObj,2048);
wavPiezoSNR=spectrum(wavPiezoSignalObj,2048)./spectrum(wavPiezoNoiseObj,2048);
mp3PiezoSNR=spectrum(mp3PiezoSignalObj,2048)./spectrum(mp3PiezoNoiseObj,2048);



audioSNRDir = [ outDir, '/audioSNR' ];
audioSNRPath = [ audioSNRDir, '/', outNameRoot, '.audioSNR.jpg' ];
system( [ 'mkdir -p ', audioSNRDir ] );
figure('visible','off');
plot(mp3AudioSNR);
hold on; 
  plot(wavAudioSNR);
hold off;
orient portrait;
set(gca,'YScale','log');
setPlotSize();
legend({'mp3AudioSNR','wavAudioSNR'})
title('Audio Signal -to- noise ratio, compressed vs. uncompressed');
saveas( gcf, audioSNRPath, 'jpeg' );
close('all')


piezoSNRDir = [ outDir, '/piezoSNR' ];
piezoSNRPath = [ piezoSNRDir, '/', outNameRoot, '.piezoSNR.jpg' ];
system( [ 'mkdir -p ', piezoSNRDir ] );
figure('visible','off');
plot(mp3PiezoSNR);
hold on; 
  plot(wavPiezoSNR);
hold off;
orient portrait;
set(gca,'YScale','log');
setPlotSize();
legend({'mp3PiezoSNR','wavPiezoSNR'})
title('Piezo Signal -to- noise ratio, compressed vs. uncompressed');
saveas( gcf, piezoSNRPath, 'jpeg' );
close('all')


audioDiff=wavAudioSNR-mp3AudioSNR;
piezoDiff=wavPiezoSNR-mp3PiezoSNR;


audioRatio=wavAudioSNR./mp3AudioSNR
piezoRatio=wavPiezoSNR./mp3PiezoSNR

snrRatioDir = [ outDir, '/snrRatio' ];
snrRatioPath = [ snrRatioDir, '/', outNameRoot, '.snrRatio.jpg' ];
system( [ 'mkdir -p ', snrRatioDir ] );
figure('visible','off');
plot(audioRatio);
hold on; 
  plot(piezoRatio);
hold off;
orient portrait;
set(gca,'YScale','log');
setPlotSize();
legend({'audioRatio','piezoRatio'})
title('Wav -to- mp3 ratio, compressed vs. uncompressed');
saveas( gcf, snrRatioPath, 'jpeg' );
close('all')


return
%close('all')



% title('Piezo - zoomed')
% plot(spectrum(wavAudioObj,2048)); set(gca,'YScale','log')
% close('all')
% plot(spectrum(wavAudioObj,2048)); set(gca,'YScale','log')
% hold on; plot(spectrum(mp3AudioObj,2048)); set(gca,'YScale','log')
% legend({'wav','mp3'})
% title('Audio spectrum compressed vs. uncompressed')
% figure; plot(spectrum(wavPiezoObj,2048)); set(gca,'YScale','log')
% hold on; plot(spectrum(mp3PiezoObj,2048)); set(gca,'YScale','log')
% legend({'wav','mp3'})
% title('Piezo spectrum compressed vs. uncompressed')
% sy=get(gca,'YLim')
% format long
% sy
% set(gca,'YLim',[1.0e-12,1.0e-3])
% set(gca,'YLim',[1.0e-15,1.0e-6])
% set(gca,'YLim',[1.0e-12,1.0e-3])
% plot(spectrum(wavAudioObj,2048)); set(gca,'YScale','log')
% hold on; plot(spectrum(mp3PiezoObj,2048)); set(gca,'YScale','log')
% close('all')
% plot(spectrum(wavAudioObj,2048)); set(gca,'YScale','log')
% hold on; plot(spectrum(mp3AudioObj,2048)); set(gca,'YScale','log')
% hold on; plot(spectrum(wavPiezoObj,2048)); set(gca,'YScale','log')
% hold on; plot(spectrum(mp3PiezoObj,2048)); set(gca,'YScale','log')
% legend({'wavAudio','mp3Audio','wavPiezo','mp3Piezo'})
% title('Audio and Piezo spectra compressed vs. uncompressed')
% set(gca,'YLim',[1.0e-15,1.0e-3])
% plot(wavAudioObj)
% close('all')
% plot(wavAudioObj)
% ax=get(gca,'XLim')
% figure; plot(segment(wavAudioObj,ax(1),ax(2))
% figure; plot(segment(wavAudioObj,ax(1),ax(2)))
% figure; plot(segment(wavAudioObj,ax))
% figure; plot(segTime(wavAudioObj,ax(1),ax(2)))
% wavAudioObj
% figure; plot(segment(wavAudioObj,ax(1),ax(2)))
% plot(spectrum(segment(wavAudioObj,ax(1),ax(2)),2048)); set(gca,'YScale','log')
% close('all')
% plot(wavAudioObj)
% as=get(gca,'XLim')
% plot(spectrum(segment(wavAudioObj,as(1),as(2)),2048)); set(gca,'YScale','log')
% close('all')
% plot(spectrum(segment(wavAudioObj,as(1),as(2)),2048)); set(gca,'YScale','log')
% hold on; plot(spectrum(segment(wavAudioObj,ax(1),ax(2)),2048));
% plot(spectrum(segment(mp3AudioObj,as(1),as(2)),2048)); set(gca,'YScale','log')
% hold on; plot(spectrum(segment(mp3AudioObj,ax(1),ax(2)),2048));
% legend({'wavAudioShot','wavAudioBkgnd','mp3AudioShot','mp3AudioBkgnd'})
% title('Audio shot vs. quiet spectra compressed & uncompressed')
% figure; plot(spectrum(segment(wavPiezoObj,as(1),as(2)),2048)); set(gca,'YScale','log')
% hold on; plot(spectrum(segment(wavPiezoObj,ax(1),ax(2)),2048));
% plot(spectrum(segment(mp3PiezoObj,as(1),as(2)),2048));
% plot(spectrum(segment(mp3PiezoObj,ax(1),ax(2)),2048));
% legend({'wavPiezoShot','wavPiezoBkgnd','mp3PiezoShot','mp3PiezoBkgnd'})
% title('P{iezo shot vs. quiet spectra compressed & uncompressed')
% title('Piezo shot vs. quiet spectra compressed & uncompressed')
% plot(spectrum(segment(wavAudioObj,ax(1),ax(2)),2048))./spectrum(segment(wavAudioObj,as(1),as(2)),2048)); set(gca,'YScale','log')
% plot(spectrum(segment(wavAudioObj,ax(1),ax(2)),2048)./spectrum(segment(wavAudioObj,as(1),as(2)),2048)); set(gca,'YScale','log')
% close('all')
% plot(spectrum(segment(wavAudioObj,ax(1),ax(2)),2048)./spectrum(segment(wavAudioObj,as(1),as(2)),2048)); set(gca,'YScale','log')
% plot(spectrum(segment(wavAudioObj,as(1),as(2)),2048)./spectrum(segment(wavAudioObj,ax(1),ax(2)),2048)); set(gca,'YScale','log')
% hold on; plot(spectrum(segment(mp3AudioObj,as(1),as(2)),2048)./spectrum(segment(mp3AudioObj,ax(1),ax(2)),2048)); set(gca,'YScale','log')
% legend({'wavSNR','mp3SNR'})
% legend({'wav SNR','mp3 SNR'})
% title('Signal-to-Noise Ratio for audio signal (shot vs. quiet)')
% close('all')
% plot(spectrum(segment(wavPiezoObj,as(1),as(2)),2048)./spectrum(segment(wavPiezoObj,ax(1),ax(2)),2048)); set(gca,'YScale','log')
% hold on; plot(spectrum(segment(mp3PiezoObj,as(1),as(2)),2048)./spectrum(segment(mp3PiezoObj,ax(1),ax(2)),2048)); set(gca,'YScale','log')
% legend({'wav SNR','mp3 SNR'})
% title('Signal-to-Noise Ratio for piezo signal (shot vs. quiet)')
% wavAudioSNR=spectrum(segment(wavAudioObj,ax(1),ax(2)),2048)./spectrum(segment(wavAudioObj,as(1),as(2)),2048);
% mp3AudioSNR=spectrum(segment(mp3AudioObj,ax(1),ax(2)),2048)./spectrum(segment(mp3AudioObj,as(1),as(2)),2048);
% wavPiezoSNR=spectrum(segment(wavPiezoObj,ax(1),ax(2)),2048)./spectrum(segment(wavPiezoObj,as(1),as(2)),2048);
% mp3PiezoSNR=spectrum(segment(mp3PiezoObj,ax(1),ax(2)),2048)./spectrum(segment(mp3PiezoObj,as(1),as(2)),2048);
% figure;plot(wavAudioSNR-mp3AudioSNR);
% audioDiff=wavAudioSNR-mp3AudioSNR;
% piezoDiff=wavPiezoSNR-mp3PiezoSNR;
% fAx=0:11.78:12000
% fAx=0:11.78:12000;
% mp3PiezoSNR
% fAx=0:11.781:12000;
% fAx=0:11.779:12000;
% fAx=0:11.775:12000;
% fAx=0:11.770:12000;
% fAx=0:11.760:12000;
% fAx=0:11.730:12000;
% plot( fAx, audioDiff.samples )
% audioDiff
% fAx=0:11.720:12000;
% fAx=0:11.710:12000;
% plot( fAx, audioDiff.samples )
% close('all')
% plot( fAx, audioDiff.samples )
% plot( fAx, wavAudioSNR.samples )
% close('all')
% plot( fAx, wavAudioSNR.samples )
% wavAudioSNR=spectrum(segment(wavAudioObj,as(1),as(2)),2048)./spectrum(segment(wavAudioObj,ax(1),ax(2)),2048);
% mp3AudioSNR=spectrum(segment(mp3AudioObj,as(1),as(2)),2048)./spectrum(segment(mp3AudioObj,ax(1),ax(2)),2048);
% wavPiezoSNR=spectrum(segment(wavPiezoObj,as(1),as(2)),2048)./spectrum(segment(wavPiezoObj,ax(1),ax(2)),2048);
% mp3PiezoSNR=spectrum(segment(mp3PiezoObj,as(1),as(2)),2048)./spectrum(segment(mp3PiezoObj,ax(1),ax(2)),2048);
% audioDiff=wavAudioSNR-mp3AudioSNR;
% piezoDiff=wavPiezoSNR-mp3PiezoSNR;
% figure;plot(audioDiff);
% figure;plot(audioDiff,piezoDiff);
% figure;plot(audioDiff);
% hold on; plot(piezoDiff)
% close('all')
% plot(piezoDiff)
% figure;plot(audioDiff);set(gca,'YScale','log')
% figure;plot(audioDiff);
% hold on; plot(piezoDiff)
% legend({'audio wavSNR-mp3SNR','piezo wavSNR-mp3SNR'})
% title('Signal - to - Noise ratio plot')