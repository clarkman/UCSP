function outdata = plus(obj1, arg2)
%
% Note that this function does not match up the times of the two TimeData
% objects, it simply adds.

if( isa( arg2, 'TimeData') )
    outdata = obj1;
    samps1 = obj1.samples;
    samps2 = arg2.samples;
    outdata.samples = samps1 + samps2;
else
    fn = @plus;
    outdata = binaryFn(obj1, arg2, fn, 'Added');
end
