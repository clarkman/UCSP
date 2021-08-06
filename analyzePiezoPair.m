function props = analyzeDQVpair( starterPistol, woodBlocks, titl )
%function [ wavAudio, mp3Audio, wavPiezo, mp3Piezo ] = analyzeDQVaudio( rootName, writeDir, signal, noise )


% 96000
Fs = 24000;

% Compute time axis ...
tAx = (0:1/Fs:4-1/Fs)';
fftL = 2048*2;
mintDur = fftL*2/Fs;



hndl = figure;
plot(tAx,starterPistol(:,2));
hold on;
plot(tAx,woodBlocks(:,2));
hold off;
setPlotSize();
xlabel('Time (secs)')
ylabel('Amplitude')
set(gca,'YTick',[-1.0, -0.9, -0.8, -0.7, -0.6, -0.5, -0.4, -0.3, -0.2, -0.1, 0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 ])
set(gca,'YTickLabel',{'-1.0', '-0.9', '-0.8', '-0.7', '-0.6', '-0.5', '-0.4', '-0.3', '-0.2', '-0.1', '0', '+0.1', '+0.2', '+0.3', '+0.4', '+0.5', '+0.6', '+0.7', '+0.8', '+0.9', '+1.0' })
title( titl )
set(gca,'YLim', [-1.05, 1.05])
legend( { 'revA Starter Pistol', 'revA Wood Blocks' } )

timeBounds=[0.98, 1.05];
set(gca,'XLim',timeBounds)

