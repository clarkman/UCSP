function plotRevXPiezo( exps, sens, fps, bldgNames, bldgNumbers, roomNames, sigDir )

% Guardian at the gate ...
switch sigDir
  case 'audio'
    col = 1;
    % All sensors have audio ...
    casellas=find( exps(:,11) > 0 & exps(:,3) ~= -9999 );
  case 'piezo'
    col = 2;
    % Only Rev4 & RevA sensors have piezo ...
    casellas=find( exps(:,11) > 0 & exps(:,4) < 9000 & exps(:,3) ~= -9999 );
  case 'accel'
    col = 3;
    % Only RevA sensors have piezo ...  (XXX Clark, not sure about 500, but it works for NMHS)
    casellas=find( exps(:,11) > 0 & exps(:,4) < 9000 & exps(:,4) > 500 & exps(:,3) ~= -9999 );
  otherwise
    error( [ 'Unknown signal type: ', sigDir ] )
end 

% Path OK
rootDir= '/Volumes/Funkotron2/SST/Artemis/NewarkHSLiveFire2/Analysis/casDir/';
outBaseDir = [ rootDir, sigDir ];

% Select data and names of base experiment set.
numCasellas = numel(casellas);
display(sprintf('A total of %d Casella %s Measurements made',numCasellas,sigDir))
casExps = extractRows( exps, casellas );
casBldgNames = extractCellRows( bldgNames, casellas );
casBldgNumbers = extractCellRows( bldgNumbers, casellas );
casRoomNames = extractCellRows( roomNames, casellas );


% Build source types
srcKey = makeSrcKey;

% Here we futz with sources
% outDir = outBaseDir;
src40 = findSrcKey( srcKey, '0.40' );
src22 = findSrcKey( srcKey, '0.22' );
srcBN = findSrcKey( srcKey, 'Balloon' );
srcSP = findSrcKey( srcKey, 'StrtrPstl' );
srcFC = findSrcKey( srcKey, 'frcrckr' );
% piezoRawInds=find( exps(:,12) == src40 | exps(:,12) == src22 | exps(:,12) == srcBN | exps(:,12) == srcSP | exps(:,12) == srcFC );


% srcs = [ 3, 4, 5, 6, 13 ];
% numSrcs = numel(srcs);
% leg={};
% for s = 1 : numSrcs
%   src = srcs(s);
%   srcInds = find( casExps(:,12) == src & (casExps(:,4)==784 | casExps(:,4)==1067 | casExps(:,4)==1062 | casExps(:,4)==1030 | casExps(:,4)==1042 | casExps(:,4)==1054 | casExps(:,4)==1022 | casExps(:,4)==1034 ) )
%   srcExps = extractRows( casExps, srcInds );
%   [ peaks ] = getPiezoPeaks( srcExps, sens )
%   hold on;
%   plot(srcExps(:,11),20.*log10(peaks),'LineStyle','none','Marker','o')
%   leg{s} = srcKey(src).name;
% end
% legend(leg);
% setPlotSize();
% xlabel('Casella sound level - dB SPL');
% ylabel('Piezo level - dB Unknown');
% title('Overall Piezo Result')
% return


% Single source
srcName = '0.40';
outDir = [ outBaseDir, srcName, '/' ];
srcIdx = findSrcKey( srcKey, srcName );
piezoRawInds = find( casExps(:,12) == srcIdx ); 
piezoExps = extractRows( casExps, piezoRawInds );
piezoBldgNames = extractCellRows( casBldgNames, piezoRawInds );
piezoBldgNumbers = extractCellRows( casBldgNumbers, piezoRawInds );
piezoRoomNames = extractCellRows( casRoomNames, piezoRawInds );


% Make (or remake) output directory
[ stat, msg ] = system(['mkdir -p ', outDir]);
if stat
  error(['Problem making output directory: ',outDir])
end
%return


% Plot by firing position
% plotType = 'By Dir'
% for fp = 1 : 12
%   fpInds = find( piezoExps(:,1) == fp & (piezoExps(:,4)==784 | piezoExps(:,4)==1067 | piezoExps(:,4)==1062 | piezoExps(:,4)==1030 | piezoExps(:,4)==1042 | piezoExps(:,4)==1054 | piezoExps(:,4)==1022 | piezoExps(:,4)==1034 ) );
%   if isempty(fpInds)
%     continue
%   end
%   fpExps = extractRows( piezoExps, fpInds );
%   fpBldgNames = extractCellRows( piezoBldgNames, fpInds );
%   fpBldgNumbers = extractCellRows( piezoBldgNumbers, fpInds );
%   fpRoomNames = extractCellRows( piezoRoomNames, fpInds );
%   fDirs = unique(fpExps(:,2));
%   legr = {};
%   figure;
%   for fDir = 1 : numel(fDirs)
%   	fDirInds = find( fpExps(:,2) == fDirs(fDir) );
%   	fDirExps = extractRows( fpExps, fDirInds );
%     fpDirBldgNames = extractCellRows( fpBldgNames, fDirInds );
%     fpDirBldgNumbers = extractCellRows( fpBldgNumbers, fDirInds );
%     fpDirRoomNames = extractCellRows( fpRoomNames, fDirInds );
%   	hold on;
%     typer = 'peak';
%     switch typer
%       case 'rms'
%        fDirPeaks = getRMSPeaks( fDirExps, sens );
%         yLabl = 'piezo RMS amplitude - dB Unknown';
%         yLims = [70 110];
%       case 'lp'
%         yLabl = 'piezo lo-pass amplitude - dB Unknown';
%         fDirPeaks = getLopassPeaks( fDirExps, sens );
%         yLims = [90 125];
%       case 'peak'
%         yLabl = 'piezo peak amplitude - dB Unknown';
%         fDirPeaks = getPeaks( fDirExps, sens );
%         yLims = [80 130];
%       otherwise
%         error( [ 'Unknown plot type: ', typer ] )
%     end 
% %    plot(fDirExps(:,11),fDirPeaks(:,2).*fDirExps(:,14),'Marker','o','LineStyle','none');
% %    plot(fDirExps(:,11),fDirPeaks(:,2),'Marker','o','LineStyle','none');
%     % casLin = undB(fDirExps(:,11));
%     % plot(casLin,fDirPeaks(:,2),'Marker','o','LineStyle','none');
%     yVals = 20*log10(fDirPeaks(:,2))+134;
%     plot(fDirExps(:,11),yVals,'Marker','o','LineStyle','none');
%     legr{fDir} = sprintf('Direction = %d', fDirs(fDir));
%   end
%   legend(legr,'Location','Northwest');
%   setPlotSize();
%   xLims = [105 155];
%   if( min(fDirExps(:,11)) < xLims(1) || max(fDirExps(:,11)) > xLims(2) )
%     error(sprintf('Plot will clip on X: %g/%g - %g/%g',min(fDirExps(:,11)),xLims(1),max(fDirExps(:,11)),xLims(2)) )
%   end
%   set(gca,'XLim',xLims);
%   if( min(yVals) < yLims(1) || max(yVals) > yLims(2) )
%     error( sprintf('Plot will clip on Y: %g/%g - %g/%g',min(min(yVals),yLims(1)), max(max(yVals),yLims(2))) )
%     error('Plot will clip on Y!!')
%   end
%   set(gca,'YLim',yLims);
%   xlabel('Casella sound level - dB SPL');
%   ylabel( yLabl );
%   begDN = min(fpExps(:,10));
%   finDN = max(fpExps(:,10));
%   title([ sprintf('%s, %s, %s, FP=%d, ', sigDir, srcName, plotType, fp), fpDirBldgNames{1}, ' ', fpDirBldgNumbers{1}, ' ', fpDirRoomNames{1}, ' from: ', datestr(begDN), ' to: ', datestr(finDN)])
%   piezoName = [ sprintf('FP_%d_',fp), fpDirBldgNames{1}, '_', fpDirBldgNumbers{1}, '_', fpDirRoomNames{1}, '-', sigDir '.dir.', srcName, '.', typer, '.jpg' ];
%   print( gcf,'-djpeg100', '-noui', [ outDir, piezoName ] );
%   close('all')
% end
% return

% plotType = 'By Sensor'
% for fp = 1 : 12
%   fpInds = find( piezoExps(:,1) == fp & (piezoExps(:,4)==784 | piezoExps(:,4)==1067 | piezoExps(:,4)==1062 | piezoExps(:,4)==1030 | piezoExps(:,4)==1042 | piezoExps(:,4)==1054 | piezoExps(:,4)==1022 | piezoExps(:,4)==1034 )  );
%   if isempty(fpInds)
%     continue
%   end
%   fpExps = extractRows( piezoExps, fpInds );
%   fpBldgNames = extractCellRows( piezoBldgNames, fpInds );
%   fpBldgNumbers = extractCellRows( piezoBldgNumbers, fpInds );
%   fpRoomNames = extractCellRows( piezoRoomNames, fpInds );
%   fSensors = unique(fpExps(:,4));
%   legr = {};
%   figure;
%   for fSensor = 1 : numel(fSensors)
%   	fSensorInds = find( fpExps(:,4) == fSensors(fSensor) );
%   	fSensorExps = extractRows( fpExps, fSensorInds );
%     fpSensorBldgNames = extractCellRows( fpBldgNames, fSensorInds );
%     fpSensorBldgNumbers = extractCellRows( fpBldgNumbers, fSensorInds );
%     fpSensorRoomNames = extractCellRows( fpRoomNames, fSensorInds );
%     typer = 'peak';
%     switch typer
%       case 'rms'
%        fSensorPeaks = getRMSPeaks( fSensorExps, sens );
%         yLabl = 'piezo RMS amplitude';
%       case 'lp'
%         yLabl = 'piezo lo-pass amplitude';
%         fSensorPeaks = getLopassPeaks( fSensorExps, sens );
%       case 'peak'
%         yLabl = 'piezo peak amplitude';
%         fSensorPeaks = getPeaks( fSensorExps, sens );
%       otherwise
%         error( [ 'Unknown plot type: ', typer ] )
%     end 
%   	hold on;
%     casLin = undB(fSensorExps(:,11));
%     [ P, S ] = polyfit(casLin,fSensorPeaks(:,2),1);
%     cXX = [min(casLin),max(casLin)];
%     [ pVals, delta ] = polyval(P,cXX,S);
%     cIdx = get(gca,'ColorOrderIndex');
%     plot(casLin,fSensorPeaks(:,2),'Marker','o','LineStyle','none');
%     legr{fSensor*2-1} = sprintf('Sensor = %d - gain=%g/%gdB', fSensors(fSensor), fSensorExps(1,8), fSensorExps(1,9) );
%     colrs = get(gca,'ColorOrder');
%     line(cXX,pVals,'LineStyle',':','Color',colrs(cIdx,:))
%     legr{fSensor*2} = sprintf('Fit: %g% ', delta(2)/pVals(2));
%   end
%   legend(legr);
%   setPlotSize();
%   xlabel('Casella sound level - linear');
%   ylabel( yLabl );
%   begDN = min(fpExps(:,10));
%   finDN = max(fpExps(:,10));
%   title([ sprintf('%s, %s, %s, FP=%d, ', sigDir, srcName, plotType, fp), fpSensorBldgNames{1}, ' ', fpSensorBldgNumbers{1}, ' ', fpSensorRoomNames{1}, ' from: ', datestr(begDN), ' to: ', datestr(finDN)])
%   piezoName = [ fpSensorBldgNames{1}, '-', sprintf('FP_%d_',fp), '_', fpSensorBldgNumbers{1}, '_', fpSensorRoomNames{1}, '-', sigDir '.dir.', srcName, '.', typer, '.jpg' ];
%   %piezoName = [ sprintf('FP_%d_',fp), fpSensorBldgNames{1}, '_', fpSensorBldgNumbers{1}, '_', fpSensorRoomNames{1}, '-piezo.40.', typer, '.jpg' ];

%   print( gcf,'-djpeg100', '-noui', [ outDir, piezoName ] );
%   % while 1
%   %   [x, y, button] = ginput(1);

%   %   if( button == 3 ) % done
%   %     break;
%   %   end
%   % end
%   close('all')
% end





revAInds = find( casExps(:,4) > 500 & casExps(:,12) < 9000  );
revAExps = extractRows( casExps, revAInds );

revARealInds = find( revAExps(:,12) == src40 | revAExps(:,12) == src22 | revAExps(:,12) == srcBN | revAExps(:,12) == srcSP | revAExps(:,12) == srcFC  );
%revARealInds = find( revAExps(:,12) == src40 | revAExps(:,12) == src22 );
revARealExps = extractRows( revAExps, revARealInds );

cafe2Inds = find( revARealExps(:,1) == 2 );
cafe12Inds = find( revARealExps(:,1) == 12 );
libr9Inds = find( revARealExps(:,1) == 9 );
libr10Inds = find( revARealExps(:,1) == 10 );

cafe2Exps = extractRows( revARealExps, cafe2Inds );
cafe12Exps = extractRows( revARealExps, cafe12Inds );
libr9Exps = extractRows( revARealExps, libr9Inds );
libr10Exps = extractRows( revARealExps, libr10Inds );

peaksCafe2 = getPeaks( cafe2Exps, sens );
peaksCafe12 = getPeaks( cafe12Exps, sens );
peaksLibr9= getPeaks( libr9Exps, sens );
peaksLibr10= getPeaks( libr10Exps, sens );

dBV_PiezoCafe2 = 20*log10(peaksCafe2(:,2));
dBV_PiezoCafe12 = 20*log10(peaksCafe12(:,2));
dBV_PiezoLibr9 = 20*log10(peaksLibr9(:,2));
dBV_PiezoLibr10 = 20*log10(peaksLibr10(:,2));

figure;
corr = 155;
plot(cafe2Exps(:,11),dBV_PiezoCafe2+corr,'Marker','o','LineStyle','none');
hold on;
plot(cafe12Exps(:,11),dBV_PiezoCafe12+corr,'Marker','o','LineStyle','none');
plot(libr9Exps(:,11),dBV_PiezoLibr9+corr,'Marker','o','LineStyle','none');
plot(libr10Exps(:,11),dBV_PiezoLibr10+corr,'Marker','o','LineStyle','none');

lo = 105;
hi = 155;
set(gca,'YLim',[lo hi])
set(gca,'XLim',[lo hi])
line([lo hi],[lo hi],'Color','k')
xlabel('Casella Sound Level (dB SPL)')
ylabel('Piezo Sound Level (dB Unknown)')
title(sprintf('Piezo performance for %d experiments', numel(revARealInds)))
setPlotSize();

legend({'Cafe FP2','Cafe FP12','Library FP9','Library FP10'})

piezoName = [ 'piezoLibraryCafeteria.jpg' ];
print( gcf,'-djpeg100', '-noui', [ outBaseDir, piezoName ] );



return



% Piezo all
piezoRealInds = find( casExps(:,12) == src40 | casExps(:,12) == src22 | casExps(:,12) == srcBN | casExps(:,12) == srcSP | casExps(:,12) == srcFC  );
numRealPiezos = numel(piezoRealInds);
display(sprintf('A total of %d Real Measurements made',numRealPiezos))
piezoRealExps = extractRows( casExps, piezoRealInds );

piezo18Inds = find( piezoRealExps(:,8)==13 & piezoRealExps(:,9)==5 );
piezo4_5Inds = find( piezoRealExps(:,8)==0 & piezoRealExps(:,9)==4.5 );
piezo5Inds = find( piezoRealExps(:,8)==0 & piezoRealExps(:,9)==5 );
%numel(piezo18Inds) + numel(piezo4_5Inds) + numel(piezo5Inds) 

piezo18Exps = extractRows( casExps, piezo18Inds );
piezo4_5Exps = extractRows( casExps, piezo4_5Inds );
piezo5Exps = extractRows( casExps, piezo5Inds );

peaks18 = getPeaks( piezo18Exps, sens );
dBV_Piezo18 = 20*log10(peaks18(:,2));
peaks4_5 = getPeaks( piezo4_5Exps, sens );
dBV_Piezo4_5 = 20*log10(peaks4_5(:,2));
peaks5 = getPeaks( piezo5Exps, sens );
dBV_Piezo5 = 20*log10(peaks5(:,2));

figure;
corr = 160;
plot(piezo18Exps(:,11),dBV_Piezo18+corr,'Marker','o','LineStyle','none')
hold on;
plot(piezo4_5Exps(:,11),dBV_Piezo4_5+corr,'Marker','o','LineStyle','none')
plot(piezo5Exps(:,11),dBV_Piezo5+corr,'Marker','o','LineStyle','none')

lo = 100;
hi = 160;
set(gca,'YLim',[lo hi])
set(gca,'XLim',[lo hi])
line([lo hi],[lo hi],'Color','k')
xlabel('Casella Sound Level (dB SPL)')
ylabel('Piezo Sound Level (dB Unknown)')
title(sprintf('Piezo performance for %d experiments', numel(piezoRealInds)))
legend({'18dB','4.5dB','5dB'})
setPlotSize();
piezoName = [ 'piezoByGain.jpg' ];
print( gcf,'-djpeg100', '-noui', [ outBaseDir, piezoName ] );


% Piezo by rev4 vs revA
piezoRealInds = find( casExps(:,12) == src40 | casExps(:,12) == src22 | casExps(:,12) == srcBN | casExps(:,12) == srcSP | casExps(:,12) == srcFC  );
numRealPiezos = numel(piezoRealInds);
display(sprintf('A total of %d Real Measurements made',numRealPiezos))
piezoRealExps = extractRows( casExps, piezoRealInds );

piezoRev4Inds = find( piezoRealExps(:,4) == 205 );
piezoRevAInds = find( piezoRealExps(:,4) > 500 );
%numel(piezo18Inds) + numel(piezo4_5Inds) + numel(piezo5Inds) 

piezoRev4Exps = extractRows( casExps, piezoRev4Inds );
piezoRevAExps = extractRows( casExps, piezoRevAInds );

peaksRev4 = getPeaks( piezoRev4Exps, sens );
dBV_PiezoRev4 = 20*log10(peaksRev4(:,2));
peaksRevA = getPeaks( piezoRevAExps, sens );
dBV_PiezoRevA = 20*log10(peaksRevA(:,2));

figure;
corr = 155;
plot(piezoRev4Exps(:,11),dBV_PiezoRev4+corr,'Marker','o','LineStyle','none')
hold on;
plot(piezoRevAExps(:,11),dBV_PiezoRevA+corr,'Marker','o','LineStyle','none')

lo = 100;
hi = 160;
set(gca,'YLim',[lo hi])
set(gca,'XLim',[lo hi])
line([lo hi],[lo hi],'Color','k')
xlabel('Casella Sound Level (dB SPL)')
ylabel('Piezo Sound Level (dB Unknown)')
title(sprintf('Piezo performance for %d experiments', numel(piezoRealInds)))
legend({'Rev4','RevA'})
setPlotSize();
piezoName = [ 'piezoBySensor.jpg' ];
print( gcf,'-djpeg100', '-noui', [ outBaseDir, piezoName ] );


revARawInds = find( casExps(:,3)~=-9999 & casExps(:,4)<9000 );
revAExps = extractRows( casExps, revARawInds );
revARealInds = find( revAExps(:,12) == src40 | revAExps(:,12) == src22 | revAExps(:,12) == srcBN | revAExps(:,12) == srcSP | revAExps(:,12) == srcFC  );
%revARealInds = find( revAExps(:,12) == src40 | revAExps(:,12) == src22 );
revARealExps = extractRows( revAExps, revARealInds );

cafe2Inds = find( revARealExps(:,1) == 2 );
cafe12Inds = find( revARealExps(:,1) == 12 );
libr9Inds = find( revARealExps(:,1) == 9 );
libr10Inds = find( revARealExps(:,1) == 10 );

cafe2Exps = extractRows( revARealExps, cafe2Inds );
cafe12Exps = extractRows( revARealExps, cafe12Inds );
libr9Exps = extractRows( revARealExps, libr9Inds );
libr10Exps = extractRows( revARealExps, libr10Inds );

peaksCafe2 = getPeaks( cafe2Exps, sens );
peaksCafe12 = getPeaks( cafe12Exps, sens );
peaksLibr9= getPeaks( libr9Exps, sens );
peaksLibr10= getPeaks( libr10Exps, sens );

dBV_PiezoCafe2 = 20*log10(peaksCafe2(:,2));
dBV_PiezoCafe12 = 20*log10(peaksCafe12(:,2));
dBV_PiezoLibr9 = 20*log10(peaksLibr9(:,2));
dBV_PiezoLibr10 = 20*log10(peaksLibr10(:,2));

figure;
corr = 155;
plot(cafe2Exps(:,11),dBV_PiezoCafe2+corr,'Marker','o','LineStyle','none');
hold on;
plot(cafe12Exps(:,11),dBV_PiezoCafe12+corr,'Marker','o','LineStyle','none');
plot(libr9Exps(:,11),dBV_PiezoLibr9+corr,'Marker','o','LineStyle','none');
plot(libr10Exps(:,11),dBV_PiezoLibr10+corr,'Marker','o','LineStyle','none');

lo = 105;
hi = 155;
set(gca,'YLim',[lo hi])
set(gca,'XLim',[lo hi])
line([lo hi],[lo hi],'Color','k')
xlabel('Casella Sound Level (dB SPL)')
ylabel('Piezo Sound Level (dB Unknown)')
title(sprintf('Piezo performance for %d experiments', numel(revARealInds)))
setPlotSize();

legend({'Cafe FP2','Cafe FP12','Library FP9','Library FP10'})

piezoName = [ 'piezoLibraryCafeteria.jpg' ];
print( gcf,'-djpeg100', '-noui', [ outBaseDir, piezoName ] );



return





piezoLibraryIndsPos9 = find( piezoRealExps(:,1)==9 );
piezoPos9Exps = extractRows( casExps, piezoLibraryIndsPos9 );
piezoLibraryIndsPos10 = find( piezoRealExps(:,1)==10 );
piezoPos9Exps = extractRows( casExps, piezoLibraryIndsPos10 );

piezoLibraryIndsPos10 = find( piezoRealExps(:,1)==10 );
piezoPos9Exps = extractRows( casExps, piezoLibraryIndsPos10 );




