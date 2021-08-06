function outObj = cloneEmpty( inObj )
% Skips copying samples for efficiency

outObj = TimeData;

outObj.DataCommon = inObj.DataCommon;

outObj.sampleRate = inObj.sampleRate;

outObj = updateEndTime( outObj );
