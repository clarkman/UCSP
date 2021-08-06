function plotPiezoScatter( ar2, sens )

cCol = 11;
rangeCol = 14;

srcKey = makeSrcKey;

%voltsCorr = 2 * sqrt(2) / 2 
voltsCorr = sqrt(2);

micSat = 20*log10(0.355*sqrt(2))+94+46;

% All ...
% figure;
inds = find( ar2(:,11) > 0 & ar2(:,3) > 0 );
numCasellas = numel(inds)
casellas = extractRows( ar2, inds );
peaks = getPeaks( casellas, sens );

figure;
logit = 1;
if logit
  dBV_Audio = 20*log10(peaks(:,1)*voltsCorr)+94+44;
  dBV_Piezo = 20*log10(peaks(:,2)*voltsCorr)+94+44;
  plot(casellas(:,11),dBV_Audio,'Marker','o','LineStyle','none')
  hold on;
  plot(casellas(:,11),dBV_Piezo,'Marker','o','LineStyle','none')
  xlabel('Casella amplitudes - dB SPL')
  ylabel('Artemis peak amplitudes - dB SPL')
  set(gca,'XLim',[100 160])
  set(gca,'YLim',[100 160])
  plot(100:160,100:160)
  line([micSat,micSat],get(gca,'XLim'))
else
  % Peaks are linear, casella vals are log, so
  casellaLin = undB(casellas(:,11));
  plot(casellaLin,peaks(:,1),'Marker','o','LineStyle','none')
  hold on;
  plot(casellaLin,peaks(:,2),'Marker','d','LineStyle','none')
  xlabel('Casella amplitudes - lin')
  ylabel('Artemis peak amplitude - wav file units')
end
legend({'audio','piezo'});
title( 'Signal peaks vs Casella')

return
%set(gca,'YLim',[0 1]);

% plot(ar2(:,14),ar2(:,11),'Marker','o','LineStyle','none')
% xlabel('range - ft.')
% ylabel('sound pressure level - dB')
% title( 'All Casella measurements')


% Caliber compare linear ...
srcNum = findSrcKey( srcKey, '0.40' )
inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum & ar2(:,5)>0 );
ar40 = extractRows( ar2, inds );
peaks = getPeaks( ar40, sens );
figure;
plot(ar40(:,14),peaks(:,1),'Marker','o','LineStyle','none')
hold on;
plot(ar40(:,14),peaks(:,2),'Marker','d','LineStyle','none')
legend({'audio','piezo'});
xlabel('range - ft.')
ylabel('amplitude - volts')
title( 'Signal peaks from .40 Caliber')
set(gca,'YLim',[0 1]);

srcNum = findSrcKey( srcKey, '0.22' )
inds = find( ar2(:,11)>0 & ar2(:,12)==srcNum & ar2(:,5)>0 );
ar22 = extractRows( ar2, inds );
peaks = getPeaks( ar22, sens );
figure;
plot(ar22(:,14),peaks(:,1),'Marker','o','LineStyle','none')
hold on;
plot(ar22(:,14),peaks(:,2),'Marker','d','LineStyle','none')
legend({'audio','piezo'});
xlabel('range - ft.')
ylabel('amplitude - volts')
title( 'Signal peaks from .22 Caliber');
set(gca,'YLim',[0 1]);

return
plot(arSt(:,14),10.^(arSt(:,11)./20),'Marker','+','LineStyle','none')
plot(arFc(:,14),10.^(arFc(:,11)./20),'Marker','*','LineStyle','none')
legend({'.40 cal','.22 cal','Starter','Firecracker'})
xlabel('range - ft.')
ylabel('sound pressure level - Lin')
title( 'Comparing Casella measurements re. Caliber')
set(gca,'YScale','log')
set(gca,'XGrid','on')
set(gca,'YGrid','on')
set(gca,'YLim',[1e5 1e8])


% Room compare ...
% inds = find( ar40(:,1)==1 ); % Principal's office
% arFp1 = extractRows( ar40, inds );
% fp1Ampl = 20*log10(10.^(arFp1(:,11)/20)./arFp1(:,14));
% inds = find( ar40(:,1)==2 ); % Principal's office
% arFp2 = extractRows( ar40, inds );
% fp2Ampl = 20*log10(10.^(arFp2(:,11)/20)./arFp2(:,14));
% inds = find( ar40(:,1)==8 ); % Principal's office
% arFp8 = extractRows( ar40, inds );
% fp8Ampl = 20*log10(10.^(arFp8(:,11)/20)./arFp8(:,14));
% inds = find( ar40(:,1)==9 ); % Principal's office
% arFp9 = extractRows( ar40, inds );
% fp9Ampl = 20*log10(10.^(arFp9(:,11)/20)./arFp9(:,14));

% figure;
% plot(arFp1(:,14),fp1Ampl,'Marker','o','LineStyle','none')
% hold on;
% plot(arFp2(:,14),fp2Ampl,'Marker','d','LineStyle','none')
% plot(arFp8(:,14),fp8Ampl,'Marker','+','LineStyle','none')
% plot(arFp9(:,14),fp9Ampl,'Marker','*','LineStyle','none')
% legend({'Admin Office sm/quiet','Cafeteria lg/loud','Atrium sm/loud','Library lg/quiet'})
% xlabel('range - ft.')
% ylabel('sound pressure level - dB')
% title( 'Comparing Casella measurements re. Room')


