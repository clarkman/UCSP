function [time, freq] = nearestPoint(obj, t1, f1)
%
% [time, freq] = nearestPoint(obj, xpt, ypt)
% 
% Finds and returns the time-freq coordinates of the data point that is
% nearest to the input time t1 and frequency f1

freqindex = f1 / obj.freqResolution;
freqindex = round(freqindex);   % Get index of nearest frequency point
freq = freqindex * obj.freqResolution;

common = obj.DataCommon;
timeindex = (t1 - common.timeOffset) * obj.sampleRate;
timeindex = round(timeindex);   % Get index of nearest frequency point
time = common.timeOffset + (timeindex / obj.sampleRate);

