function outArr = timeArray( inObj )
% $Id: timeArray.m,v 64c76fa2aa13 2013/11/11 21:04:45 qcvs $

eventTable = getEvents(inObj);
numEvents = size(eventTable);
if ~numEvents(1)
  outArr = [];
  warning( 'Empty EventData object supplied, nothing to time!!' );
  return;
end

eTimes = zeros(numEvents(1),2);
eTimes(:,1) = eventTable(:,1);
eTimes(:,2) = eTimes(:,1) + eTimes(:,2) / 86400;

outArr = eTimes;
