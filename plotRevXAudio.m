function plotRevXAudio( exps, sens )

srcKey = makeSrcKey;

% All ...
% figure;
% plot(ar2(:,14),ar2(:,11),'Marker','o','LineStyle','none')
% xlabel('range - ft.')
% ylabel('sound pressure level - dB')
% title( 'All Casella measurements')

voltsCorr = sqrt(2);

src40 = findSrcKey( srcKey, '0.40' );
src22 = findSrcKey( srcKey, '0.22' );
srcBN = findSrcKey( srcKey, 'Balloon' );
srcSP = findSrcKey( srcKey, 'StrtrPstl' );
srcFC = findSrcKey( srcKey, 'frcrckr' );

casellas=find( exps(:,11) > 0 );
numCasellas = numel(casellas);
display(sprintf('A total of %d Casella Measurements made',numCasellas))
casExps = extractRows( exps, casellas );


% Rev4
% rev4RawInds = find( casExps(:,4)==205 & casExps(:,6)==0 & casExps(:,7)==4.5 );
% %display(sprintf('A total of %d Casella Measurements made of Rev4',numRev4s))
% rev4Exps = extractRows( casExps, rev4RawInds );
% rev4RealInds = find( rev4Exps(:,12) == src40 | rev4Exps(:,12) == src22 | rev4Exps(:,12) == srcBN | rev4Exps(:,12) == srcSP | rev4Exps(:,12) == srcFC  );
% %rev4RealInds = find( rev4Exps(:,12) == src40 | rev4Exps(:,12) == src22 );
% rev4RealExps = extractRows( rev4Exps, rev4RealInds );
% peaks = getPeaks( rev4RealExps, sens );
% display(sprintf('A total of %d Casella Measurements made of Rev4',numel(rev4RealInds)))
% dBV_Audio = 20*log10(peaks(:,1));
% %dBV_Piezo = 20*log10(peaks(:,2));
% figure;
% plot(rev4RealExps(:,11),dBV_Audio+134,'Marker','o','LineStyle','none')
% set(gca,'YLim',[100 155])
% set(gca,'XLim',[100 155])
% line(get(gca,'XLim'),[120 120],'Color','k','LineStyle',':')
% line([100 155],[100 155],'Color','k')
% xlabel('Casella Sound Level (dB SPL)')
% ylabel('Rev4 Sound Level (dB SPL)')
% title(sprintf('Rev 4 Microphone performance for %d experiments', numel(rev4RealInds)))
% setPlotSize();


% RevA
% revARawInds = find( casExps(:,3)~=-9999 & casExps(:,4)>1000 & casExps(:,4)<2000 & casExps(:,6)==0 & casExps(:,7)==4.5 );
% revAExps = extractRows( casExps, revARawInds );
% revARealInds = find( revAExps(:,12) == src40 | revAExps(:,12) == src22 | revAExps(:,12) == srcBN | revAExps(:,12) == srcSP | revAExps(:,12) == srcFC  );
% %revARealInds = find( revAExps(:,12) == src40 | revAExps(:,12) == src22 );
% revARealExps = extractRows( revAExps, revARealInds );
% peaks = getPeaks( revARealExps, sens );
% display(sprintf('A total of %d Casella Measurements made of RevA',numel(revARealInds)))
% dBV_Audio = 20*log10(peaks(:,1));
% %dBV_Piezo = 20*log10(peaks(:,2));
% figure;
% plot(revARealExps(:,11),dBV_Audio+134,'Marker','o','LineStyle','none')
% set(gca,'YLim',[100 155])
% set(gca,'XLim',[100 155])
% line(get(gca,'XLim'),[131 131],'Color','k','LineStyle',':')
% line([100 155],[100 155],'Color','k')
% xlabel('Casella Sound Level (dB SPL)')
% ylabel('RevA Sound Level (dB SPL)')
% title(sprintf('Rev 4 Microphone performance for %d experiments', numel(revARealInds)))
% setPlotSize();

% Knowles
% knowles1RawInds = find( casExps(:,4)==9997 );
% knowles2RawInds = find( casExps(:,4)==9998 );
% knowles1Exps = extractRows( casExps, knowles1RawInds );
% knowles2Exps = extractRows( casExps, knowles2RawInds );
% knowles1RealInds = find( knowles1Exps(:,12) == src40 | knowles1Exps(:,12) == src22 | knowles1Exps(:,12) == srcBN | knowles1Exps(:,12) == srcSP | knowles1Exps(:,12) == srcFC  );
% knowles2RealInds = find( knowles2Exps(:,12) == src40 | knowles2Exps(:,12) == src22 | knowles2Exps(:,12) == srcBN | knowles2Exps(:,12) == srcSP | knowles2Exps(:,12) == srcFC  );
% knowles1RealExps = extractRows( knowles1Exps, knowles1RealInds );
% knowles2RealExps = extractRows( knowles2Exps, knowles2RealInds );
% peaks1 = getAudioPeaks( knowles1RealExps, sens );
% peaks2 = getAudioPeaks( knowles2RealExps, sens );
% display(sprintf('A total of %d Casella Measurements found of Knowles',numel(peaks1(:,1))+numel(peaks2(:,1))))
% dBV_Audio1 = 20*log10(peaks1(:,1));
% dBV_Audio2 = 20*log10(peaks2(:,1));
% %dBV_Piezo = 20*log10(peaks(:,2));
% figure;
% plot(knowles1RealExps(:,11),dBV_Audio1+150,'Marker','o','LineStyle','none')
% hold on
% plot(knowles2RealExps(:,11),dBV_Audio2+150,'Marker','o','LineStyle','none')
% set(gca,'YLim',[100 155])
% set(gca,'XLim',[100 155])
% line(get(gca,'XLim'),[154 154],'Color','k','LineStyle',':')
% line([100 155],[100 155],'Color','k')
% xlabel('Casella Sound Level (dB SPL)')
% ylabel('Knowles Sound Level (dB Unknown)')
% title(sprintf('Knowles Microphone performance for %d experiments', numel(knowles1RealInds)))
% legend({'Knowles1','Knowles2'})
% setPlotSize();


% revA by room
% revARawInds = find( casExps(:,3)~=-9999 & casExps(:,4)>500 & casExps(:,4)<2000 & casExps(:,6)==0 & casExps(:,7)==4.5 );
% revAExps = extractRows( casExps, revARawInds );
% revARealInds = find( revAExps(:,12) == src40 | revAExps(:,12) == src22 | revAExps(:,12) == srcBN | revAExps(:,12) == srcSP | revAExps(:,12) == srcFC  );
% %revARealInds = find( revAExps(:,12) == src40 | revAExps(:,12) == src22 );
% revARealExps = extractRows( revAExps, revARealInds );

% cafe2Inds = find( revARealExps(:,1) == 2 );
% cafe12Inds = find( revARealExps(:,1) == 12 );
% libr9Inds = find( revARealExps(:,1) == 9 );
% libr10Inds = find( revARealExps(:,1) == 10 );

% cafe2Exps = extractRows( revARealExps, cafe2Inds );
% cafe12Exps = extractRows( revARealExps, cafe12Inds );
% libr9Exps = extractRows( revARealExps, libr9Inds );
% libr10Exps = extractRows( revARealExps, libr10Inds );

% peaksCafe2 = getPeaks( cafe2Exps, sens );
% peaksCafe12 = getPeaks( cafe12Exps, sens );
% peaksLibr9= getPeaks( libr9Exps, sens );
% peaksLibr10= getPeaks( libr10Exps, sens );

% dBV_AudioCafe2 = 20*log10(peaksCafe2(:,1));
% dBV_AudioCafe12 = 20*log10(peaksCafe12(:,1));
% dBV_AudioLibr9 = 20*log10(peaksLibr9(:,1));
% dBV_AudioLibr10 = 20*log10(peaksLibr10(:,1));

% figure;
% plot(cafe2Exps(:,11),dBV_AudioCafe2+134,'Marker','o','LineStyle','none');
% hold on;
% plot(cafe12Exps(:,11),dBV_AudioCafe12+134,'Marker','o','LineStyle','none');
% plot(libr9Exps(:,11),dBV_AudioLibr9+134,'Marker','o','LineStyle','none');
% plot(libr10Exps(:,11),dBV_AudioLibr10+134,'Marker','o','LineStyle','none');

% set(gca,'YLim',[100 155])
% set(gca,'XLim',[100 155])
% line(get(gca,'XLim'),[131 131],'Color','k','LineStyle',':')
% line([100 155],[100 155],'Color','k')
% xlabel('Casella Sound Level (dB SPL)')
% ylabel('RevA Sound Level (dB SPL)')
% title(sprintf('Rev A Microphone performance for %d experiments', numel(revARealInds)))
% setPlotSize();

% legend({'Cafe FP2','Cafe FP12','Library FP9','Library FP10'})






% Knowles
knowlesRawInds = find( casExps(:,4) > 9000 );
knowlesExps = extractRows( casExps, knowlesRawInds );
knowlesRealInds = find( knowlesExps(:,12) == src40 | knowlesExps(:,12) == src22 | knowlesExps(:,12) == srcBN | knowlesExps(:,12) == srcSP | knowlesExps(:,12) == srcFC  );
%knowlesRealInds = find( knowlesExps(:,12) == src40 | knowlesExps(:,12) == src22 );
knowlesRealExps = extractRows( knowlesExps, knowlesRealInds );

cafe2Inds = find( knowlesRealExps(:,1) == 2 );
cafe12Inds = find( knowlesRealExps(:,1) == 12 );
libr9Inds = find( knowlesRealExps(:,1) == 9 );
libr10Inds = find( knowlesRealExps(:,1) == 10 );

cafe2Exps = extractRows( knowlesRealExps, cafe2Inds );
cafe12Exps = extractRows( knowlesRealExps, cafe12Inds );
libr9Exps = extractRows( knowlesRealExps, libr9Inds );
libr10Exps = extractRows( knowlesRealExps, libr10Inds );

peaksCafe2 = getAudioPeaks( cafe2Exps, sens );
peaksCafe12 = getAudioPeaks( cafe12Exps, sens );
peaksLibr9= getAudioPeaks( libr9Exps, sens );
peaksLibr10= getAudioPeaks( libr10Exps, sens );

dBV_AudioCafe2 = 20*log10(peaksCafe2(:,1));
dBV_AudioCafe12 = 20*log10(peaksCafe12(:,1));
dBV_AudioLibr9 = 20*log10(peaksLibr9(:,1));
dBV_AudioLibr10 = 20*log10(peaksLibr10(:,1));

figure;
cof=147;
plot(cafe2Exps(:,11),dBV_AudioCafe2+cof,'Marker','o','LineStyle','none');
hold on;
plot(cafe12Exps(:,11),dBV_AudioCafe12+cof,'Marker','o','LineStyle','none');
plot(libr9Exps(:,11),dBV_AudioLibr9+cof,'Marker','o','LineStyle','none');
plot(libr10Exps(:,11),dBV_AudioLibr10+cof,'Marker','o','LineStyle','none');

set(gca,'YLim',[100 155])
set(gca,'XLim',[100 155])
line(get(gca,'XLim'),[154 154],'Color','k','LineStyle',':')
line([100 155],[100 155],'Color','k')
xlabel('Casella Sound Level (dB SPL)')
ylabel('Knowles Sound Level (dB Unknown)')
title(sprintf('Knowles Microphone performance for %d experiments', numel(knowlesRealInds)))
setPlotSize();

legend({'Cafe FP2','Cafe FP12','Library FP9','Library FP10'})



