function outdata = rdivide(obj1, obj2)
%
% Note that this function does not match up the times of the two TimeData
% objects.

if( isa( obj1, 'FrequencyData') && isa( obj2, 'FrequencyData') )
  outdata=obj1;
  samps1 = obj1.samples;
  samps2 = obj2.samples;
  outdata.samples = samps1 ./  samps2;
else
  outdata=obj1;
  samps1 = obj1.samples;
  outdata.samples = samps1 ./ obj2;
end
