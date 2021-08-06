function outObj = offset( inObj )

outObj = inObj;

outObj.DataCommon.UTCref = outObj.DataCommon.UTCref + outObj.DataCommon.timeOffset / 86400;
outObj.DataCommon.timeOffset = 0;
outObj = updateEndTime( outObj );
