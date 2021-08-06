function outdata = times(obj1, arg2)
% Element-wise multiplication
% Note that this function does not match up the times or frequencies of the two FrequencyTimeData
% objects.

outdata = obj1;

if isa(arg2, 'FrequencyTimeData')
    outdata.samples = obj1.samples .* arg2.samples;
    
    outdata = addToTitle(outdata, ['Multiplied by ', arg2.DataCommon.source]);
    
else
    outdata.samples = obj1.samples .* arg2;
    
    if length(arg2) == 1
        outdata = addToTitle(outdata, ['Multiplied by ', num2str(arg2)]);
    else
        outdata = addToTitle(outdata, ['Multiplied by a Sample Array']);
    end
    
end
