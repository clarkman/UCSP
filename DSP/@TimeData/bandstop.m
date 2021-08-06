function y = bandstop(obj, ctrfreq, stopbandwidth, filtlen)
%
% obj -- input signal
% ctrfreq -- center of stop band (Hz)
% stopbandwidth -- width of stop band (Hz)
% filtlen -- number of points in filter
%
% This function band-stop filters its input. In the process, it loses
%   filtlen/2 points off the end.


fs = obj.sampleRate;

window = [ctrfreq - stopbandwidth/2, ctrfreq + stopbandwidth/2];  % in Hz
window = window / (fs/2);  % Convert to Matlab units

filt = fir1(filtlen-1, window, 'stop', 'scale');   % fir1 takes the filter order = length-1

y = applyFilter(obj, filt, [num2str(stopbandwidth), ' Hz Bandstop @ ', num2str(ctrfreq), ' Hz'] );

