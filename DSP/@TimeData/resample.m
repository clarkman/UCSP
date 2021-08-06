function outObj = resample( inObj, p, q )

if nargin ~= 3
   error( 'Usage' );
end

samps = inObj.samples;

resamps = resample( samps, p, q );

outObj = inObj;
outObj.sampleRate = inObj.sampleRate * (p/q);
outObj.samples = resamps;

