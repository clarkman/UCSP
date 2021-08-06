function outdata = minus( obj1, arg2 )
%
% Does a simple element-wise subtraction 
%



if( isa( obj1, 'TimeData') && isa( arg2, 'TimeData') )
    outdata = obj1;
    samps1 = obj1.samples;
    samps2 = arg2.samples;
    outdata.samples = samps1 - samps2;
elseif( isa( obj1, 'TimeData') && isnumeric( arg2 ) )
    fn = @minus;
    outdata = binaryFn(obj1, arg2, fn, 'Subtracted');
elseif( isnumeric( obj1 ) && isa( arg2, 'TimeData') )
    outdata = arg2;
    samps1 = arg2.samples;
    outdata.samples = obj1 - samps1;
end



