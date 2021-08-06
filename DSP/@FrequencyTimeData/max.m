function [maximum ind] = max(obj)
%
% mx = max(obj, firstTime, lastTime)
% Finds the maximum value in the object within the time window defined as firsttime to lasttime.
%  The window arguments are optional; if omitted, it uses the whole TimeData object.
% Returns mx = [amp t] where amp is the value of the max and t is its time
% relative to the UTCref

[maximum ind] = max( obj.samples );


