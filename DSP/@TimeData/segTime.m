function outobj = segTime( obj, startSecOfDay, stopSecOfDay )
%
% Create a new TimeData object but with its samples bounded by startTime and
% endTime. startTime and endTime are in seconds relative to UTCref.
% Floor and ceil are used to return the maximum number of samples.  'reset'
% is optional, and if non-zero resets the DataCommon.timeOffset to zero.

outobj = -1;

if( ischar( stopSecOfDay ) )
    stopSecOfDay = 86400;
end

if( startSecOfDay < 0 || stopSecOfDay < startSecOfDay )
    warning( 'Usage::' );
    return;
end

inobj = offset(obj);

pstStart = -1/3; % Time zone correction
dayFract = (inobj.DataCommon.UTCref+pstStart) - ( floor( (inobj.DataCommon.UTCref+pstStart) ) );
if( dayFract < 0.9 )
    fileBegTime = dayFract * 86400;
else
    fileBegTime = (dayFract-1.0) * 86400;
end
fileEndTime = fileBegTime + (inobj.sampleCount/inobj.sampleRate);

if( startSecOfDay < fileBegTime )
    warning( 'Requested start time is before data start.' );
    return;
end

hangOff = 1;
if( stopSecOfDay ~= 86400 && stopSecOfDay > fileEndTime )
    hangOff = 0;
end

outobj = inobj;

% Trim beginning
numSecsAdjustStart = startSecOfDay - fileBegTime;
numSampleAdjustStart = floor( numSecsAdjustStart * inobj.sampleRate );
outobj.DataCommon.UTCref = outobj.DataCommon.UTCref + (numSecsAdjustStart/86400);
outobj.samples = outobj.samples(numSampleAdjustStart:end);


fileBegTime = ( (outobj.DataCommon.UTCref+pstStart) - ( floor( (outobj.DataCommon.UTCref+pstStart) ) ) ) * 86400;
fileEndTime = fileBegTime + (length(outobj.samples)/outobj.sampleRate);
if( hangOff && stopSecOfDay < fileEndTime )
    numSecsAdjustStop = fileEndTime - stopSecOfDay;
    numSampleAdjustStop = floor( numSecsAdjustStop * inobj.sampleRate );
    outobj.samples = outobj.samples(1:end-numSampleAdjustStop);
end


outobj = updateEndTime(outobj);
