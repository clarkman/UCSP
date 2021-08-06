function plotSpoolDownload( dirName, dqvDivisor )

oldDir = pwd;

cd( dirName );

if nargin < 2 
  dqvDivisor = 5;
end

wavs = dir( '*.wav' );
numWavs = numel( wavs );
audios = cell(numWavs,1);
mags = zeros(numWavs,1);
fs = zeros(numWavs,1);
yLabs = cell(numWavs,1);
for w = 1 : numWavs
  [ audios{w}, fs(w) ] = audioread(wavs(w).name);
  afr = audioinfo(wavs(w).name)
  fName = wavs(w).name;
  dahs = strfind( fName, '(' );
  wafs = strfind( fName, ')' );
  leftParen = dahs(1);
  rightParen = wafs(end);
  fName = fName(leftParen+1:rightParen-1);
  dashes = strfind(fName,'-');
  if ~isempty( strfind( fName, 'DQV' ) )
  	fName = sprintf( 'DQV/%d', dqvDivisor );
  	dqvInd = w;
  else
    fName = fName(dashes(end)+1:end);
  end
  yLabs{w} = fName;
  mags(w) = std(audios{w});
end

if numel(unique(fs(w))) ~= 1
  warning('wav files different length')
  return
end

audioSize = size(audios{w});
if audioSize(2) > 1
  warning('Only MONO files')
  return
end
numSamps = audioSize(2);
dateName = wavs(1).name;
unds = strfind(dateName,'_');
wsps = strfind(dateName,' ');
dateName = dateName(wsps(1)+1:unds(1)-1);
firstT = datenum( [ dateName(1:10), ' ', dateName(12:13), ':', dateName(14:15), ':', dateName(16:17) ] );
%tVec = firstT : 
cd( oldDir );

%return

[ m, h ] = sort(mags);

yStep = 5;
yTickLabels = cell(numWavs,1);
yTicks = zeros(numWavs,1);
for w = numWavs : -1 : 1 
  yLabels{w} = yLabs{h(w)};
  hold on;
  yTicks(w) = w/yStep;
  if( h(w) == dqvInd )
    plot( audios{h(w)} .* 0.25 + yTicks(w) )
  else
    plot( audios{h(w)} + yTicks(w) )
  end
  hold off;
end

set(gca,'YLim',[0,yTicks(end)+1/yStep])
set(gca,'YTick',yTicks)
set(gca,'YTickLabel',yLabels)
%pSql = dir( 'pulses.sql' )

cd( oldDir );

