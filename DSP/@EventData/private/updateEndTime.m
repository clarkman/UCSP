function obj = updateEndTime(obj)
% Updates this object's timeEnd field based on the timeOffset, number of
% samples, and sampleRate.
%
obj.sampleRate
(length(obj.samples)-1)

obj.datacommon.timeEnd = obj.datacommon.timeOffset + ...
          (length(obj.samples)-1) / obj.sampleRate;


