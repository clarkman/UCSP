function [outBins, histBinWidth] = histogram( obj, numBins )
% Create a 

objStdDev = sqrt(var(obj.samples))
objMean = mean( obj )
objMax = max( obj.samples );
objMin = min( obj );

if( nargin >= 2 )
    lengthHisto = numBins;
else 
   % Use Sturges Rule, NO.  Caca for large n
   % lengthHisto = 3.3 * log10( length( obj ) + 1 );
   % lengthHisto = 1.0 * log( length( obj ) );
   % Scott's rule:
    lengthHisto= 3.5 * (objStdDev*length(obj))^(1/3)
end

if( abs(objMax) > abs(objMin) )
    halfHist = abs(objMax);
else
    halfHist = abs(objMin);
end

histMin = objMean - halfHist
histMax = objMean + halfHist
histBinWidth = ( histMax - histMin ) / lengthHisto;
cntrHisto = lengthHisto/2;

figure;
set(get(gcf,'CurrentAxes'),'XLim',[500 1500]);
outBins = hist( obj.samples, lengthHisto );
