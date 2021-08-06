function out = undB(obj)
%
% Convert the dB relative to the input. E.g., if the input is in
%  counts, the output is in dB-counts.

out = obj;

out.samples = 10.0 .^ (obj.samples ./ 10.0);

out.valueUnit = out.valueUnit(4:end);
