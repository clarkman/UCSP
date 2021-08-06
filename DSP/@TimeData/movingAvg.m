function outdata = movingAvg(obj, timeConstant)
%
% Performs a simple moving average of the samples in obj, using the
% timeConstant (in sec.) to determine the number of points to average.
% outdata is time lagged with respect to the input
%
outdata = TimeData(obj);    % initialize output with all the same fields

nptsToAvg = obj.sampleRate * timeConstant;    % Number of points to average
nptsToAvg = fix(nptsToAvg) + 1;   % round up

% Perform the moving average
outdata.samples  = filter(ones(1,nptsToAvg)/nptsToAvg, 1, obj.samples);

% Discard extra points at start created by the filtering operation
outdata.samples = outdata.samples(nptsToAvg:length(outdata.samples));

% Adjust the time offset to be centered within the averaging window
outdata.DataCommon.timeOffset = outdata.DataCommon.timeOffset + ...
                                 0.5 * (nptsToAvg-1) / outdata.sampleRate;
outdata = updateEndTime(outdata);

outdata = addToTitle(outdata, ['Averaged over ', num2str(timeConstant), ' sec']);

