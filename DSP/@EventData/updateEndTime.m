function obj = updateEndTime(obj)
% Updates this object's timeEnd field based on the timeOffset, number of
% samples, and sampleRate.
%

begT = min( obj.eventTable(:,1) );
[ finT, indx ] = max( obj.eventTable(:,1) );
finT = finT + obj.eventTable(indx,2) / 86400;

obj.DataCommon.timeEnd = ( finT - begT ) * 86400;


