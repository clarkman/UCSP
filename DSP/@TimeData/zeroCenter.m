function [ outdata, ctr ] = zeroCenter(obj)
%
% Uses a histogram to find the mean of "most" of the data.
%

%doGraph = 1;

numSamps = length(obj.samples);
if( numSamps == 0 )
    error([' TimeData object for ', obj.DataCommon.source, ' has no samples']);
end

outdata = cloneEmpty( obj );
numBins = 100;

[cnts,ctrs] = hist(obj.samples,numBins);

[ val, ind ] = max(cnts);

halfbin=round(ctrs(2)-ctrs(1))/2;

stepr = 4.5;

%highestBin=ctrs(ind);

highestBinInd = ind+25;
if( highestBinInd > numBins )
    highestBinInd = numBins;
end
lowestBinInd = ind-25;
if( lowestBinInd < 1 )
    lowestBinInd = 1;
end

hi = ctrs(highestBinInd)-stepr*halfbin;
lo = ctrs(lowestBinInd)+stepr*halfbin;


%if doGraph
%  hist(obj.samples)
%  line( [lo lo], get(gca,'YLim'), 'Color', [0,0.6,0])
%  line( [hi hi], get(gca,'YLim'), 'Color', [0.6,0,0])
%end

sampsIn = obj.samples;
sampsOut = zeros( numSamps, 1 );
uth = 0;
for ith = 1 : numSamps
  s = sampsIn(ith);
  if( s >= lo && s <= hi )
    uth = uth + 1;
    sampsOut( uth, 1 ) = s;
  end
end

sampsOut = sampsOut(1:uth,1);

%[rows,cols,vals] = find( ctrs(2) < obj.samples );
%vals(1:10)
%[rows,cols,vals] = find( ctrs(end-1) > vals );

ctr = mean( sampsOut );
outdata.samples = obj.samples - ctr;

outdata = addToHistory(outdata, ['Zero Centered']);

outdata = updateEndTime( outdata );

