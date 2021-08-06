function outObj = minus( inObj )
% Note that this function does not match up the times of the two FrequencyTimeData
% objects.

outObj = inObj;

outObj.samples = log10(inObj.samples);
    
