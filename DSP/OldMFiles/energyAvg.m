function outdata = energyAvg(indata, fs, timeConstant, plotTitle)
% Performs a simple moving average of the energy in indata
% outdata is time lagged with respect to indata by npoints-1, or
% approximately the time constant
%
%    The output is in dB relative to the input. E.g., if the indata is in
%  counts, the output is in dB-counts.
%    If no output is specified, the data is plotted.

nptsToAvg = fs * timeConstant;    % Number of points to average
nptsToAvg = fix(nptsToAvg) + 1;   % round up

temp = removeDC(indata);        % Remove the DC level before squaring

temp = temp .^ 2;               % Square the input points

outlen = length(indata) - nptsToAvg + 1;
outdata = zeros(outlen, 1);

outdata(1) = sum(temp(1: nptsToAvg));

for i = 2: outlen
    outdata(i) = outdata(i-1) - temp(i-1) + temp(i-1+nptsToAvg);
end

outdata = outdata / nptsToAvg;        % Average

% Convert to dB
outdata = 10*log10(outdata);

if (nargout == 0)
    timeaxis = nptsToAvg/fs : 1/fs : length(indata)/fs;
    figure;
    plot(timeaxis, outdata);
    axis xy;
    xlabel('Time (seconds)');
    ylabel('Energy (dB)');
    figtitle = ['Averaging over ', num2str(timeConstant), ' sec.'];
    if (nargin == 4)
        figtitle = [figtitle, ', ', plotTitle];
    end
    title(figtitle);
    grid on;
end
