function out = getNumTimePts( obj )
% Extract and return the frequency data closest in time to atTime.
% 

sizer = size(obj.samples);

out = sizer(2);
