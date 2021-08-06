function outObj = empty( inObj )

tmpObj = inObj;
sz = size(tmpObj.eventTable);
clear tmpObj.eventTable;
tmpObj.eventTable = zeros(0, sz(2));
tmpObj.DataCommon.timeEnd = 0;

outObj = tmpObj;
