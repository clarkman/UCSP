function mx = max(obj, firstFreq, lastFreq)
%
% mx = max(obj, firstFreq, lastFreq)
% Finds the maximum value in the object within the frequency window defined as firstFreq to lastFreq.
%  The window arguments are optional; if omitted, it uses the whole FrequencyData object.
% Returns mx = [amp freq] where amp is the value of the max and freq is
% its frequency

if nargin == 1
    firstFreq = 0;
    lastFreq = (length(obj.samples) - 1) * obj.freqResolution;
end

firstIndex = 1 + floor( firstFreq / obj.freqResolution);
lastIndex  =  1 + ceil(  lastFreq / obj.freqResolution);

[amp ind] = max( obj.samples(firstIndex:lastIndex) );

% Adjust for firstIndex
ind = ind + firstIndex - 1;

% Convert the index back to a freq 
freq = (ind-1) * obj.freqResolution;

mx = [amp freq];

