function outdata = times(obj1, arg2)
%
% Element-wise multiplication
% Note that this function does not match up the times of the two TimeData
% objects.

fn = @times;
outdata = binaryFn(obj1, arg2, fn, 'Multiplied by');
