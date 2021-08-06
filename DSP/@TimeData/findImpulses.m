function [ cnt, peaks, durs, onsets, decays, noisePeak, noiseRmsAvg ] = findImpulses( td )

cnt = 0; 
peaks = []; 
durs = [];
onsets = [];
decays = []; 
noisePeak = 0; 
noiseRmsAvg = 0;

sampls = td.samples;
numSampls = length( td );

segLength = 512;
segOvrlap = 1/2;
segStep = segLength * segOvrlap;
numSegs = ( numSampls / segLength ) * 2 - 2; % Toss last

vals = zeros(2,numSegs);

segs = zeros(numSegs,segLength);

for s = 1 : numSegs
  segStart = s*segStep;
  segEnd = segStart + segLength - 1;
  seg=sampls(segStart:segEnd);
  vals(1,s) = rms(seg);
  vals(2,s) = max(seg);
  segs(s,:) = seg;
end

%plot(td);
numBins = 10;
[ bins, ctrs ] = hist(vals(2,:),numBins);
zips = find( bins == 0 );
if numel(zips) == 0
  noisePeak = max(sampls);
  noiseRmsAvg = rms(sampls);
  warning('None found')
  return
end
% Well behaved?
if( zips(1) == 1 || zips(end) == numBins )
	error('Problem')
end
binWidth = ctrs(2)-ctrs(1);
halfBinWidth = binWidth  / 2;
% max(ctrs)
% max(vals(2,:))
% min(ctrs)
noiseCap = ctrs(zips(1)-1) + halfBinWidth;
signalFloor = ctrs(zips(end)) - halfBinWidth;
%line(get(gca,'XLim'),[noiseCap,noiseCap],'Color',[1.0,0.5,0.5])
%line(get(gca,'XLim'),[signalFloor,signalFloor],'Color',[0.5,1.0,0.5])

noise = find( vals(2,:) < noiseCap );
signal = find( vals(2,:) > signalFloor );

noiseVals = extractRows(vals(2,:)',noise);
rmsVals = extractRows(vals(1,:)',noise);

noisePeak = max(noiseVals);
noiseRmsAvg = mean(rmsVals);


% Remove duplicates from overlap. 
numSignal = numel(signal);
sigInds = zeros(1,numSignal*6);
numF = 0;
for s = 1 : numSignal
	indrs = find( sampls == vals(2,signal(s)) );
	for ii = 1 : numel(indrs)
	  numF = numF + 1;
      sigInds(numF) = indrs(ii);
    end
end
sigInds = sigInds(1:numF);
sigInds = unique(sigInds);
numSigs = numel(sigInds);

plotem = 0;
if plotem == 1
  figure;
  plot(sampls)
  for s = 1 : numSigs
  	x = sigInds(s);
  	line([x x],get(gca,'Ylim'),'Color','k')
  end
  %keyboard
end

if(numSigs>3)
  warning('Bogey')
  cnt = 0;
  return
end
peaks = zeros(1,numSigs);
durs = zeros(1,numSigs);

samplPeriod = 1.0 / td.sampleRate;
for s = 1 : numSigs
	x = sigInds(s) * samplPeriod - samplPeriod/2;
	peaks(s) = sampls(sigInds(s));
	%line( [x x], [0 peaks(s)], 'Color', [0.5 0.5 0.5]);

    % Find start index
	for v = sigInds(s) : -1 : sigInds(s) - 2048
		if sampls(v) < noiseCap
			break
		end
	end
	sigStart = v + 1;
	xStart = sigStart * samplPeriod - samplPeriod/2;
	%line( [xStart, xStart], [0,noiseCap], 'Color', [0.5 0.5 0.5])
    % Find final index
    %numel(sampls)
	for v = sigInds(s) : sigInds(s) + 2048
		if sampls(v) < noiseCap
			break
		end
	end
	sigEnd = v - 1;
	xEnd = sigEnd * samplPeriod - samplPeriod/2;
	%line( [xEnd, xEnd], [0,noiseCap], 'Color', [0.5 0.5 0.5])

	durs(s) = ( xEnd - xStart );
	onsets(s) = ( x - xStart );
	decays(s) = ( xEnd - x );
    
end
%Shots are seconds apart.  Any with close indices are the same event. 

cnt = numSigs;

% Duration is to noise cap, segLength max.




return

