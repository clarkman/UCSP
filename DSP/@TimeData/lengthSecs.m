function secs = lengthSecs(obj)
%
% Overloads the built-in function for TimeData objects

if length(obj.samples) > 0
  secs = (length(obj.samples)-1) / obj.sampleRate;
else
  secs = 0;
end

