function plotArtemisPeaksVsCasella( exps, sens, ch, opt, beg )
%PLOTARTEMISPEAKS Sound peaks from various Aretmis signals.
% 
% exps - the 17 column full experiment.  Column labels are contained in the 
%        'fullExpsLbls' variable found in ExperimentMatrix.mat.
%
% sens - the 'sensor' struct array found in ExperimentMatrix.mat.
%
% ch - And indicator of which channel (audio piezo, etc.) to plot.  It's 
%      values are found in makeChKey.m 

outBaseDir = '/Volumes/Funkotron2/SST/Artemis/NewarkHSLiveFire2/Analysis/casDir/';

% Consistent yools across all Artemis analyses.
srcKey = makeSrcKey;
fpKey = makeFpKey;
dirKey = makeDirKey;
chKey = makeChKey;

sz = size(exps);
if sz(2) ~= 17
  error('Improper experiment matrix in ex!')
end

if nargin > 4
  tub = find( casIdxs == beg );
  if isempty(tub)
    display(sprintf('No matching experiment found for %d ',beg))
  end
  interactive = 1;
  lo = tub(1);
  hi = tub(1);
else
  numExpIdxs = sz(1);
  display(sprintf('Plotting peaks of %d experiments',numExpIdxs))
  interactive = 0;
  lo = 1;
  hi = numExpIdxs;
end

% Select only Casella exps
  % casellaIdxs = find( exps(:,11) > 0 );
  % exps = extractRows( exps, casellaIdxs );
exps = getCasellaExps( exps );

% Remove non-incidents
incidentIdxs = find( exps(:,3) ~= -9999 );
exps = extractRows( exps, incidentIdxs );

% Select data loader
[ chMoniker, chName ] = findChKey(chKey,ch);
[ loader, chan, exps, dBCorr ] = selectPeakLoader( exps, chKey, ch );


close('all')


% numFPs = numel(fps);
% for fp = 1 : numFPs
%   thisFP = fps(fp)
%   fpInds = find( exps(:,1) == thisFP );
%   fpExps = extractRows( exps, fpInds );
%   srcs = unique(fpExps(:,12))  
% end
% fps = unique(exps(:,1));

srcs = unique(exps(:,12));
figure;
colrs = get(gca,'ColorOrder');
szc=size(colrs);

leg={};
numLeg = 0;
for s = 1 : numel(srcs)
  src = srcs(s);
  srcInds = find( exps(:,12) == src );
  if isempty(srcInds)
    continue
  end    
  arr = extractRows( exps, srcInds );
  numSrcExps = numel(srcInds);
  hold on;
  eval(loader);
  sz=size(aPeaks);
  if isempty(aPeaks)
    continue
  end
  plot(aPeaks(:,3),aPeaks(:,1),'Marker','o','LineStyle','none','Color',colrs(mod(s,szc(1))+1,:));
  set(gca,'XGrid','on');
  set(gca,'YGrid','on');
%  set(gca,'YScale','log');
  numLeg = numLeg + 1;
  leg{numLeg} = srcKey(src).name;
  ticks(numLeg)=s + 0.25;
  %lbls{s} = srcKey(src).name
end
legend(leg,'Location','Northwest')
%set(gca,'YLim',[-20 10])
%set(gca,'YLim',[-80 0])
%set(gca,'YLim',[-70 0])
%set(gca,'XTick',ticks)
set(gca,'XGrid','on')
setPlotSize();

title( sprintf('NMHS Tests, %s peak vs. Casella',chName) )
writeJpegFile( outBaseDir, sprintf('%s-source-ve-casella.jpg',chMoniker) )
ylabel(units)
xlabel('Casella - dB SPL')

return



