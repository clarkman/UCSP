function [ outObj, ctr ] = zCent( inObj )

  tdObj = inObj;
  s = inObj.samples;
  indss = find( s ~= 8546909 );
  rems = extractRows( s, indss );
  tdObj.samples = rems;
  [ outdata, ctr ] = zeroCenter(tdObj);
  outObj = inObj;
  outObj.samples = s - ctr;
