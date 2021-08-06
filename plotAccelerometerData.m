function plotExperimentData( exps, sens, beg )

outBaseDir = '/Volumes/Funkotron2/SST/Artemis/NewarkHSLiveFire2/Analysis/casDir/';

srcKey = makeSrcKey;
fpKey = makeFpKey;

dirKey = { 'o', '+', 'x', '*', 'd', 'v', '^' };

% Arg, no values saved for traceability in INI file.
% XXX Clark gain must be assumed.
% +/- 2 Gs over a signal range of +/- 1 wav units
wav2Gs = 2;

casellas=find( exps(:,11) > 0 & exps(:,4) > 700 & exps(:,4) < 9000 );
numCasellas = numel(casellas);
casExps = extractRows( exps, casellas );
casIdxs = unique(casExps(:,13));
numCasIdxs = numel(casIdxs);


if nargin > 2
  tub = find( casIdxs == beg );
  if isempty(tub)
    display(sprintf('No accelerometer data found for Casella experiment %d ',beg))
  end
  interactive = 1;
  lo = tub(1);
  hi = tub(1);
else
  display(sprintf('Plotting %d Casella accelerometer experiments',numCasIdxs))
  interactive = 0;
  lo = 108;
  hi = numCasIdxs;
end


% for c = lo : hi

%   casIdx = casIdxs(c)
%   outputDir = [ outBaseDir, sprintf('exp%03d/',casIdx) ];
%   system( [ 'mkdir -p ', outputDir ] );

%   cInds = find( casExps(:,13) == casIdx & casExps(:,3) ~= -9999 )
%   numSensors = numel(cInds);
%   if ~numSensors
%     display(sprintf('No sensor data for Casella index = %d',c))
%     continue;
%   end

%   display(sprintf('Loading sensor data for Casella index = %d',c))

%   accelExps = extractRows(casExps,cInds);
%   Fs = 5000;
%   halfScale = 2;

%   numLoaded = 0;
%   accelSet = {};
%   accelLoads = zeros(size(accelExps));
%   for ex = 1 : numSensors

%     sensorNumber = accelExps(ex,4);
%     loadSuccess = 1;
    
%     try 
%       [ data, fNames ] = loadData( accelExps, ex, sens );
%       numLoaded = numLoaded + 1
%       accelSet{numLoaded} = data{3};
%       accelLoads(numLoaded,:) = accelExps(ex,:);
%     catch
%       loadSuccess = 0;
%       display( sprintf('No accelerometer data loaded for revA casIdx = %d, sensorID = %d', c, sensorNumber ) );
%     end

%   end

%   display(sprintf('Accelerometer data found for experiment %d, %d sensors',c,numLoaded))



%   FFTL = 512;
%   ovrlp = 1-1/64;
%   axesOffsets = [5, 3, 1];

%   for ex = 1 : numLoaded

%     %hold on;
%     sensorNumber = accelLoads(ex,4);
%     sensor = getSensor( sens, sensorNumber );
%     data = accelSet{ex};
%     if isempty(data)
%       warning('Load concept o-whacko')
%       continue
%     end
%     sz = size(data);
%     numSamps = sz(1);
%     xAx = 0:1/Fs:4-1/Fs; xAx = xAx + 0.5/Fs;
%     figure;
%     plot(xAx,data(:,2)+axesOffsets(1));
%     hold on;
%     plot(xAx,data(:,3)+axesOffsets(2));
%     plot(xAx,data(:,4)+axesOffsets(3));
%     %numel(unique(data(:,4)))
%     set(gca,'YLim',[0,6])
%     set(gca,'YTick',[0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6])
%     set(gca,'YTickLabel',{'-2','-1','0','1','+/-2','-1','0','1','+/-2','-1','0','1','2'})
%     xlabel('Secs');
%     ylabel('Amplitude (g)');
%     gVec = computeExpectedGravity( sensor.orient );
%     gVecEst = gravityEstimator( data(:,2:4) );
%     gVecErrorDeg = acosd(dot(gVecEst./norm(gVecEst),gVec));
%     if gVec(1) ~= 0
%       gVecHeight = axesOffsets(1) + gVec(1) ./ halfScale;
%     elseif gVec(2) ~= 0
%       gVecHeight = axesOffsets(2) + gVec(2) ./ halfScale;
%     elseif gVec(3) ~= 0
%       gVecHeight = axesOffsets(3) + gVec(3) ./ halfScale;
%     else
%       error('Wrongola!')
%     end
%     xLims = get(gca,'Xlim');
%     xWidth = xLims(2)-xLims(1);
%     line(xLims,[gVecHeight,gVecHeight],'LineStyle',':','LineWidth',2)
%     line([1 1],get(gca,'Ylim'),'LineStyle',':','Color','k')
%     text( xLims(1)+xWidth/20, gVecHeight+0.25, sprintf('Gravity error = %g degrees', gVecErrorDeg) );
%     title( sprintf('Time series of accelerometer %d for casIdx=%d experiments %s, src=%s, FP=%s, SPL=%gdB', sensorNumber, accelLoads(ex,13), datestr(accelLoads(ex,10)), srcKey(accelLoads(ex,12)).name, fpKey(accelLoads(ex,1)).name, accelLoads(ex,11) ) )
%     writeJpegFile( outputDir, makeFileName( accelLoads(ex,1), accelLoads(ex,12), sensorNumber, accelLoads(ex,5), 'accel-ts', '.jpg' ) );

%     set(gca,'XLim',[0.98 1.02])
%     title( sprintf('Zoomed time series of accelerometer %d for casIdx=%d experiments %s, src=%s, FP=%s, SPL=%gdB', sensorNumber, accelLoads(ex,13), datestr(accelLoads(ex,10)), srcKey(accelLoads(ex,12)).name, fpKey(accelLoads(ex,1)).name, accelLoads(ex,11) ) )
%     writeJpegFile( outputDir, makeFileName( accelLoads(ex,1), accelLoads(ex,12), sensorNumber, accelLoads(ex,5), 'accel-ts-zoomed', '.jpg' ) );
%     close( 'all' );

%     accel = TimeData;
%     accel.sampleRate = Fs;
%     % Noise
%     axes = { 'x', 'y', 'z' };
%     figure;
%     colors = zeros(3,3);
%     phi = ((1+sqrt(5))/2)-1;
%     colors(1,:) = [ phi, 0, 0 ];
%     colors(2,:) = [ 0, phi, 0 ];
%     colors(3,:) = [ 0, 0, phi ];
%     slic = 600;
%     noiseBase = 2500;
%     signlBase = 5000;
%     leg = {};
%     for ax = 1 : 3
%       % Convert to Gs
%       accel.samples = (data(noiseBase:noiseBase+slic,ax+1)-gVecEst(ax)) * wav2Gs;
%       %figure;
%       noiseSpect = sqrt(spectrum(accel,FFTL));
%       hsv = rgb2hsv(colors(ax,:));
%       colr = hsv2rgb([hsv(1), hsv(2)/2, 1]);
%       plot(freqVector(noiseSpect),noiseSpect.samples, 'Color', colr );
%       accel.samples = (data(signlBase:signlBase+slic,ax+1)-gVecEst(ax)) * wav2Gs;
%       signlSpect = sqrt(spectrum(accel,FFTL));
%       hold on;
%       plot(freqVector(signlSpect),signlSpect.samples, 'Color', colors(ax,:) );
%       snr{ax} = signlSpect.samples ./ noiseSpect.samples 
%       set(gca,'XLim',[signlSpect.freqResolution,Fs/2])
%       ylabel('G''s / rootHz')
%       set(gca,'XScale','log');
%       set(gca,'YScale','log');
%       set(gca,'XGrid','on');
%       set(gca,'YGrid','on');
%       legend({'noise','signal'})
%       title( sprintf('Spectrum of accelerometer %d, %s axis, for casIdx=%d experiments %s, src=%s, FP=%s, SPL=%gdB', sensorNumber, axes{ax}, accelLoads(ex,13), datestr(accelLoads(ex,10)), srcKey(accelLoads(ex,12)).name, fpKey(accelLoads(ex,1)).name, accelLoads(ex,11) ) )
%       writeJpegFile( outputDir, makeFileName( accelLoads(ex,1), accelLoads(ex,12), sensorNumber, accelLoads(ex,5), [ 'accel-psd-', axes{ax} ], '.jpg' ) );
%       close('all')
%     end
%     leg = {};
%     for ax = 1 : 3
%       % Convert to Gs
%       leg{ax} = [ axes{ax}, ' axis' ]; 
%       plot(freqVector(noiseSpect),snr{ax}, 'Color', colors(ax,:) );
%       hold on;
%       ylabel( [ 'G''s / rootHz - ', sprintf('Frequency Resolution = %g', signlSpect.freqResolution ) ] )
%       set(gca,'XLim',[signlSpect.freqResolution,Fs/2])
%       set(gca,'YLim',[0.1, 1000])
%       set(gca,'YTickLabel',{'0.1','1','10','100','1000'})
%       set(gca,'XScale','lin');
%       set(gca,'YScale','log');
%       set(gca,'XGrid','on');
%       set(gca,'YGrid','on');
%     end
%     legend(leg)
%     title( sprintf('SNR of accelerometer %d, for casIdx=%d experiments %s, src=%s, FP=%s, SPL=%gdB', sensorNumber, accelLoads(ex,13), datestr(accelLoads(ex,10)), srcKey(accelLoads(ex,12)).name, fpKey(accelLoads(ex,1)).name, accelLoads(ex,11) ) )
%     writeJpegFile( outputDir, makeFileName( accelLoads(ex,1), accelLoads(ex,12), sensorNumber, accelLoads(ex,5), 'accel-snr', '.jpg' ) );

%     % for ax = 1 : 3
%     %   % Convert to Gs
%     %   accel.samples = data(:,ax+1) * wav2Gs;

%     %   figure;
%     %   plot(spectrum(accel,FFTL));
%     %   set(gca,'XScale','log');
%     %   set(gca,'YScale','log');

%     %   title( sprintf('Spectrum of accelerometer %d, %s axis, for casIdx=%d experiments %s, src=%s, FP=%s, SPL=%gdB', sensorNumber, axes{ax}, accelLoads(ex,13), datestr(accelLoads(ex,10)), srcKey(accelLoads(ex,12)).name, fpKey(accelLoads(ex,1)).name, accelLoads(ex,11) ) )
%     %   writeJpegFile( outputDir, makeFileName( accelLoads(ex,1), accelLoads(ex,12), sensorNumber, accelLoads(ex,5), [ 'psd-', axes{ax} ], '.jpg' ) );


%     %   % plot(log10(spectrogram(accel,FFTL,ovrlp)));
%     %   % title( sprintf('Spectrogram of accelerometer %d, %s axis, for casIdx=%d experiments %s, src=%s, FP=%s, SPL=%gdB', sensorNumber, axes{ax}, accelLoads(ex,13), datestr(accelLoads(ex,10)), srcKey(accelLoads(ex,12)).name, fpKey(accelLoads(ex,1)).name, accelLoads(ex,11) ) )
%     %   % writeJpegFile( outputDir, makeFileName( accelLoads(ex,1), accelLoads(ex,12), sensorNumber, accelLoads(ex,5), [ 'sgram-', axes{ax} ], '.jpg' ) );
%     % end
%   end



%   if ~interactive
%     close('all')
%     continue
%   else
%     return
%   end

    	
% end

% close('all')
% return

close('all')


accelInds = find( casExps(:,13) > 179 & casExps(:,3) ~= -9999 );
accelExps = extractRows( casExps, accelInds );

fps = unique(accelExps(:,1));
numFPs = numel(fps);
for fp = 1 : numFPs
  thisFP = fps(fp)
  fpInds = find( accelExps(:,1) == thisFP );
  fpExps = extractRows( accelExps, fpInds );
  srcs = unique(fpExps(:,12))  
end

% for axis = 1 : 3;
%   switch axis
%     case 1
%       axKey = 'X'
%       axMax = 2;
%     case 2
%       axKey = 'Y'
%       axMax = 3;
%     case 3
%       axKey = 'Z'
%       axMax = 2;
%     otherwise
%       error('Bad axis')
%   end

%   casMeas = unique(accelExps(:,13));
%   quot = zeros(numel(accelInds),1);
%   quotExps = zeros(numel(accelInds),17);
%   numQuot = 0;
%   for c = 1 : numel(casMeas)
%     cas = casMeas(c);
%     cIds = find( accelExps(:,13) == cas );
%     if numel(cIds) < 2
%       continue;
%     end
%     cIdExps = extractRows( accelExps, cIds );
%     floaterIdx = find( cIdExps(:,4) == 1024 );
%     if numel(floaterIdx) ~= 1
%       continue
%     end
%     % We have a candidate
%     floaterExp = extractRows( cIdExps, floaterIdx );
%     fixedIdxs = find( cIdExps(:,4) ~= 1024 & cIdExps(:,4) ~= 1061 & cIdExps(:,4) ~= 1068 & cIdExps(:,4) ~= 762 );
%     fixedExps = extractRows( cIdExps, fixedIdxs );
%     numFixed = numel(fixedIdxs);
%     [ peak ] = getAccelPeaks( floaterExp, sens, axis ).*wav2Gs;
%     [ peaks ] = getAccelPeaks( fixedExps, sens, axis ).*wav2Gs;
%     for p = 1 : numFixed
%       if( peaks(p)>axMax*(1-1/256) | peak>axMax*(1-1/256) )
%         continue
%       end
%       numQuot = numQuot +1;
%       quot(numQuot) = peak / peaks(p);
%       quotExps(numQuot,:) = fixedExps(p,:);
%     end
%   end
%   quot = quot(1:numQuot);
%   quotExps = quotExps(1:numQuot,:);
%   hold on;
%   plot(quotExps(:,1),quot,'LineStyle','none','Marker','o')
% end
% legend({'X axis','Y axis','Z axis'})
% set(gca,'XLim',[-1 14])
% set(gca,'XTick',1:12)
% for f = 1:12
%   fLbl{f} = fpKey(f).name;
% end
% set(gca,'XTickLabel',fLbl,'XTickLabelRotation',10)
% setPlotSize();
% ylabel('peak amplitude floating/fixed')
% xlabel('Firing Position')
% title('Ratio of fixed to floating accelerometer amplitudes')
% return


axis = 1;
switch axis
  case 1
    axKey = 'X'
    axMax = 2;
  case 2
    axKey = 'Y'
    axMax = 3;
  case 3
    axKey = 'Z'
    axMax = 2;
  otherwise
    error('Bad axis')
end


srcs = unique(accelExps(:,12))
figure;
colrs = get(gca,'ColorOrder');
szc=size(colrs);

leg={}
numLeg = 0;
for s = 1 : numel(srcs)
  src = srcs(s);
  srcInds = find( accelExps(:,12) == src & accelExps(:,4) ~= 1061 & accelExps(:,4) ~= 1068 & accelExps(:,4) ~= 762 );
  if isempty(srcInds)
    continue
  end    
  srcExps = extractRows( accelExps, srcInds );
  numSrcExps = numel(srcInds)
  %peaks = zeros(numSrcExps,1);
  [ peaks ] = getAccelPeaks( srcExps, sens, axis ).*wav2Gs;
  %[ peaks ] = getAccelRms( srcExps, sens, axis );
  %[ peaks ] = getAccelPwr( srcExps, sens, axis );
  sz = size(peaks);
  %xAx = zeros(sz(1),1); xAx = xAx + s;
  xAx = s:0.5/(sz(1)-1):s+0.5
  numel(xAx)
  hold on;
  % for p = 1 : numel(peaks)
  %   plot(xAx(p),20.*log10(peaks(p)),'Marker',dirKey{srcExps(p,2)+1},'LineStyle','none','Color',colrs(mod(s,szc(1))+1,:));
  % end
  plot(xAx,20.*log10(peaks),'Marker','o','LineStyle','none','Color',colrs(mod(s,szc(1))+1,:));
  numLeg = numLeg + 1;
  leg{numLeg} = srcKey(src).name;
  ticks(numLeg)=s+0.25;
  %lbls{s} = srcKey(src).name
end
legend(leg)
set(gca,'XLim',[0 16])
%set(gca,'YLim',[-20 10])
%set(gca,'YLim',[-80 0])
%set(gca,'YLim',[-70 0])
set(gca,'XTick',ticks)
set(gca,'XGrid','on')
set(gca,'XTickLabel',leg)
set(gca,'XTickLabelRotation',10)
ylabel('Peak dB')
setPlotSize();
title( sprintf('Accelerometer %s-axis peaks vs. source',axKey) )
writeJpegFile( outBaseDir, sprintf('Accelerometer-source-%s-axis-peaks.jpg', axKey ) )
return

% % srcs = unique(accelExps(:,12))
% srcs = [ 1, 7, 8, 9, 10, 11, 12 ]
% figure;
% leg={}
% for s = 1 : numel(srcs)
%   src = srcs(s);
%   srcInds = find( accelExps(:,12) == src  & accelExps(:,4) ~= 1061 & accelExps(:,4) ~= 1068 & accelExps(:,4) ~= 762 );
%   srcExps = extractRows( accelExps, srcInds );
%   numSrcExps = numel(srcInds)
%   %peaks = zeros(numSrcExps,1);
%   [ peaks ] = getAccelPeaks( srcExps, sens, axis ).*wav2Gs;
%   %[ peaks ] = getAccelRms( srcExps, sens, axis );
%   %[ peaks ] = getAccelPwr( srcExps, sens, axis );
%   sz = size(peaks);
%   %xAx = zeros(sz(1),1); xAx = xAx + s;
%   hold on;
%   xAx = srcExps(:,11);
%   %xAx = undB(srcExps(:,11));
%   hold on;
%   for p = 1 : numel(peaks)
%     plot(xAx(p),20.*log10(peaks(p)),'Marker',dirKey{srcExps(p,2)+1},'LineStyle','none','Color',colrs(mod(s,szc(1))+1,:));
%   end
%   leg{s} = srcKey(src).name;
%   %lbls{s} = srcKey(src).name
% end
% legend(leg)
% %set(gca,'XLim',[0 16])
% set(gca,'XLim',[110 155])
% set(gca,'YLim',[-20 10])
% % set(gca,'XTickLabel',leg)
% % set(gca,'XTickLabelRotation',10)
% setPlotSize();
% ylabel('log Peak |G''s| dB')
% xlabel('Casella Peak Level, dB SPL')
% title( sprintf('Accelerometer %s-axis peaks vs. Casella Sound Meter peaks for taps',axKey) )
% writeJpegFile( outBaseDir, sprintf('Casella-Accelerometer-compare-taps-%s-axis.jpg', axKey ) )
% close('all')
return

srcs = [ 3, 4, 6, 13 ]
figure;
leg={}
plCnt=0;
for s = 1 : numel(srcs)
  src = srcs(s)
  src1Inds = find( accelExps(:,12) == src & accelExps(:,1) == 9 & accelExps(:,4) ~= 1024 & accelExps(:,4) ~= 1061 );
  src1Exps = extractRows( accelExps, src1Inds );
  src2Inds = find( accelExps(:,12) == src & accelExps(:,1) == 10 & accelExps(:,4) ~= 1024 & accelExps(:,4) ~= 1061 );
  src2Exps = extractRows( accelExps, src2Inds );
  [ peaks1 ] = getAccelPeaks( src1Exps, sens, axis ).*wav2Gs;
  [ peaks2 ] = getAccelPeaks( src2Exps, sens, axis ).*wav2Gs;
  %xAx = zeros(sz(1),1); xAx = xAx + s;
  hold on;
  if numel(src1Exps)
    xAx1 = src1Exps(:,11);
    plot(xAx1,10.*log10(peaks1),'Marker','o','LineStyle','none','Color',colrs(mod(s,szc(1)),:));
    fpName = fpKey(9).name;
    plCnt = plCnt + 1;
    leg{plCnt} = sprintf( '%s - %s', srcKey(src).name, fpName );
  end
  if numel(src2Exps)
    xAx2 = src2Exps(:,11);
    plot(xAx2,20.*log10(peaks2),'Marker','+','LineStyle','none','Color',colrs(mod(s,szc(1)),:));
    fpName = fpKey(10).name;
    plCnt = plCnt + 1;
    leg{plCnt} = sprintf( '%s - %s', srcKey(src).name, fpName );
  end
  %lbls{s} = srcKey(src).name
end
legend(leg,'Location','SouthEast')
%set(gca,'XLim',[0 16])
%set(gca,'XLim',[110 155])
set(gca,'YLim',[-15 10])
% set(gca,'XTickLabel',leg)
% set(gca,'XTickLabelRotation',10)
setPlotSize();
ylabel('Peak |G''s| dB')
xlabel('Casella Peak Level, dB SPL')
title( sprintf('Library Accelerometer %s-axis Peaks vs. Casella Sound Meter peaks',axKey) )
writeJpegFile( outBaseDir, sprintf('Library-Casella-Accelerometer-compare-%s-axis-rms.jpg', axKey ) )

return


srcs = [ 3, 4, 6, 13 ]
figure;
leg={}
for s = 1 : numel(srcs)
  src = srcs(s)
  srcInds = find( accelExps(:,12) == src );
  srcExps = extractRows( accelExps, srcInds );
  numSrcExps = numel(srcInds)
  %peaks = zeros(numSrcExps,1);
  %[ peaks ] = getAccelPeaks( srcExps, sens, axis ).*wav2Gs;
  [ peaks ] = getAccelRms( srcExps, sens, axis ).*wav2Gs;
  %[ peaks ] = getAccelPwr( srcExps, sens, axis ).*wav2Gs;
  sz = size(peaks);
  %xAx = zeros(sz(1),1); xAx = xAx + s;
  hold on;
  xAx = srcExps(:,11);
  %xAx = undB(srcExps(:,11));
  hold on;
  % for p = 1 : numel(peaks)
  %   plot(xAx(p),20.*log10(peaks(p)),'Marker',dirKey{srcExps(p,2)+1},'LineStyle','none','Color',colrs(mod(s,szc(1))+1,:));
  % end
  plot(xAx,10.*log10(peaks),'Marker','o','LineStyle','none','Color',colrs(mod(s,szc(1)),:));
  leg{s} = srcKey(src).name;
  %lbls{s} = srcKey(src).name
end
legend(leg,'Location','NorthWest')
%set(gca,'XLim',[0 16])
set(gca,'XLim',[110 155])
%set(gca,'YLim',[-20 10])
% set(gca,'XTickLabel',leg)
% set(gca,'XTickLabelRotation',10)
setPlotSize();
ylabel('RMS |G''s| dB')
xlabel('Casella Peak Level, dB SPL')
title( sprintf('Accelerometer %s-axis rms vs. Casella Sound Meter peaks',axKey) )
writeJpegFile( outBaseDir, sprintf('Casella-Accelerometer-compare-%s-axis-rms.jpg', axKey ) )

return

txtOff=-0.25;


leg={}
for t = 1 : numel(srcs)
  txtSrc = srcs(t);
  cIdx = 0;
  for s = 1 : numel(srcs)
    src = srcs(s);
    cIdx = cIdx + 1;
    srcColor = colrs(mod(s,szc(1))+1,:);
    srcInds = find( accelExps(:,12) == src );
    srcExps = extractRows( accelExps, srcInds );
    numSrcExps = numel(srcInds);
    %peaks = zeros(numSrcExps,1);
    [ peaks ] = getAccelPeaks( srcExps, sens, axis ).*wav2Gs;
    %[ peaks ] = getAccelRms( srcExps, sens, axis );
    %[ peaks ] = getAccelPwr( srcExps, sens, axis );
    sz = size(peaks);
    hold on;
    mkr = 'o';
    xAx = srcExps(:,11);
    hold on;
    for p = 1 : numel(peaks)
      plot(xAx(p),20.*log10(peaks(p)),'Marker',dirKey{srcExps(p,2)+1},'LineStyle','none','Color',colrs(mod(s,szc(1))+1,:));
    end
    if txtSrc == src
      for s = 1 : sz(1)
        text(xAx(s),20.*log10(peaks(s))+txtOff,[ fpKey(srcExps(s,1)).name, '-', sprintf('%d=%d',srcExps(s,4),srcExps(s,13)) ],'HorizontalAlignment','center')
      end
      plot(xAx,20.*log10(peaks),'Marker',mkr,'LineStyle','none','MarkerFaceColor',srcColor,'MarkerEdgeColor',srcColor);
    end
    %leg{s} = srcKey(src).name;
    %lbls{s} = srcKey(src).name
  end
  %legend(leg)
  set(gca,'XLim',[110 155])
  set(gca,'YLim',[-20 10])
  % set(gca,'XTickLabel',leg)
  % set(gca,'XTickLabelRotation',10)
  setPlotSize();
  ylabel('log Peak |G''s|')
  xlabel('Casella Peak Level, dB SPL')
  title( sprintf('Accelerometer %s-axis peaks vs. Casella Sound Meter peaks - %s', axKey, srcKey(txtSrc).name ))
  writeJpegFile( outBaseDir, sprintf('Casella-Accelerometer-%s-%s-axis.jpg', axKey, srcKey(txtSrc).name ) )
  close('all')
end

return

