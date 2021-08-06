function outdata = mtimes(obj1, arg2)
%
% Matrix multiplication is the same as element-wise multiplication.
% Note that this function does not match up the times of the two TimeData
% objects.

outdata = obj1 .* arg2;

