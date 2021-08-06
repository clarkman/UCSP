function out = spectrogram2(obj, fftlen, fractionOverlap)
%
% Generates a frequency versus time spectrogram 
% 

if (length(obj.samples) == 0)
    error([' TimeData object for ', obj.DataCommon.source, ' has no samples']);
end

fs = obj.sampleRate;
freqRes = fs / fftlen;
overlapPts = fix(fractionOverlap*fftlen);

%obj = removeDC(obj)

% Careful there Eugene!  The window can hurt
%sgram = spectrogram(obj.samples, window(@hann,fftlen), fs, fftlen, overlapPts);
sgram = spectrogram(obj.samples, window(@hann,fftlen), overlapPts, fftlen, fs );
sgram = 10*log10(abs(sgram)); 

newSampleRate = fs / (fftlen-overlapPts);
out = FrequencyTimeData(obj.DataCommon, sgram, newSampleRate, freqRes);

% Shift start time by 1/2 an FFT length
out = addToTimeOffset(out, (fftlen/2) / fs );

% Update the end time
sgramsize = size(out.samples);
parent = out.DataCommon;
out.timeEnd = parent.timeOffset + (sgramsize(2)-1) / newSampleRate;

return;


dims = size( sgram );


% Log joggling
psdR = psd( obj, fftlen );
psdRsamples = psdR.samples;
%maxPsdVal = max( psdRsamples(floor(1/freqRes)) )
%minPsdVal = min( psdRsamples(5:'end') )
maxPsdVal = max( psdRsamples );
minPsdVal = min( psdRsamples );

%psdR = undB( psdR );

x = (0:psdR.freqResolution:(obj.sampleRate/2))';

%p = polyfit(x,psdR.samples,12);

numPts = (0:1:(obj.sampleRate/2))';
p = spline(x,psdR.samples, numPts);

plot( psdR );
hold on;
%plot( x, polyval(p,x), 'r' );
plot( x, ppval(p,x), 'r' );
hold off;

return;

fakeZero = minPsdVal - 10.0;
normRange = maxPsdVal - fakeZero;

if( dims(1) ~= fftlen/2+1 || dims(1) ~= length(psdR) )
    error('Size mismatch');
end

psdRNormed = psdR;
for ith = 1 : dims(1)
    psdRNormed(ith) = ( psdR(ith) - fakeZero ) / normRange;
end
%plot( psdRNormed )

sgramNormed = sgram;
for ith = 1 : dims(1)
    sgramNormed(ith,:) = sgram(ith,:) / psdRNormed(ith);
end



newSampleRate = fs / (fftlen-overlapPts);
out = FrequencyTimeData(obj.DataCommon, sgramNormed, newSampleRate, freqRes);

% Shift start time by 1/2 an FFT length
out = addToTimeOffset(out, (fftlen/2) / fs );

% Update the end time
sgramsize = size(out.samples);
parent = out.DataCommon;
out.timeEnd = parent.timeOffset + (sgramsize(2)-1) / newSampleRate;

%fprintf(sprintf('Frequency resolution: %8.2f Hz\n', freqRes));
%fprintf(sprintf('Time resolution: %9.6f sec\n', 1/newSampleRate);
