function outputBins = compareBins(varargin)
%
% This function pulls the spectral strength
% for any arbitrary number of FrequencyData Objects
% and returns them in an array.
%
% The calling syntax is 
% outputBins = compareBins(FreqDataObj1, FreqDataObj2, ..., FreqDataObjN, frequency)

%1. Determine extent of work.
numFreqDataObjects = 0;
frequencyResolution = 0;
numFrequencyBins = 0;
binNumber = 0;
frequency=0;
theSample=0;

if (isa(varargin{nargin}, 'double'))
    numFreqDataObjects = nargin-1;
    frequency = varargin{nargin};
    if( frequency < 0 )
        outputBins = 0;
        return;
    end
else
    outputBins = 0;
    error('Last argument must be frequency!!');
    return;
end

% If ALL are not frequency data objects, bail.
tmpFreqData = FrequencyData;
for count = 1 : numFreqDataObjects
	if( isa(varargin{count}, 'FrequencyData') )
       tmpFreqData = varargin{count};
       % echo source name
       %FrequencyDataObject = sprintf('source = %s',tmpFreqData.classname,tmpFreqData.source);
       %display(FrequencyDataObject);
	else
        outputBins = 0;
        return;
	end
end

baseObject = varargin{1};
frequencyResolution = baseObject.freqResolution;
numFrequencyBins = length(baseObject.samples);
binNumber = round(frequency/frequencyResolution)+1;

% If ALL Frequency Data Objects do not have the same count, etc.
% BAIL
for count = 1 : numFreqDataObjects
    tmpFreqData = varargin{count};
	if( frequencyResolution ~= tmpFreqData.freqResolution )
        outputBins = 0;
        return;
	end
	if( numFrequencyBins ~= length(tmpFreqData.samples) )
        outputBins = 0;
        return;
	end
end


% Happiness.  All is ready, and correctly specified.

% Create output array, one per object
outputBins = (1:numFreqDataObjects);
for outr = 1 : numFreqDataObjects
    tmpFreqData = varargin{outr};   
    freqArray = tmpFreqData.samples;
    theSample = freqArray(binNumber);
    % For DEBUGGING outputBins(outr) = theSample;
    %outputBins(outr) = 10^(theSample/10);
    outputBins(outr) = theSample;
end

binFrequency = (binNumber-1)*frequencyResolution
frequencyResolution

