function out = spectrogram(obj, fftlen, fractionOverlap)
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

obj.samples=double(obj.samples);

% Careful there Eugene!  The window can hurt
%sgram = specgram(obj.samples, fftlen, fs, fftlen, overlapPts);
%sgram = specgram(obj.samples, fftlen, fs, window(@blackman,fftlen), overlapPts);
sgram = spectrogram(obj.samples,  window(@blackman,fftlen), overlapPts, fftlen, fs);
%sgram = specgram(obj.samples, fftlen, fs, window(@rectwin,fftlen), overlapPts);
%sgram = 20*log10(abs(sgram)); 

size(sgram)
isreal(sgram(1,1))
min(min(sgram))
max(max(sgram))
sgram = imag(sgram); 
size(sgram)
isreal(sgram(1,1))
sgram = sgram - min(min(sgram)) * 1.0001;
max(max(sgram))
min(min(sgram))

obj.DataCommon.UTCref = obj.DataCommon.UTCref;

newSampleRate = fs / (fftlen-overlapPts);
out = FrequencyTimeData(obj.DataCommon, sgram, newSampleRate, freqRes);

% Shift start time by 1/2 an FFT length
out = addToTimeOffset(out, (fftlen/2) / fs );

% Update the end time
sgramsize = size(out.samples);
parent = out.DataCommon;
out.timeEnd = parent.timeOffset + (sgramsize(2)-1) / newSampleRate;

colorRange(1) = min(min(sgram));
colorRange(2) = max(max(sgram));

%fprintf(sprintf('Frequency resolution: %8.2f Hz\n', freqRes));
%fprintf(sprintf('Time resolution: %9.6f sec\n', 1/newSampleRate);
