function y = lowpass(obj, cutofffreq, filtlen)
%
% obj -- input signal
% cutofffreq -- filter cutoff frequency (Hz)
% filtlen -- number of points in filter
%
% This function lowpass filters its input. In the process, it loses
%   filtlen/2 points off the end.

fs = obj.sampleRate;

filt = fir1(filtlen-1, cutofffreq/(fs/2), 'scale' ); % fir1 takes the filter order = length-1

y = applyFilter(obj, filt, ['Lowpass @ ', num2str(cutofffreq), ' Hz'] );

