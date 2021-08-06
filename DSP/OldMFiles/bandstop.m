function y = bandstop(input, ctr_freq, width, fs, length)
% input -- input signal
% ctr_freq -- center of notch (Hz)
% width -- width of notch (Hz)
% fs -- sample rate
% length -- number of points in filter
%
% This function band-stop filters its input. In the process, it shifts the
%   input by length/2, losing that many points off the end. The first
%   length/2 points are the result of processing zeros before the input
%   data starts.

window = [(ctr_freq-width/2)/(fs/2) (ctr_freq+width/2)/(fs/2)];
filt = fir1(length, window, 'stop');
filt = filt / sum(filt);            % scale filter to unity gain
y = filter(filt, 1, input);
