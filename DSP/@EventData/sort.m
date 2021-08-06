function sortedObj = sort( inObj );

sortedObj = inObj;
evts = inObj.eventTable;
sz = size(evts)
if sz(1) % else empty, ie. nothing to sort!
  sortedObj.eventTable = sortrows(evts,1);
end