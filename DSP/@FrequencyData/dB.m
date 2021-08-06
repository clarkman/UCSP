function outdata = dB(obj)
%
% Convert the input to dB relative to the input. E.g., if the input is in
%  counts, the output is in dB-counts.

outdata = obj;    % initialize output with all the same fields

% Convert to dB
outdata.samples = 10.0*log10(obj.samples);
outdata.valueUnit = ['dB-', outdata.valueUnit];
                         
