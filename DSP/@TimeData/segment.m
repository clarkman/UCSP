function outobj = segment( obj, startTime, endTime, reset )
%
% Create a new TimeData object but with its samples bounded by startTime and
% endTime. startTime and endTime are in seconds relative to UTCref.
% Floor and ceil are used to return the maximum number of samples.  'reset'
% is optional, and if non-zero resets the DataCommon.timeOffset to zero.

%startTime
%endTime
oplk = obj.DataCommon.timeOffset;


outobj = TimeData(obj);

startTimeDelta = startTime - obj.DataCommon.timeOffset;
if startTimeDelta < 0
    startTimeDelta = 0;
end

firstPt = 1 + ceil( startTimeDelta * obj.sampleRate );

lastPt = ceil( (endTime - obj.DataCommon.timeOffset) * obj.sampleRate );
if lastPt > length(obj.samples)
    lastPt = length(obj.samples);
end

outobj.samples = obj.samples(firstPt : lastPt);

% Update start and end times
outobj.DataCommon.timeOffset = obj.DataCommon.timeOffset + (firstPt-1)/obj.sampleRate;

outobj = updateEndTime(outobj);

if( nargin == 4 && reset ~= 0 )
    outobj = offset( outobj );
end
