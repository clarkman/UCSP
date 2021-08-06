function outObj = rss( inObj1, inObj2 )

if( inObj1.DataCommon.UTCref ~= inObj2.DataCommon.UTCref )
	error( 'Times must match!!' )
end
if( inObj1.sampleCount ~= inObj2.sampleCount )
	error( 'Sample counts must match!!' )
end

samps1 = inObj1.samples;
samps2 = inObj2.samples;

sampsOut = ( samps1 .^ 2 + samps2 .^ 2 ) .^ (1/2);

outObj = inObj1
outObj.samples = sampsOut;
