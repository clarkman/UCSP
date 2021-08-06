function timeaxisvec = getTAxis( obj )


siz = size( obj.samples );
UTCref = obj.DataCommon.UTCref;


if 0 % Do PST
    timeZoneOff = -1/3;
else
    timeZoneOff = 0;
end    



timefirst = obj.DataCommon.timeOffset;  % zeroed by offset, but left intact deliberately
interval = 1 / obj.sampleRate;
timelast =  timefirst + (siz(2)-1)*interval;
timeaxisvec = timefirst: interval: timelast;
timeaxisvec = timeaxisvec ./ 86400;

timeaxisvec = timeaxisvec + UTCref + timeZoneOff;
