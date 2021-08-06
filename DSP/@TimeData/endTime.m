function endDatenum = endTime( inObj )

endDatenum = inObj.DataCommon.UTCref + ( (inObj.sampleCount-1) / inObj.sampleRate + inObj.DataCommon.timeOffset ) / 86400;

