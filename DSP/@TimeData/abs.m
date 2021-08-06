function outdata = abs(obj)
%
% Take the absolute value of the input.

outdata = TimeData(obj);    % initialize output with all the same fields

% Convert to dB
outdata.samples = abs(outdata.samples);
                         
outdata = addToTitle(outdata, ['Absolute Value']);
