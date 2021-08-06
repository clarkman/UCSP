function plotPiezoDelay( exps, sens, beg )

outBaseDir = '/Volumes/Funkotron2/SST/Artemis/NewarkHSLiveFire2/Analysis/casDir/';

srcKey = makeSrcKey;
fpKey = makeFpKey;

dirKey = { 'o', '+', 'x', '*', 'd', 'v', '^' };

% Arg, no values saved for traceability in INI file.
% XXX Clark gain must be assumed.
% +/- 2 Gs over a signal range of +/- 1 wav units
wav2Gs = 2;

casellas=find( exps(:,11) > 0 & exps(:,4) < 9000 );
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


close('all')


fps = unique(casExps(:,1));
numFPs = numel(fps);
for fp = 1 : numFPs
  thisFP = fps(fp)
  fpInds = find( casExps(:,1) == thisFP );
  fpExps = extractRows( casExps, fpInds );
  srcs = unique(fpExps(:,12))  
end


srcs = unique(casExps(:,12))
figure;
colrs = get(gca,'ColorOrder');
szc=size(colrs);

doOnset = 1;

leg={}
numLeg = 0;
for s = 1 : numel(srcs)
  src = srcs(s);
  srcInds = find( casExps(:,12) == src );
  if isempty(srcInds)
    continue
  end    
  srcExps = extractRows( casExps, srcInds );
  numSrcExps = numel(srcInds)
  %peaks = zeros(numSrcExps,1);
  hold on;
  if doOnset
    peaks = getPiezoPeakOnset( srcExps, sens );   sz = size(peaks)
    xAx = s:0.5/(sz(1)-1):s+0.5
    plot(xAx,peaks,'Marker','o','LineStyle','none','Color',colrs(mod(s,szc(1))+1,:));
    set(gca,'XGrid','on');
    set(gca,'YGrid','on');
    set(gca,'YScale','log');
    set(gca,'XLim',[0 16])
  else
    peaks = getPiezoPeakOnset( srcExps, sens );   sz = size(peaks)
    plot(peaks(:,2),peaks(:,1),'Marker','o','LineStyle','none','Color',colrs(mod(s,szc(1))+1,:));
    set(gca,'XGrid','on');
    set(gca,'YGrid','on');
    set(gca,'YScale','log');
  end
  %xAx = zeros(sz(1),1); xAx = xAx + s;
  % for p = 1 : numel(peaks)
  %   plot(xAx(p),20.*log10(peaks(p)),'Marker',dirKey{srcExps(p,2)+1},'LineStyle','none','Color',colrs(mod(s,szc(1))+1,:));
  % end
  numLeg = numLeg + 1;
  leg{numLeg} = srcKey(src).name;
  ticks(numLeg)=s+0.25;
  %lbls{s} = srcKey(src).name
end
%set(gca,'YLim',[-20 10])
%set(gca,'YLim',[-80 0])
%set(gca,'YLim',[-70 0])
%set(gca,'XTick',ticks)
set(gca,'XGrid','on')
%set(gca,'XTickLabel',leg)
%set(gca,'XTickLabelRotation',10)
setPlotSize();

if doOnset
  title( sprintf('NMHS Tests, Piezo peak onset delay vs. source') )
  %writeJpegFile( outBaseDir, 'Piezo-source-msec.jpg' )
  writeJpegFile( outBaseDir, 'Piezo-source-msec.jpg' )
  ylabel('msec (after 1 sec)')
else
  %legend(leg)
  title( sprintf('NMHS Tests, Piezo peak onset delay vs. Casella') )
  writeJpegFile( outBaseDir, 'Piezo-source-msec-casella.jpg' )
  ylabel('msec (after 1 sec)')
end
return



