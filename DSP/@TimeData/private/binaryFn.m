function outdata = binaryFn(obj1, arg2, fn, titleName)
% Note that this function does not match up the times of the two TimeData
% objects.

outdata = obj1;

% Find the common time bounds

if isa(arg2, 'TimeData')
    if obj1.DataCommon.UTCref ~= arg2.DataCommon.UTCref
        warning('UTC ref. times on the two objects are different');
    end
    
    fs = obj1.sampleRate;
    if( abs( fs - arg2.sampleRate ) > 1 )
        error('Sample rates do not match');
    end
    
    startTime = max(obj1.DataCommon.timeOffset, arg2.DataCommon.timeOffset);
    endTime = min(obj1.DataCommon.timeEnd, arg2.DataCommon.timeEnd);

    start1 = round( 1 + (startTime - obj1.DataCommon.timeOffset) * fs );
    start2 = round( 1 + (startTime - arg2.DataCommon.timeOffset) * fs );
    
    end1   = round( 1 + (endTime - obj1.DataCommon.timeOffset) * fs );
    end2   = start2 + (end1 - start1);
    
    outdata.samples = feval(fn, obj1.samples(start1:end1), arg2.samples(start2:end2) );
    outdata.DataCommon.timeOffset = startTime;

    outdata = updateEndTime(outdata);

    outdata = addToTitle(outdata, [titleName, ' ', arg2.DataCommon.source]);
    
else
    outdata.samples = feval(fn, obj1.samples, arg2);
    
    if length(arg2) == 1
        outdata = addToTitle(outdata, [titleName, ' ', num2str(arg2)]);
    else
        outdata = addToTitle(outdata, [titleName, ' a Sample Array']);
    end
    
end
