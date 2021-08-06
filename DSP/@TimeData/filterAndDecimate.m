function outdata = filterAndDecimate(obj, nfactor)
%
% Performs a lowpass filter combined with a 1-out-of-nfactor decimation of the samples in the input
% obj.
%

% Initialize output to be the same as the input
outdata = obj;

filtlen = 127;

outdata.samples = decimate(outdata.samples, nfactor, filtlen, 'fir')  ;

outdata.sampleRate = outdata.sampleRate / nfactor;

outdata = updateEndTime(outdata);

outdata = addToTitle(outdata, ['Decimated by ', num2str(nfactor)]);
