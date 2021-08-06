function outObj = maskEvents( inObj, mask )
%
% $Id: maskEvents.m,v 64c76fa2aa13 2013/11/11 21:04:45 qcvs $
%
% inObj is an EventData object
% Mask is an nx2 array of datenums
%

eventTable = getEvents(inObj);

numEvents = size(eventTable);
if ~numEvents
  outObj = inObj;
  warning( 'Empty EventData object supplied, nothing to mask!!' );
  return;
end

if isempty( mask )
  outObj = inObj;
  warning( 'Empty mask supplied' );
  return;
end

sz = size( mask );
if sz(2) ~= 2
  outObj = inObj;
  warning( sprintf( 'Malorformed mask supplied SB: nx2 is: %dx%d', sz(1), sz(2) ) );
  return;
end

outEvents = eventTable;
outEvents(:,:) = 0;
numPassed = 0;
eTimes = timeArray( inObj );

for evt = 1 : numEvents

  % Case 1: mask starts in event time window
  fIndsStart = find( mask(:,2) >= eTimes(evt,2) & mask(:,1) < eTimes(evt,2) & mask(:,1) >= eTimes(evt,1) );
  if ~isempty( fIndsStart )
    continue;
  end

  % Case 2: mask ends in event time window
  fIndsEnd = find( mask(:,1) <= eTimes(evt,1) & mask(:,2) < eTimes(evt,2) & mask(:,2) >= eTimes(evt,1) );
  if ~isempty( fIndsEnd )
    continue;
  end

  % Case 3: mask starts before event time window and ends after event time window (ie encompasses the whole time window)
  fIndsAll = find( mask(:,1) <= eTimes(evt,1) & mask(:,2) > eTimes(evt,2) );
  if ~isempty( fIndsAll )
    continue;
  end

  % Case 4: if outage is contained completely in the time window (unlikely)
  fIndsInside = find( mask(:,1) >= eTimes(evt,1) & mask(:,1) < eTimes(evt,2) & mask(:,2) >= eTimes(evt,1) & mask(:,2) < eTimes(evt,2) );
  if ~isempty( fIndsAll )
    continue;
  end

  numPassed = numPassed + 1;
  outEvents( numPassed, : ) = eventTable( evt, : );

end

outEvents = outEvents( 1:numPassed, : );
outObj = inObj;
outObj = setEvents( outObj, outEvents );

