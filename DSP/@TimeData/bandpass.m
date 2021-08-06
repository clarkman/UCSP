function y = bandpass(obj, ctrfreq, passbandwidth, filtlen)
%
% obj -- input signal
% ctrfreq -- center of pass band (Hz)
% passbandwidth -- width of pass band (Hz)
% filtlen -- number of points in filter
%
% This function passband filters its input. In the process, it loses
%   filtlen/2 points off the end.


fs = obj.sampleRate;

window = [ctrfreq - passbandwidth/2, ctrfreq + passbandwidth/2];  % in Hz
window = window / (fs/2);  % Convert to Matlab units

filt = fir1(filtlen-1, window, 'scale');   % fir1 takes the filter order = length-1

y = applyFilter(obj, filt, [num2str(passbandwidth), ' Hz Bandpass @ ', num2str(ctrfreq), ' Hz'] );

