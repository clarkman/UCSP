function freqaxisvec = getTAxis( obj )

siz = size( obj.samples );


freqfirst = 0;
interval = obj.freqResolution;
freqlast =  (siz(1)-1)*interval;
freqaxisvec = freqfirst: interval: freqlast;
