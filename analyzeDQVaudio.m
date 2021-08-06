function segOut = analyzeDQVaudio( rootName, writeDir, segIn )
%function [ wavAudio, mp3Audio, wavPiezo, mp3Piezo ] = analyzeDQVaudio( rootName, writeDir, signal, noise )


% 96000
statedLength = 4 * 24000;

rootDir = [ '/Volumes/Funkotron2/SST/', writeDir, '/' ];
rootPath = [ rootDir, rootName ];
outNameRoot = rootName(1:end-1); % All have trailing '-' character
outDir = [ '/Volumes/Funkotron2/SST/ArtemisEval/', writeDir ];

% Load audio
try
  [ mp3Audio, Fs1 ] = audioread( [ rootPath, 'audio.mp3' ] );
  [ wavAudio, Fs2 ] = audioread( [ rootPath, 'audio.wav' ] );
  [ mp3Piezo, Fs3 ] = audioread( [ rootPath, 'piezo.mp3' ] );
  [ wavPiezo, Fs4 ] = audioread( [ rootPath, 'piezo.wav' ] );
catch
  warning( 'Problem loading audio!' )
  return
end

% Checkout load ...
if Fs1 ~= Fs2 || Fs1 ~= Fs3 || Fs1 ~= Fs4 
  warning( 'Sample rate mismatch!' )
  return
else
  Fs = Fs1;
end
sz1 = size( mp3Audio );
sz2 = size( wavAudio );
sz3 = size( mp3Piezo );
sz4 = size( wavPiezo );
if sz1(1) ~= sz2(1) || sz1(1) ~= sz3(1) || sz1(1) ~= sz4(1) 
  warning( 'Audio length mismatch!' )
  return
end
if sz1(2) ~= 1 || sz2(2) ~= 1 || sz3(2) ~= 1 || sz4(2) ~= 1
  warning( 'Multi-Channel or empty load detected!' )
  return
end
if sz1(1) ~= statedLength
  warning( 'Loaded size unexpected!' )
  return
else
  numSamps = statedLength;
end
display( 'Loaded four audio files OK' );


% Computed time axis ...
tAx = (0:1/Fs:4-1/Fs)';

fftL = 2048;
mintDur = fftL*2/Fs;
if nargin < 4
  display( [ 'Select signal & noise times for: ', rootName ] )
  plot(tAx,wavAudio);
  hold on;
  plot(tAx,wavPiezo);
  hold off;
  setPlotSize();
  inSignalSelect = 0;
  inNoiseSelect = 0;
  signal = zeros(1,2) - 1;
  noise = zeros(1,2) - 1;
  while 1

    [x, y, button] = ginput(1);

    if( button == 3 ) % cancel
      display('Exiting selection')
      break;
    end
    
    if( button == 2 ) % do it
      if ~inNoiseSelect
        noise(1) = x;
        inNoiseSelect = 1;
        display( sprintf( 'Noise starts at %0.2f', x ));
      else
        noise(2) = x;
        display( sprintf( 'Noise ends at %0.2f', x ));
      	inNoiseSelect = 0;
        if noise(1) == -1 || noise(2) == -1
          warning( 'Noise time not properly selected')
          noise = zeros(1,2) - 1;
          continue
        end
        if noise(2)-noise(1) < mintDur
          warning( 'Noise segment too short!')
          noise = zeros(1,2) - 1;
          continue
        end
        line( noise, [0 0], 'Color', [0 1 0] )
      end
    end
   
    if( button == 1 ) % report
      if ~inSignalSelect
        signal(1) = x;
        inSignalSelect = 1;
        display( sprintf( 'Signal starts at %0.2f', x ));
      else
        signal(2) = x;
        display( sprintf( 'Signal ends at %0.2f', x ));
      	inSignalSelect = 0;
        if signal(1) == -1 || signal(2) == -1
          warning( 'Signal time not properly selected')
          signal = zeros(1,2) - 1;
          continue
        end
        if signal(2)-signal(1) < mintDur
          warning( 'Signal segment too short!')
          signal = zeros(1,2) - 1;
          continue
        end
        line( signal, [0 0], 'Color', [0 0 1] )
      end
    end

  end  % While

  close('all')

end


segOut(1,1) = signal(1);
segOut(1,2) = signal(2);
segOut(1,3) = noise(1);
segOut(1,4) = noise(2);

audioTSDir = [ outDir, '/audioTimeSeries' ];
audioTSPath = [ audioTSDir, '/', outNameRoot, '.audio.jpg' ];
system( [ 'mkdir -p ', audioTSDir ] );
figure('visible','off');
plot(tAx,wavAudio)
hold on; plot(tAx,mp3Audio)
setPlotSize();
legend( { 'wav', 'mp3' } )
xlabel('secs')
set(gca,'YLim',[-1.1, 1.1])
ay=get(gca,'YLim');
ht = (ay(2)-ay(1)) * 2/3 + ay(1);
line( signal, [ht ht], 'Color', [0 0 1] )
line( noise, [ht ht], 'Color', [0 1 0] )
title( [ 'Audio overlay wav & mp3: ', outNameRoot ], 'Interpreter', 'none'  )
saveas( gcf, audioTSPath, 'jpeg' );
close('all')


piezoTSDir = [ outDir, '/piezoTimeSeries' ];
piezoTSPath = [ piezoTSDir, '/', outNameRoot, '.piezo.jpg' ];
system( [ 'mkdir -p ', piezoTSDir ] );
figure('visible','off');
plot(tAx,wavPiezo)
hold on; plot(tAx,mp3Piezo)
setPlotSize();
legend( { 'wav', 'mp3' } )
xlabel('secs')
set(gca,'YLim',[-1.1, 1.1])
ay=get(gca,'YLim');
ht = (ay(2)-ay(1)) * 2/3 + ay(1);
line( signal, [ht ht], 'Color', [0 0 1] )
line( noise, [ht ht], 'Color', [0 1 0] )
title( [ 'Piezo overlay wav & mp3: ', outNameRoot ], 'Interpreter', 'none'  )
saveas( gcf, piezoTSPath, 'jpeg' );
close('all')


audioDiffDir = [ outDir, '/audioDiff' ];
audioDiffPath = [ audioDiffDir, '/', outNameRoot, '.audiodiff.jpg' ];
system( [ 'mkdir -p ', audioDiffDir ] );
figure('visible','off');
plot(tAx,mp3Audio-wavAudio)
setPlotSize();
legend( { 'mp3 - wav' } )
xlabel('secs')
ylabel('Amplitude diff')
title( [ 'Audio signal diff mp3 - wav: ', outNameRoot ], 'Interpreter', 'none'  )
saveas( gcf, audioDiffPath, 'jpeg' );
close('all')


piezoDiffDir = [ outDir, '/piezoDiff' ];
piezoDiffPath = [ piezoDiffDir, '/', outNameRoot, '.piezodiff.jpg' ];
system( [ 'mkdir -p ', piezoDiffDir ] );
figure('visible','off');
plot(tAx,mp3Piezo-wavPiezo)
setPlotSize();
legend( { 'mp3 - wav' } )
xlabel('secs')
ylabel('Amplitude diff')
title( [ 'Piezo signal diff mp3 - wav: ', outNameRoot ], 'Interpreter', 'none'  )
saveas( gcf, piezoDiffPath, 'jpeg' );
close('all')


if 0
% sound(mp3Audio-wavAudio,)
% sound(mp3Audio,Fs)
% sound(wavAudio,Fs)
% sound(mp3Audio-wavAudio,Fs)
% sound(mp3Audio,Fs)
% sound(wavAudio,Fs)
% sound(mp3Audio,Fs)
% sound(wavAudio,Fs)
% sound(mp3Audio,Fs)
% sound(wavAudio,Fs)
% sound(mp3Piezo,Fs)
% sound(wavPiezo,Fs)
end


% Make into TD objs
mp3PiezoObj=TimeData;
mp3PiezoObj.sampleRate=Fs;
mp3PiezoObj.samples=mp3Piezo;
wavPiezoObj=TimeData;
wavPiezoObj.sampleRate=Fs;
wavPiezoObj.samples=wavPiezo;
mp3AudioObj=TimeData;
mp3AudioObj.sampleRate=Fs;
mp3AudioObj.samples=mp3Audio;
wavAudioObj=TimeData;
wavAudioObj.sampleRate=Fs;
wavAudioObj.samples=wavAudio;


% Plots PSD
audioSpectraDir = [ outDir, '/audioSpectra' ];
audioSpectraPath = [ audioSpectraDir, '/', outNameRoot, '.audioPSD.jpg' ];
system( [ 'mkdir -p ', audioSpectraDir ] );
figure('visible','off');
plot(spectrum(wavAudioObj,fftL)); set(gca,'YScale','log')
hold on; plot(spectrum(mp3AudioObj,fftL));
setPlotSize();
legend({'wav','mp3'})
title( [ 'Audio PSD mp3 & wav: ', outNameRoot ], 'Interpreter', 'none'  )
saveas( gcf, audioSpectraPath, 'jpeg' );
close('all')


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