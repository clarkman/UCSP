function out = meanPeaks(varargin)
%
% Analyzes a mean frequency object and its components for
% any mean peak that occurs within "width" (+/- 1/2 width).
% hertz of every frequency in the mean.
%
% hndl = meanPeaks(meanFreqDataObj,freqDataObj1,freqDataObj2,...,detThresh,width,threshCount,moniker)
%

cutoffFreq = 25.0;
samplingFrequency = 10e6/3333;
nyquistFreq = samplingFrequency/2.0;
numToDo=50;
componentsArePacked = 0;
plotPeaks = 1;

% 1. Arg count checking:
if nargin < 6
    error('Not enough inputs args!')
    return;
elseif( nargin == 6 )
    % 2nd arg s/b a cell arr
    if( isa(varargin{2},'cell') )
        fdats = varargin{2};
        numPackedComponentSpectra = numel(fdats);
        for ith = 1 : numel(fdats)
           if( isa(fdats{ith},'FrequencyData') == 0 )
               error( 'All component objects must be FrequencbbbbbyData' );
           end
        end
        componentsArePacked = 1;
        plotPeaks = 0;
    else
       error('With six args, 2nd arg must be a cell array containing Frequency data objects!')
    end
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
moniker = varargin{nargin};


% 3. Frequency range determination:
lengthOfSum = length(meanSpectrum); 
numMeanBins = lengthOfSum - 1;
maxFreq = numMeanBins * meanSpectrum.freqResolution;
meanSpectrumProps = sprintf( 'Mean spectrum has %d points, and a maximum frequency of %g hz ', numMeanBins+1, maxFreq );
display( meanSpectrumProps );


% 4. Slice determination:
width = 0;
threshCount = 0;
if( isa( varargin{nargin-1}, 'double' ) )
    threshCount = varargin{nargin-1};
else
    error('Last arg not a number - must be threshold required above mean');
    return;
end
if( threshCount < 0 )
    error('threshCounter must be a positive number!');
    return;
end

if( componentsArePacked == 1 )
    numFreqDataObjs = numPackedComponentSpectra;
else
    numFreqDataObjs = nargin - 5;
end

if( threshCount > numFreqDataObjs )
    error('threshCounter greater than count of frequency data object components!');
    return;
end

if( isa( varargin{nargin-2}, 'double' ) )
    width = varargin{nargin-2};
else
    error('Next to last arg not aq number - must frequency mean length');
    return;
end
if( width < 0 )
    error('Width must be a positive number!');
    return;
end
if( width > maxFreq )
    warning('Width greater than maximum frequency of mean spectrum!');
    width = maxFreq;
    sprintf('Width clamped to maximum frequency of mean spectrum: %g hz!', width)
end

if( isa( varargin{nargin-3}, 'double' ) )
    elev = varargin{nargin-3};
else
    error('Next to last arg not aq number - must frequency mean length');
    return;
end


% 5. Component checking
sumFlunky = meanSpectrum; % Make ahead for speed.
for rth = 2:numFreqDataObjs+1
    if( componentsArePacked == 1 )
        sumFlunky = fdats{rth-1};
    else
        sumFlunky = varargin{rth};
    end
	if( isa( sumFlunky, 'FrequencyData' ) == 0 )
        error('All components must be frequency data objects');
        return;
	end
    if( length(sumFlunky) ~= lengthOfSum )
        error('All components must be identical length');
        return;
    end
    componentComplete = sprintf('Found valid component %d',rth);
    %display(componentComplete);
    %display(sumFlunky.source);
end
allComponents = sprintf('Found %d component spectra...',numFreqDataObjs);
display(allComponents);


% 5. Compute mean spectrum properties
binsPerHertz = 1.0 / meanSpectrum.freqResolution;
halfWidth = width/2;
numBinsWide = halfWidth * binsPerHertz;
numBinsWide = floor(numBinsWide)+1; % Round UP.


% 6. Filter out 100hz & foldovers by creating mask
oneHundredHzBlot = 16;
maxPoint = max(meanSpectrum, 1399.8, 1400.2)
fourteenthHarmonic = maxPoint(2);
%fbase = fourteenthHarmonic / 14 - (meanSpectrum.freqResolution/2); % find fundamental
fbase = fourteenthHarmonic/14; % find fundamental
%fbase = 100.0 % find fundamental
fs = 1.0e7/3333; % 3000.300030003000...
fmax = 4500;
hmax = floor( fmax / fbase );
hvec = 1:hmax;
freqs = hvec * fbase;
freqs = ( freqs/fs - floor(freqs/fs) ) * fs;
for kk = 1:hmax
    if( freqs(kk) > fs )
        freqs(kk) = freqs(kk) - fs;    
    elseif( freqs(kk) > fs/2 )
        freqs(kk) = fs - freqs(kk);    
    end
end
num100hzfreqs = length(freqs);
mask = ones(lengthOfSum,1); % Create a mask to be used for tone analysis
meanSamps = meanSpectrum.samples;
for tth = 1:num100hzfreqs
    % Compute which-th bin this frequency is found in
    freqth = round(freqs(tth)*binsPerHertz+1);
    %freqth = round(freqs(tth)*binsPerHertz+1);
    %mask(freqth-3:freqth+3) = 0;
    loer=round(freqth-oneHundredHzBlot);
    if( loer < 1 )
        loer = 1;
    end
    hier=round(freqth+oneHundredHzBlot);
    if( hier > lengthOfSum )
        hier = lengthOfSum;
    end
    mask(loer:hier) = 0;
    %harmon = round(freqs(tth)/100)
    %mask(freqth-(oneHundredHzBlot*harmon):freqth+(oneHundredHzBlot*harmon)) = 0;
end
if 1

	% 6a. Filter out 50hz & foldovers by creating mask
	fiftyHzBlot = 17;
	maxPoint = max(meanSpectrum, 1349.8, 1350.2)
	twentySeventhHarmonic = maxPoint(2);
	%fbase = fourteenthHarmonic / 14 - (meanSpectrum.freqResolution/2); % find fundamental
	fbase = twentySeventhHarmonic/27; % find fundamental
	%fbase = 100.0 % find fundamental
	fs = 1.0e7/3333; % 3000.300030003000...
	fmax = 4500;
	hmax = floor( fmax / fbase );
	hvec = 1:hmax;
	freqs = hvec * fbase;
	freqs = ( freqs/fs - floor(freqs/fs) ) * fs;
	for kk = 1:hmax
        if( freqs(kk) > fs )
            freqs(kk) = freqs(kk) - fs;    
        elseif( freqs(kk) > fs/2 )
            freqs(kk) = fs - freqs(kk);    
        end
	end
	num50hzfreqs = length(freqs);
	for tth = 1:num50hzfreqs
        % Compute which-th bin this frequency is found in
        freqth = round(freqs(tth)*binsPerHertz+1);
        %freqth = round(freqs(tth)*binsPerHertz+1);
        %mask(freqth-3:freqth+3) = 0;
        loer=round(freqth-fiftyHzBlot);
        if( loer < 1 )
            loer = 1;
        end
        hier=round(freqth+fiftyHzBlot);
        if( hier > lengthOfSum )
            hier = lengthOfSum;
        end
        mask(loer:hier) = 0;
        %harmon = round(freqs(tth)/100)
        %mask(freqth-(oneHundredHzBlot*harmon):freqth+(oneHundredHzBlot*harmon)) = 0;
	end
end

% 7. Add 600 & 1200 hz to mask
maxPoint = max(meanSpectrum, 599.8, 600.2); % "600"
sixHundred = maxPoint(2);
%sixHundredBlot = 75; %orig
sixHundredBlot = 250;
loer = ((sixHundred)*binsPerHertz+1) - sixHundredBlot;
hier = ((sixHundred)*binsPerHertz+1) + sixHundredBlot;
mask(loer:hier) = 0;
maxPoint = max(meanSpectrum, 1199.8, 1200.2); % "1200"
twelveHundred = maxPoint(2);
twelveHundredBlot = 2 * sixHundredBlot;  % Seems to fit the harmonic role
loer = ((twelveHundred)*binsPerHertz+1) - twelveHundredBlot;
hier = ((twelveHundred)*binsPerHertz+1) + twelveHundredBlot;
mask(loer:hier) = 0;


% 8. Detect peaks & use mask to eliminate
%allPeaks=detectPeaks(meanSpectrum,elev);
[allPeaks,daThresh,variances] =detectPeaks2(meanSpectrum,elev);
averageSpectralVariance = mean(variances)
%allPeaks
peaks=allPeaks;
passCounter = 0;
numPeaks=length(allPeaks);
for yth = 1:numPeaks
    if( mask(floor(allPeaks(yth,2) * binsPerHertz + 1)) ~= 0 && allPeaks(yth,2) > cutoffFreq )
        passCounter = passCounter + 1;
        peaks(passCounter,:)=allPeaks(yth,:);
    end
end
peaksnew = peaks(1:passCounter,:);
numDetPeaks = length(peaksnew)
%numDetPeaks = numToDo;
%peaksnew = peaksnew(1:numToDo,:);
foldoverFreq = zeros(numDetPeaks,1);
exCntr = zeros(numDetPeaks,1);
lclCntr = exCntr;
freqBins = zeros(numDetPeaks,1);
for wth = 1:numDetPeaks
    freqbin=round(peaksnew(wth,2)*binsPerHertz+1);
    freqBins(wth) = freqbin;
    foldoverFreq(wth) = ( nyquistFreq - peaksnew(wth,2) )  +  nyquistFreq;
    meanl = meanSamps(freqbin-1);
    mean = meanSamps(freqbin);
    meanh = meanSamps(freqbin+1);
    if( meanl > mean || meanh > mean )
        msg=sprintf('bad peak %f < %f < %f', meanl, mean, meanh );    
        error(msg);    
    end
	for rth = 2:numFreqDataObjs+1
		if( componentsArePacked == 1 )
            sumFlunky = fdats{rth-1};
		else
            sumFlunky = varargin{rth};
		end
        if( sumFlunky.samples(freqbin) >= mean )
            exCntr(wth) = exCntr(wth) + 1;
        end
        if( sumFlunky.samples(freqbin) >= daThresh.samples(freqbin) )
            lclCntr(wth) = lclCntr(wth) + 1;
        end
	end
end
countr = exCntr;
localcountr = lclCntr;
freq=peaksnew(:,2);
%fre
val=peaksnew(:,1);

valRel = val;
for eeth = 1:numDetPeaks
    plotSamples(eeth) = meanSpectrum.samples(freqBins(eeth));
    localThresh=daThresh.samples(freqBins(eeth));
    if( localThresh > 0.0 )
        valRel(eeth) = plotSamples(eeth) - localThresh;
    else
        valRel(eeth) = 0.0;
    end
end

out = zeros(numDetPeaks,6);
out(:,1) = freq;
out(:,2) = val;
out(:,3) = valRel;
out(:,4) = countr;
out(:,5) = localcountr;
out(:,6) = foldoverFreq;


if plotPeaks

hold on;
plot(meanSpectrum, 'g')
hold off;


frequ=daThresh.samples;
for qth = 1:lengthOfSum
   frequ(qth)=(qth-1)*meanSpectrum.freqResolution;
end
hold on;
    plot(frequ,daThresh.samples,'r');
    %plot(frequ,variances,'r--');
hold off;

return;

% 6. Plotting components
%corder = get(gca,'ColorOrder')     % use the standard color ordering matrix
corder(1)='r'; corder(2)='m'; corder(3)='k'; corder(4)='c'; corder(5)='b'; 
cmarker(1)='d'; cmarker(2)='x'; cmarker(3)='+'; cmarker(4)='s'; cmarker(5)='v'; cmarker(6)='*'; cmarker(7)='^';
corderLength = 5;
cmarkerLength = 7;

plotSamples=val;

for rth = 2:numFreqDataObjs+1
    if( componentsArePacked == 1 )
        sumFlunky = fdats{rth-1};
    else
        sumFlunky = varargin{rth};
    end
    sumFlunkySamples = sumFlunky.samples;
    ddyy=sumFlunky.DataCommon;
    dadates(rth-1)=ddyy.UTCref;
    %dadates(rth-1)=datenum2str(ddyy.UTCref);
    for eeth = 1:numDetPeaks
        plotSamples(eeth) = sumFlunkySamples(freqBins(eeth));
    end
    hold on;
    scheme = sprintf('%s%s%s',corder(floor(mod(rth,corderLength))+1),cmarker(floor((rth-2)/corderLength)+1),':');
    %scheme2 = sprintf('%s%s',corder(floor(mod(rth,corderLength))+1),cmarker(floor(rth/cmarkerLength)+1));
    %sprintf('%s%s - %s\n',corder(floor(mod(rth,corderLength))+1),cmarker(floor(rth/cmarkerLength)+1),datenum2str(dadates(rth-1)))
    %scheme = sprintf('%s%s','r','+');
    stem(freq,plotSamples,scheme);
    %plot(freq,plotSamples,scheme2);
    alps = sprintf('%s%s - %s\n',corder(floor(mod(rth,corderLength))+1),cmarker(floor((rth-2)/corderLength)+1),datenum2str(dadates(rth-1)))
    text(1125,38-(rth-2),alps);
    hold off;
	%set(get(gcf,'CurrentAxes'),'XLim',[choppedFreqAx(1) choppedFreqAx(numChoppedBins+1)]);
	%set(get(gcf,'CurrentAxes'),'YLim',[-1000 1000]);
end


% Plotting hits
hold on;
stem(freq,plotSamples,'bo');
titl=sprintf('%d %s mean spectrum points of %d component spectra that are greater than %g dB above 20 hz median',length(freq),moniker,numFreqDataObjs,elev);
title(titl);
titl=sprintf('Frequency - hz (resolution = %g hz, num points = %g)',meanSpectrum.freqResolution,lengthOfSum);
xlabel(titl);
ylabel('dB');
set(get(gcf,'CurrentAxes'),'XLim',[0 1500.2]);
set(get(gcf,'CurrentAxes'),'YLim',[-1 40]);
% NO legend('Mean Spectrum','Threshold','12/3/2003','','Mean Peaks');
hold off;


end


return;





