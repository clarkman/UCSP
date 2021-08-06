function [ audioProps, peizoProps ] = annotatePlot( tAx, seg, Fs, signal, noise )

sigSamps = find( tAx >= signal(1) & tAx < signal(2) );
noiseSamps = find( tAx >= noise(1) & tAx < noise(2) );

signalAudio = extractRows( seg(:,1), sigSamps );
signalPiezo = extractRows( seg(:,2), sigSamps );

noiseAudio = extractRows( seg(:,1), noiseSamps );
noisePiezo = extractRows( seg(:,2), noiseSamps );

sigDur = signal(2) - signal(1);

upClipAudio = find( signalAudio > 0.996 );
dnClipAudio = find( signalAudio < -0.996 );
if isempty(upClipAudio) || isempty(dnClipAudio)
  pctAudioClipped = 0;
else
  firstClipAudio = tAx(min( upClipAudio(1), dnClipAudio(1) ));
  finalClipAudio = tAx(max( upClipAudio(end), dnClipAudio(end) ));
  clipDurAudio = finalClipAudio - firstClipAudio;
  pctAudioClipped = clipDurAudio/sigDur
end
upClipPiezo = find( signalPiezo > 0.996 );
dnClipPiezo = find( signalPiezo < -0.996 );
if isempty(upClipPiezo) || isempty(dnClipPiezo)
  pctPiezoClipped = 0;
else
  firstClipPiezo = tAx(min( upClipPiezo(1), dnClipPiezo(1) ));
  finalClipPiezo = tAx(max( upClipPiezo(end), dnClipPiezo(end) ));
  clipDurPiezo = finalClipPiezo - firstClipPiezo + 1/Fs;
  pctPiezoClipped = clipDurPiezo/sigDur
end

rmsAudioNoise = rms(noiseAudio)
rmsPiezoNoise = rms(noisePiezo)

rmsAudioSignal = rms(signalAudio)
rmsPiezoSignal = rms(signalPiezo)

hTxt = 2.0;
text( hTxt, 0.7, sprintf('Audio: pct clipped = %0.2f, signalRMS = %0.6f, noiseRMS = %0.6f', pctAudioClipped, rmsAudioSignal, rmsAudioNoise ) )
text( hTxt, 0.64, sprintf('Piezo: pct clipped = %0.2f, signalRMS = %0.6f, noiseRMS = %0.6f', pctPiezoClipped, rmsPiezoSignal, rmsPiezoNoise ) )

audioProps = [ pctAudioClipped, rmsAudioSignal, rmsAudioNoise ];
peizoProps = [ pctPiezoClipped, rmsPiezoSignal, rmsPiezoNoise ];