function outObj = xferCompAvg( inObj, fftlen, numComps, deltaSecs, xferFunc )


if( length(inObj) < fftlen + numComps * deltaSecs * inObj.sampleRate )
    error( 'Time Series too short' );
end

for ith = 1 : numComps
    firstSample = deltaSecs * ith * inObj.sampleRate + 1
    finalSample = firstSample + fftlen;
    componentSpectra{ith} = xferComp( removeDC( slice( inObj, floor(firstSample), ceil(finalSample) ) ), fftlen, xferFunc );
end

outObj = componentSpectra{1};
if( numComps <= 1 ) 
    return;
end

for ith = 2 : numComps
    compObj = componentSpectra{ith};
    outObj = outObj + compObj;
end

outObj.samples = outObj.samples / numComps;
