function plotSource( exps, sens )

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

casellas=find( exps(:,11) > 0 & exps(:,4) < 9000 & exps(:,3) ~= -9999 );
numCasellas = numel(casellas);
display(sprintf('A total of %d Casella Measurements made',numCasellas))
casExps = extractRows( exps, casellas );

% 40 cal
cal40Inds = find( casExps(:,12) == src40 );
numCal40s = numel(cal40Inds);
display(sprintf('A total of %d .40 caliber Measurements made',numCal40s))
cal40Exps = extractRows( casExps, cal40Inds );

% peaks = getPeaks( cal40Exps, sens );
% dBV_Audio = 20*log10(peaks(:,1))+134;
% dBV_Piezo = 20*log10(peaks(:,2))+134;

figure;
plot(cal40Exps(:,14),cal40Exps(:,11),'Marker','o','LineStyle','none')

title(sprintf('%d .40 caliber experiments', numCal40s))
setPlotSize();

