function outdata = times(obj1, arg2)
%
% Element-wise multiplication
% Note that this function does not match up the times of the two TimeData
% objects.

samps = obj1.samples .* arg2;

outdata = obj1;

outdata.samples = samps;
