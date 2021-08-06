function peaks = detectPeaks(obj, detThresh)
%
% y = removeSpikes(obj, pk_thresh, trough_thresh, pk_window, trough_window)
%function to remove single spiky impulses that exceed a magnitude threshold.
% obj = input data
% detThresh = 
% search_window = number of points to search on either side of the expected
%    peak position based on the peak rate
% filter_window = number of points on either side of the peak to set them to
%    zero; the peak is also set to zero.

% Start with a whitened spectrum
y = whiten(obj);

thresh = detThresh + findNoiseFloor(y.samples);

peaks = findPeaks(y.samples, thresh);

% Convert indexes back to freqs
peaks(:,2) = (peaks(:,2) - 1) * obj.freqResolution;

% Sort ascending
peaks = sortrows(peaks,1);

% Reverse descending
peaks = peaks(end:-1:1,:);




function noisefloor = findNoiseFloor(samples)

noisefloor = median(samples);




function peaks = findPeaks(samples, thresh)
% Find all peaks above the threshold and returns their values and indexes


% Get first difference. Will be used to tell if side of peak is increasing or decreasing 
diffs = diff(samples);

% Find all points exceeding the threshold
threshdata = samples > thresh;
candidatePeaks = find(threshdata);

lastPeakIndex = 0;

peakvals = [];
peakindexes = [];
numpeaks = 0;

% Find positive spikes
for ii = 1 : length(candidatePeaks)
        
    % Search for local maximum
    index = candidatePeaks(ii);
    
    if index > lastPeakIndex
        % Climb up the side of the peak
        while index <= length(diffs)  &&  diffs(index) > 0
            index = index + 1;
        end
        
        if index == 1  || diffs(index-1) >= 0
            % Save peak
            numpeaks = numpeaks + 1;
            peakvals(numpeaks) = samples(index);
            peakindexes(numpeaks) = index;
            
            lastPeakIndex = index;      
        end
    end
    
end

peaks = [peakvals; peakindexes]';


