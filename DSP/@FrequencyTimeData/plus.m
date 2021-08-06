function outdata = minus(obj1, arg2)
% Note that this function does not match up the times of the two FrequencyTimeData
% objects.

outdata = obj1;


if isa(arg2, 'FrequencyTimeData')
    outdata.samples = obj1.samples + arg2.samples;
    
    outdata = addToTitle(outdata, ['Added ', arg2.DataCommon.source]);
    
else
    outdata.samples = obj1.samples + arg2;
    
    if length(arg2) == 1
        outdata = addToTitle(outdata, ['Added ', num2str(arg2)]);
    else
        outdata = addToTitle(outdata, ['Added a Sample Array']);
    end
    
end
