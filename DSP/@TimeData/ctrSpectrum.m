function [outputSpectrum,varargout]  = meanSpectrum2(varargin)
%
% This function computes the spectral mean of an aribtrary number
% of TimeData objects. It can be invoked two ways:
%
% 1. Automatic FFT length. The shortest of the signals is
% found automatically, its cal signal subtracted off, and then
% this signal's length is used to fix the resolution of the FFT.
%
% meanSpect = meanSpectrum(TimeDataObj1, TimeDataObj2, ..., TimeDataObjN)
%
% 2. Specified FFT length. The last argument is supplied as the number
% of points, n, to set for the FFT. If the specified "n" is less than
% the shortest of the TimeData objects (minus cal signal), and also a 
% positive integer, the operation will be carried out.  For this usage, 
% the calling syntax is:
%
% meanSpect = meanSpectrum(TimeDataObj1, TimeDataObj2, ..., TimeDataObjN, FFTlength)
%
% After an FFT has been taken for all the data, the spectra are converted
% back to raw counts, and summed.  The average is then found by dividing
% by the number of FFTs, and converting back to dB's.

numTimeDataObjects = 0;
theFFTLength=0;
tmpTimeData=TimeData;
tmpFreqData=FrequencyData;
calSignalLength=2000;


%1. Determine extent of work.
if (isa(varargin{nargin}, 'double'))
    numTimeDataObjects = nargin-1;
    theFFTLength=fix(varargin{nargin});
    % Usage check
    if( theFFTLength <= 0 )
        error('Specified FFT length was zero or negative!')
        outputSpectrum=0;
        return;
    end
    sprintf('Using specified FFT length of : %d',theFFTLength)
    if(mod(theFFTLength,2))
        warning('Odd number of samples specified, subtracting 1');
        theFFTLength = theFFTLength - 1;
    end
else
    numTimeDataObjects = nargin;
    % Usage check
    if( numTimeDataObjects <= 0 )
        error('Not enough timedata objects!!')
        outputSpectrum=0;
        return;
    end
end


% 2. Quick check whether average must be computed.
if( numTimeDataObjects == 1 )
    sprintf('Only one timedata object specified. Returning it as the average!!')
    outputSpectrum=varargin{1};
    return;
else
    sprintf('The number of TimeData objects to be averaged is: %d',numTimeDataObjects)
end


% 3. Verify proper output argument count
if( nargout ~= numTimeDataObjects + 1 )
    error('Qty of output args must be one plus the qty of input TimeData objects!!')
    outputSpectrum=0;
    return;
end


% 4. Find/check FFT length.
if( theFFTLength > 0 )
    % 'been Specified, check for validity.
    for each = 1 : numTimeDataObjects
        tmpTimeData = varargin{each};
        if( theFFTLength > length(tmpTimeData.samples)-calSignalLength )
            %error('Specified FFT length too long!!')
            %outputSpectrum=0;
            %return;
            %alfo = tmpTimeData.samples;
            %tmpTimeData.samples = alfo(1:length(tmpTimeData.samples)-calSignalLength);
            tmpTimeData.samples = tmpTimeData.samples(1:length(tmpTimeData.samples)-calSignalLength);
            varargin{each} = zeroPad( tmpTimeData, theFFTLength );
            length(tmpTimeData.samples);
        end
    end
else
    % Automatic, compute FFT length.
    theFFTLength = length(varargin{1}.samples)-calSignalLength; 
    sprintf('length of TimeDataObj #1 = %d',theFFTLength)
    for each = 2 : numTimeDataObjects
        nextLength = length(varargin{each}.samples)-calSignalLength;
        sprintf('length of TimeDataObj #%d = %d',each,nextLength)
        if( theFFTLength > nextLength )
            theFFTLength = nextLength;
        end
    end
    if(mod(theFFTLength,2))
        theFFTLength = theFFTLength - 1;
    end
    sprintf( 'Automatically computed sample length is: %d', theFFTLength )
end


% 5. Compute spectra and mean
sum = undB(spectrum(varargin{1},theFFTLength));
%plot(sum);
sum.samples = 0;
for each = 1 : numTimeDataObjects
    sprintf('Computing spectrum #%d',each)
    tmpFreqData = spectrum(varargin{each},theFFTLength);
    varargout(each) = {tmpFreqData};
    tmpFreqData = undB(tmpFreqData);
    sum=sum+tmpFreqData;
    %damin=min(sum.samples);
end
sprintf( 'Resultant FFT length is: %d', length(sum.samples) )


% 6. Prepare output
samps = sum.samples;
for each = 1 : length(samps)
    samps(each) = samps(each) / numTimeDataObjects;
end
sum.samples = samps;
outputSpectrum = dB(sum); % cogito ergo dB
title = sprintf('Spectral Sum of %d UK2 signals, with FFT length = %d',numTimeDataObjects,length(sum.samples));
outputSpectrum.source=title;
outputSpectrum.UTCref=[];
