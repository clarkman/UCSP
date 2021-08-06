function outdata = whiten(obj, filtwindow)
% Whitens the spectrogram by passing the spectrum through a median filter with
% a size of filtwindow points, and subtracts the median values (since all
% of this is done in dB).
%

% Initialize output to be the same as the input
outdata = obj;

outdata.samples = medfilt1(outdata.samples, filtwindow);

outdata.samples = obj.samples - outdata.samples;

outdata = addToTitle(outdata, ['Whitened Using ', num2str(filtwindow), '-pt Median']);
