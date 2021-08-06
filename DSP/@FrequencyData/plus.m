function outdata = plus(obj1, obj2)
%
% Note that this function does not match up the times of the two TimeData
% objects.

outdata=obj1;
outdata.samples = obj1.samples + obj2.samples;

