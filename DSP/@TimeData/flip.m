function outObj = flip( inObj )

samps = inObj.samples;
samps = rot90( samps );
samps = rot90( samps );
outObj=inObj;
outObj.samples = samps;
