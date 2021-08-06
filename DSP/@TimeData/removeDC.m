function outdata = removeDC(obj)
%
% Subtracts out the mean.
%
if (length(obj.samples) == 0)
    error([' TimeData object for ', obj.DataCommon.source, ' has no samples']);
end

dcvalue = double(sum(obj.samples)) / length(obj.samples);

outdata = obj;

outdata.samples = obj.samples - dcvalue;

outdata = addToHistory(outdata, ['DC Removed']);
