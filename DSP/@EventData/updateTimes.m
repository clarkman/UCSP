function obj = updateTimes( inObj )

obj = inObj;

obj.DataCommon.UTCref=min(inObj.eventTable(:,1));
[endDN, endDNidx] = max(inObj.eventTable(:,1));
if ~isempty(endDN)
  obj.DataCommon.timeEnd=( (endDN+inObj.eventTable(endDNidx,2)/86400) - obj.DataCommon.UTCref )*86400;
else
  obj.DataCommon.timeEnd=0;
end
    