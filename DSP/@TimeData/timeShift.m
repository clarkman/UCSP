function outobj = timeShift(obj, deltatime)
%
% outobj = timeShift(obj, deltatime);
% Time shifts the input object by adding the specified deltatime (sec).

    
% Initialize objects to be the same
outobj = obj;

outobj.DataCommon.UTCref = outobj.DataCommon.UTCref + deltatime/86400;

outobj = updateEndTime(outobj);

outobj = addToTitle(outobj, ['Shifted by ', num2str(deltatime), ' sec']);
