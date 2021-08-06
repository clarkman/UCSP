function mx = maxInterval(obj, firstTime, lastTime)
%
% mx = max(obj, firstTime, lastTime)
% Finds the maximum value in the object within the time window defined as firsttime to lasttime.
%  The window arguments are optional; if omitted, it uses the whole TimeData object.
% Returns mx = [amp t] where amp is the value of the max and t is its time
% relative to the UTCref

if nargin == 1
    [amp ind] = max( obj.samples );
    %firstTime = obj.DataCommon.timeOffset;
    %lastTime = obj.DataCommon.timeEnd
    %length(obj)
else
	firstIndex = 1 + floor( (firstTime - obj.DataCommon.timeOffset) * obj.sampleRate);
	lastIndex  =  1 + ceil( ( lastTime - obj.DataCommon.timeOffset) * obj.sampleRate);
	[amp ind] = max( obj.samples(firstIndex:lastIndex) );
	% Adjust for firstIndex
	ind = ind + firstIndex - 1;
end

% Convert the index back to a relative time 
time = (ind-1) / obj.sampleRate + obj.DataCommon.timeOffset;

mx = [amp time];

