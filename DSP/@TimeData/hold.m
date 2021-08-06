function outObj = hold( inObj, lothrsh, hithrsh )

samps = inObj.samples;
numSamps = length( samps )

for ith = 2 : numSamps
    if( samps(ith) > hithrsh )
        samps(ith) = samps(ith-1);
    end;
    if( samps(ith) < lothrsh )
        samps(ith) = samps(ith-1);
    end;
end

outObj = inObj;
outObj.samples = samps;

outObj = removeDC( outObj );
