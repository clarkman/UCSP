function outdata = zerocrossings(indata, fs)
%  Finds all zero crossings in indata. outdata contains the time of each
%  zero crossing.
%  Uses interpolation to get an accurate estimate for each zero crossing.

outdata = zeros(length(indata), 1);

lastpt = indata(1);

outcount = 0;
for i = 2: length(indata)
    if (lastpt * indata(i) <= 0 & indata(i) ~= 0)
        % Add a zero crossing
        outcount = outcount + 1;
        time = ( i-1 + abs(lastpt/(lastpt - indata(i)) ) ) / fs;
        outdata(outcount) = time;
    end
    lastpt = indata(i);
end

outdata = outdata(1:outcount);