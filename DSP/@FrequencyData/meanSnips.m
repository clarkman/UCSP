function [freqsAx, plotsAx] = meanSnips(varargin)
%
% Analyzes a mean frequency object and its components for
% any mean peak that occurs within "width" (+/- 1/2 width).
% hertz of every frequency in the mean.
%
% hndl = meanSnips(meanFreqDataObj,freqDataObj1,freqDataObj2,...,dBOffset,width,threshCount)
%
% lo and his are not optional, and should not be made very wide, lest
% The plots take too long to draw!


% 1. Arg count checking:
if nargin < 5
    error('Not enough inputs args! Min is: meanPlots(meanFreqData,FreqDataObj1,lo,hi,width,threshcount)')
    return;
end


% 2. Meaned object determination:
meanSpectrum = 0;
if( isa( varargin{1}, 'FrequencyData' ) )
    meanSpectrum = varargin{1};    
else
    error('First arg must be the averaged frequency data object');
    hndl = 0;
    return;
end    


% 3. Frequency range determination:
lengthOfSum = length(meanSpectrum); 
numMeanBins = lengthOfSum - 1;
maxFreq = numMeanBins * meanSpectrum.freqResolution;
meanSpectrumProps = sprintf( 'Mean spectrum has %d points, and a maximum frequency of %g hz ', numMeanBins+1, maxFreq );
display( meanSpectrumProps );


% 4. Slice determination:
width = 0;
threshCount = 0;
if( isa( varargin{nargin}, 'double' ) )
    threshCount = varargin{nargin};
else
    error('Last arg not a number - must be threshold required above mean');
    hndl = 0;
    return;
end
if( threshCount < 0 )
    error('threshCounter must be a positive number!');
    hndl = 0;
    return;
end

numFreqDataObjs = nargin - 4;
if( threshCount > numFreqDataObjs )
    error('threshCounter greater than count of frequency data object components!');
    hndl = 0;
    return;
end

if( isa( varargin{nargin-1}, 'double' ) )
    width = varargin{nargin-1};
else
    error('Next to last arg not aq number - must frequency mean length');
    hndl = 0;
    return;
end
if( width < 0 )
    error('Width must be a positive number!');
    hndl = 0;
    return;
end
if( width > maxFreq )
    warning('Width greater than maximum frequency of mean spectrum!');
    width = maxFreq;
    sprintf('Width clamped to maximum frequency of mean spectrum: %g hz!', width)
end

if( isa( varargin{nargin-2}, 'double' ) )
    elev = varargin{nargin-2};
else
    error('Next to last arg not aq number - must frequency mean length');
    hndl = 0;
    return;
end


% 5. Component checking
sumFlunky = meanSpectrum;
for rth = 2:numFreqDataObjs+1
    sumFlunky = varargin{rth};
	if( isa( sumFlunky, 'FrequencyData' ) == 0 )
        error('All components must be frequency data objects');
        hndl = 0;
        return;
	end
    if( length(sumFlunky) ~= lengthOfSum )
        error('All components must be identical length');
        hndl = 0;
        return;
    end
    componentComplete = sprintf('Found valid component %d',rth);
    %display(componentComplete);
    %display(sumFlunky.source);
end
allComponents = sprintf('Found %d component spectra...',numFreqDataObjs);
display(allComponents);



% 5. Compute average way points
binsPerHertz = 1.0 / meanSpectrum.freqResolution;
halfWidth = width/2;
numBinsWide = halfWidth * binsPerHertz;
numBinsWide = floor(numBinsWide)+1; % Round UP.
if( numBinsWide > 1000 )
    warning( 'really wide bins may be slow!' );
end
firstRunningPoint = numBinsWide + 1;
lastRunningPoint = lengthOfSum - numBinsWide;
sprintf('Averages will be run from bin %d to bin %d!', firstRunningPoint,lastRunningPoint)

freqAxSamples = meanSpectrum.samples;
plottedSamples = meanSpectrum.samples;
binSelections = meanSpectrum.samples;
localMeansSamps = meanSpectrum.samples;
localMeansElevs = meanSpectrum.samples;
meanSamps = meanSpectrum.samples;
plotIdx = 0;
passCriteriaIdx = 0;
passCounter = 0;
meanN = numBinsWide + numBinsWide + 1;
sumN = 0;
localMean = 0;
for nth = firstRunningPoint:lastRunningPoint
    sumN = 0;
    for rth = nth-numBinsWide:nth+numBinsWide
        sumN = sumN + meanSamps(rth);
    end
    localMean = sumN / meanN;
%    if( meanSamps(nth) > localMean )
    if( meanSamps(nth) >= 0 )
        plotIdx = plotIdx+1;
        freqAxSamples(plotIdx) = (nth-1) * meanSpectrum.freqResolution;
        plottedSamples(plotIdx) = meanSamps(nth);
        binSelections(plotIdx) = nth;
        localMeansSamps(plotIdx) = localMean;
        localMeansElevs(plotIdx) = plottedSamples(plotIdx)-localMean;
    end
end


freqAx = freqAxSamples(1:plotIdx);
plotAx = plottedSamples(1:plotIdx);
binSel = binSelections(1:plotIdx);
localMeans = localMeansSamps(1:plotIdx);

%figure;
%stem(freqAx,plotAx);

passAxis = freqAx;
plotAxis = plotAx;
passIdx = 0;

for tth = 1:plotIdx
    passCounter = 0;
    %nth
	for rth = 2:numFreqDataObjs+1
        sumFlunky = varargin{rth};
        sumFlunkySamps = sumFlunky.samples;
		if( sumFlunkySamps(binSel(tth)) > localMeans(tth) )
            passCounter = passCounter + 1;
        end
	end
    if( passCounter >= threshCount )
        %passCounter
        if( localMeansElevs(tth) >= elev )
            passIdx = passIdx + 1;
            plotAxis(passIdx) = plotAx(tth)-localMeansElevs(tth);
            %plotAxis(passIdx) = plotAx(tth);
            passAxis(passIdx) = freqAx(tth);
        end
    end 
end



freqsAx = passAxis(1:passIdx);
plotsAx = plotAxis(1:passIdx);

figure;
stem(freqsAx,plotsAx);
arf=sprintf('Plotting %d averages for %d out of %d components, %g hz averaging, %g dB offset', passIdx, threshCount, numFreqDataObjs, width, elev);
title(arf);




