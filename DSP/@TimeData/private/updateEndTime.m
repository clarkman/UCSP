function obj = updateEndTime(obj)
% Updates this object's timeEnd field based on the timeOffset, number of
% samples, and sampleRate.
%



obj.sampleCount = length( obj.samples );

if( obj.sampleCount == 0 )
  obj.DataCommon.timeEnd = 0;
else
  obj.DataCommon.timeEnd = obj.DataCommon.timeOffset + (length(obj.samples)-1) / obj.sampleRate;
end


