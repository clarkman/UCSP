function [peaks,threshObj,variances,widths] = detectPeaks2(obj, detThresh)
%
% y = detectPeaks2(obj, detThresh)
% Uses median filtering to find peaks.

% Compute one hertz sliding average as local "noise" floor
% 5. Compute average way points
FFTPoints=obj.samples;
numFFTPoints = length(obj);
binsPerHertz = 1.0 / obj.freqResolution;
halfWidth = 1.0/2;
numBinsWide = halfWidth * binsPerHertz;
numBinsWide = floor(numBinsWide)+1; % Round UP.
meanN = numBinsWide + numBinsWide + 1;
sumN = 0;

firstRunningPoint = numBinsWide + 1;
lastRunningPoint = numFFTPoints - numBinsWide;
sprintf('Averages will be run from bin %d to bin %d!', firstRunningPoint,lastRunningPoint)

thresh=FFTPoints;
length(thresh)
for nth = 1:numFFTPoints
    thresh(nth)=100.0; % Set high to elimate non-averaged
end


doNewAlgorithm = 0;
if doNewAlgorithm == 0
    artl=cleanTones(obj);
    DaTones = artl.samples;
    thresh = medfilt1(DaTones,80*numBinsWide,5000)+ detThresh;
    frequ=artl.samples;
    lengthOfSum = length(obj);
	for qth = 1:lengthOfSum
	  frequ(qth)=(qth-1)*obj.freqResolution;
	end
    begTrunc = 2000;
    endTrunc = 500;
    [Pa,Sa]=polyfit(frequ(begTrunc:end-endTrunc),thresh(begTrunc:end-endTrunc),7);
	
    for seth = 1 : lengthOfSum
    % freqquu = Pa(1)*frequ(seth)^8 + Pa(2)*frequ(seth)^7 + Pa(3)*frequ(seth)^6 + Pa(4)*frequ(seth)^5 + Pa(5)*frequ(seth)^4 + Pa(6)*frequ(seth)^3 + Pa(7)*frequ(seth)^2 + Pa(8)*frequ(seth) + Pa(9);
     freqquu = Pa(1)*frequ(seth)^7 + Pa(2)*frequ(seth)^6 + Pa(3)*frequ(seth)^5 + Pa(4)*frequ(seth)^4 + Pa(5)*frequ(seth)^3 + Pa(6)*frequ(seth)^2 + Pa(7)*frequ(seth) + Pa(8);
    % freqquu = Pa(1)*frequ(seth)^6 + Pa(2)*frequ(seth)^5 + Pa(3)*frequ(seth)^4 + Pa(4)*frequ(seth)^3 + Pa(5)*frequ(seth)^2 + Pa(6)*frequ(seth) + Pa(7);
     %freqquu = Pa(1)*frequ(seth)^5 + Pa(2)*frequ(seth)^4 + Pa(3)*frequ(seth)^3 + Pa(4)*frequ(seth)^2 + Pa(5)*frequ(seth) + Pa(6);
     %freqquu = Pa(1)*frequ(seth)^4 + Pa(2)*frequ(seth)^3 + Pa(3)*frequ(seth)^2 + Pa(4)*frequ(seth) + Pa(5);
     
     thresh(seth) = freqquu;
     variances(seth) = sqrt( ( FFTPoints(seth) - thresh(seth) )^2 );
     %variances(seth) = freqquu;
	end    
    
    peaks = findPeaks(FFTPoints, thresh);
    
else
    beg = 10.7/obj.freqResolution;
    ender = 10.7/obj.freqResolution;
    ender = 0;
    tailPad = 10000;
    %artl=obj;
    artl=cleanTones(obj);
    %plot(artl); % For inspection
    %figure;
	frequ=artl.samples;
	darSamps = frequ;
    frequFit=[frequ',zeros(1,tailPad)]';
    lengthOfSum = length(obj);
	for qth = 1:lengthOfSum
	  frequ(qth)=(qth-1)*obj.freqResolution;
	end
	for qth = 1:lengthOfSum+tailPad
	  frequFit(qth)=(qth-1)*obj.freqResolution;
	end
	for qth = 1:lengthOfSum
      darSamps(qth) = 10.0 ^ ( darSamps(qth) / 10.0 );
    end
    uth=mean(darSamps(end-4000:end-10))
    fitSamps = [darSamps',zeros(1,tailPad)]';
	for qth = lengthOfSum+1:(lengthOfSum+tailPad)
      fitSamps(qth) = uth;
    end
    %[Pa,Sa]=polyfit(frequFit(beg:end-ender),fitSamps(beg:end-ender),8);
    [Pa,Sa]=polyfit(frequFit(beg:end-ender),fitSamps(beg:end-ender),7);
    %[Pa,Sa]=polyfit(frequFit(beg:end-ender),fitSamps(beg:end-ender),6);
    %[Pa,Sa]=polyfit(frequFit(beg:end-ender),fitSamps(beg:end-ender),5);
    %[Pa,Sa]=polyfit(frequ(beg:end),darSamps(beg:end),4);
	freqquus = frequ;
	variances = frequ;
	for seth = 1 : lengthOfSum
    % freqquu = Pa(1)*frequ(seth)^8 + Pa(2)*frequ(seth)^7 + Pa(3)*frequ(seth)^6 + Pa(4)*frequ(seth)^5 + Pa(5)*frequ(seth)^4 + Pa(6)*frequ(seth)^3 + Pa(7)*frequ(seth)^2 + Pa(8)*frequ(seth) + Pa(9);
     freqquu = Pa(1)*frequ(seth)^7 + Pa(2)*frequ(seth)^6 + Pa(3)*frequ(seth)^5 + Pa(4)*frequ(seth)^4 + Pa(5)*frequ(seth)^3 + Pa(6)*frequ(seth)^2 + Pa(7)*frequ(seth) + Pa(8);
    % freqquu = Pa(1)*frequ(seth)^6 + Pa(2)*frequ(seth)^5 + Pa(3)*frequ(seth)^4 + Pa(4)*frequ(seth)^3 + Pa(5)*frequ(seth)^2 + Pa(6)*frequ(seth) + Pa(7);
     %freqquu = Pa(1)*frequ(seth)^5 + Pa(2)*frequ(seth)^4 + Pa(3)*frequ(seth)^3 + Pa(4)*frequ(seth)^2 + Pa(5)*frequ(seth) + Pa(6);
     %freqquu = Pa(1)*frequ(seth)^4 + Pa(2)*frequ(seth)^3 + Pa(3)*frequ(seth)^2 + Pa(4)*frequ(seth) + Pa(5);
     freqquus(seth) = freqquu;
     variances(seth) = sqrt( ( darSamps(seth) - freqquu )^2 );
     %variances(seth) = 10.0*log10(sqrt( ( darSamps(seth) - freqquu )^2 ));
	end
    vth=mean(variances(end-10:end))
    fitFreqSamps = [variances',zeros(1,tailPad)]';
	for qth = lengthOfSum+1:(lengthOfSum+tailPad)
        fitFreqSamps(qth) = vth;
    end
    [Pa,Sa]=polyfit(frequFit(beg:end-ender),fitFreqSamps(beg:end-ender),5);
	for seth = 1 : lengthOfSum
        vary = Pa(1)*frequ(seth)^5 + Pa(2)*frequ(seth)^4 + Pa(3)*frequ(seth)^3 + Pa(4)*frequ(seth)^2 + Pa(5)*frequ(seth) + Pa(6);
        %variances(seth)=10.0*log10(vary);
        %variances(seth)=vary+freqquus(seth);
        variances(seth)=10.0*log10(vary+freqquus(seth));
    end
	
 %darSamps = freqquus+vary;
	%plot(frequ,10*log10(darSamps),'r--');
	thresh =  freqquus;   
    
    peaks = findPeaks2(10.0*log10(darSamps),10.0*log10(thresh),detThresh);
end

%peaks = findPeaks(darSamps,thresh,detThresh);

% Convert indexes back to freqs
peaks(:,2) = (peaks(:,2) - 1) * obj.freqResolution;

% Sort ascending
peaks = sortrows(peaks,1);

% Reverse descending
peaks = peaks(end:-1:1,:);

% Re-condition thresh for plotting & builf FrequencyData obj.
%thresh = thresh - detThresh;
for nth = 1:firstRunningPoint-1
    thresh(nth) = 0.0;
end
for nth = lastRunningPoint+1:numFFTPoints
    thresh(nth) = 0.0;
end
threshObj=obj;

if doNewAlgorithm == 0
    threshObj.samples=thresh;
else
    threshObj.samples=10.0*log10(thresh);
end


function noisefloor = findNoiseFloor(samples)

noisefloor = median(samples);




function peaks = findPeaks(samples, thresh, detThresh)
% Find all peaks above the threshold and returns their values and indexes


% Get first difference. Will be used to tell if side of peak is increasing or decreasing 
diffs = diff(samples);

% Find all points exceeding the threshold (user value already added)
threshdata = samples > thresh;
candidatePeaks = find(threshdata);

samplesL = length(samples)
candidatePeaksL = length(candidatePeaks)

lastPeakIndex = 0;

peakvals = [];
peakindexes = [];
numpeaks = 0;

% Find positive spikes
for ii = 1 : length(candidatePeaks)
        
    % Search for local maximum
    index = candidatePeaks(ii);
    
    if index > lastPeakIndex
        % Climb up the side of the peak
        while index <= length(diffs)  &&  diffs(index) > 0
            index = index + 1;
        end
        
        if index == 1  || diffs(index-1) >= 0
            % Save peak
            numpeaks = numpeaks + 1;
            peakvals(numpeaks) = samples(index);
            peakindexes(numpeaks) = index;
            
            lastPeakIndex = index;      
        end
    end
    
end

peaks = [peakvals; peakindexes]';


function peaks = findPeaks2(samples, thresh, detThresh)
% Find all peaks above the threshold and returns their values and indexes


% Get first difference. Will be used to tell if side of peak is increasing or decreasing 
diffs = diff(samples);

% Find all points exceeding the threshold (user value already added)
lift = samples - thresh;
lengthSamples = length(samples);
%diffs = diff(lift);

threshArray=samples;
for rth = 1:length(samples)
    threshArray(rth)=detThresh;
end

threshdata = lift > threshArray;
candidatePeaks = find(threshdata);

samplesL = length(samples)
candidatePeaksL = length(candidatePeaks)

lastPeakIndex = 0;

peakvals = [];
peakindexes = [];
numpeaks = 0;

% Mark positive spikes' width.
ith = 1;
bogulus = samples;
for ii = 1 : lengthSamples
    % Search for local maximum
    index = candidatePeaks(ith);
    %ith
    if( index == ii )
        bogulus(ii) = 1.0;
        if(ith < candidatePeaksL), ith = ith + 1, end;
    else
        bogulus(ii) = 0.0;
    end
end
    
if 0

% Find positive spikes
for ii = 1 : length(candidatePeaks)-1
        
    % Search for local maximum
    index = candidatePeaks(ii);
    if( bogulus(index) ~= 1.0 )
        error('DEV test failure');
    end
    if( index > 1 && index < lengthSamples )
        if( bogulus(index-1) == 0.0 && bogulus(index+1) == 0.0 )
            %surrounded by flunks
            numpeaks = numpeaks + 1;
            peakvals(numpeaks) = samples(index);
            peakindexes(numpeaks) = index;
        end
    else
        error('Bogus tri');
    end
        
end

else

% Find positive spikes
for ii = 1 : length(candidatePeaks)
        
    % Search for local maximum
    index = candidatePeaks(ii);
    
    if index > lastPeakIndex
        % Climb up the side of the peak
        while index <= length(diffs)  &&  diffs(index) > 0
            index = index + 1;
        end
        
        if index == 1  || diffs(index-1) >= 0
            % Save peak
            numpeaks = numpeaks + 1;
            peakvals(numpeaks) = samples(index);
            peakindexes(numpeaks) = index;
            
            lastPeakIndex = index;      
        end
    end
    
end

end


peaks = [peakvals; peakindexes]';


