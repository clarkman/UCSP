function outObj = setEvents(inObj,newEvents)
%  $Id: setEvents.m,v d4e01bc08f7c 2013/10/28 18:54:34 qcvs $

outObj = empty( inObj );

outObj.eventTable = newEvents;

if( ~isempty(newEvents) )
  outObj.DataCommon.UTCref = min( newEvents(:,1) );
  [ val, ind ] = max( newEvents(:,1) );
  outObj.DataCommon.timeEnd = val * 86400 + newEvents(ind,2);
end

