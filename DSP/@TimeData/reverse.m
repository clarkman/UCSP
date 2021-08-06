function outobj = reverse(obj)
%
% Element-wise multiplication
% Note that this function does not match up the times of the two TimeData
% objects.


outobj = obj;
outobj.samples = obj.samples(length(obj.samples):-1:1)
