function outobj = slice(obj, firstPt, lastPt)

% Create a new TimeData object but with its samples bounded by startTime and
% endTime. startTime and endTime are in seconds relative to UTCref.

outobj = TimeData(obj);

% XXX Clark test
%obj.DataCommon.source
%length(obj.samples)
%3*(lastPt - firstPt)

outobj.samples = obj.samples( firstPt : lastPt );

% Update start and end times
outobj.DataCommon.timeOffset = obj.DataCommon.timeOffset + (firstPt-1)/obj.sampleRate;

outobj = updateEndTime(outobj);
