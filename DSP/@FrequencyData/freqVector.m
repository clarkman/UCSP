function axVec = freqVector(obj)

first = 0;
interval = obj.freqResolution;
last =  (length(obj.samples)-1)*interval;

axVec = first: interval: last;