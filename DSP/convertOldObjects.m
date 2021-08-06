function outObj = convertOldObjects( inStruct )

outObj = TimeData;

outObj.source     = inStruct.datacommon.source;
outObj.title      = inStruct.datacommon.title;
outObj.UTCref     = inStruct.datacommon.UTCref;
outObj.timeOffset = inStruct.datacommon.timeOffset;
outObj.timeEnd    = inStruct.datacommon.timeEnd;
outObj.history    = inStruct.datacommon.history;


outObj.sampleRate = inStruct.sampleRate;
outObj.axisLabel  = inStruct.axisLabel;
outObj.valueType  = inStruct.valueType;
outObj.valueUnit  = inStruct.valueUnit;
outObj.samples  = inStruct.samples;
