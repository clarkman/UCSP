function y = applyFilter(obj, filt, str)
% obj -- input signal
% filt -- Matlab FIR filter
% str  -- string to add to title field
%
% This function applies filt to its input. In the process, it loses
%   filt_length/2 points off the end.

% Initialize output to get all of the fields
y = obj;

% Apply filter
y.samples = filter(filt, 1, obj.samples);

% Throw away extra points at start due to the padding performed by the
% filter function. This adjusts the time so that it exactly matches that of
% the input signal.
y.samples = y.samples(fix(length(filt)/2)+1: length(y.samples) );

y = updateEndTime(y);

y = addToHistory(y, str);
