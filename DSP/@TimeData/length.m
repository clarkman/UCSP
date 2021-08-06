function len = length(obj)
%
% Overloads the built-in function for TimeData objects

len = length(obj.samples);

