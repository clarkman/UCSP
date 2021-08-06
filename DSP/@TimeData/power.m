function outObj = power( inObj, pwr )
%
% Note that this function does not match up the times of the two TimeData
% objects.

outObj=inObj;
outObj.samples = power( inObj.samples, pwr );
