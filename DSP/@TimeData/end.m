function e = end(obj, index, numindices)
%
% Defines end for TimeData objects.

e= length( obj.samples ); % XXX Clark, standard below worked noT.
%e = end((obj.samples), index, numindices);

