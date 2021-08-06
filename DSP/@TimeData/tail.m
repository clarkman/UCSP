function outObj = tail( inObj, discardUpTo )

samps = inObj.samples;
outObj=inObj;
outObj.samples = samps(discardUpTo:end);
