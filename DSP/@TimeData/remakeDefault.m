function newObj = remakeDefault( oldObj )

classname = 'TimeData';

parent = DataCommon;
newObj.sampleRate = 1;
newObj.sampleCount = 0;
newObj.axisLabel = 'Time (Sec)';
newObj.valueType = 'Amplitude';
newObj.valueUnit = 'Counts';
newObj.samples = [];
newObj = class(newObj, classname, parent);
