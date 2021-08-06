function outdata = rdivide(obj1, obj2)
%
% Note that this function does not match up the times of the two TimeData
% objects.

outdata=obj1;
samps1 = obj1.samples;
samps2 = obj2.samples;
outdata.samples = samps1 ./  samps2;

