function outObj = sqrt( inObj )
%
% Note that this function does not match up the times of the two TimeData
% objects.

outObj=inObj;
outObj.samples = sqrt( inObj.samples );

