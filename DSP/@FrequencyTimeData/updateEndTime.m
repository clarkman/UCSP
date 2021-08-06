function obj = updateEndTime(obj)
% Updates this object's timeEnd field based on the timeOffset, number of
% samples, and sampleRate.
%


obj.DataCommon.timeEnd = obj.DataCommon.timeOffset + ...
          (length(obj.samples)-1) / obj.sampleRate;


