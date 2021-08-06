function y = hipass(obj, filt)
%
% obj -- input signal
% cutofffreq -- filter cutoff frequency (Hz)
% filtlen -- number of points in filter
%
% This function highpass filters its input. In the process, it loses
%   filtlen/2 points off the end.

y = applyFilter(obj, filt, ['Highpass @ ', num2str(filt.Fpass), ' Hz'] );

