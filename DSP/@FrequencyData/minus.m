function outdata = minus( obj1, arg2 )
%
% Does a simple element-wise subtraction 
%



if( isa( obj1, 'FrequencyData') && isa( arg2, 'FrequencyData') )
    outdata = obj1;
    samps1 = obj1.samples;
    samps2 = arg2.samples;
    outdata.samples = samps1 - samps2;
end



