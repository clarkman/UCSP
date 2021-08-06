function [ y, filt ] = highpass(obj, cutofffreq, filtlen)
%
% obj -- input signal
% cutofffreq -- filter cutoff frequency (Hz)
% filtlen -- number of points in filter
%
% This function highpass filters its input. In the process, it loses
%   filtlen/2 points off the end.

fs = obj.sampleRate;

filt = fir1(filtlen-1, cutofffreq/(fs/2), 'high', 'scale');  % fir1 takes the filter order = length-1

y = applyFilter(obj, filt, ['Highpass @ ', num2str(cutofffreq), ' Hz'] );

