function outdata = mtimes(obj1, arg2)
% Matrix multiplication is the same as element-wise multiplication.
% Note that this function does not match up the times or frequencies of the two FrequencyTimeData
% objects.

outdata = obj1;

outdata.samples = obj1.samples .* arg2;

