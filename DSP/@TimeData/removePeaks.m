function y = removePeaks(obj, start_peak, end_peak, peak_rate, search_window, filter_window)
%
%function to remove periodic spiky pulses that repeat at a known rate. the
%user must id the first peak and the last peak. peaks are removed whether
%they have positive or negative values.
%
% obj = input data
% start_peak = sample number of first peak
% end_peak = sample number of last peak
% peak_rate = repetition rate of peaks (Hz)
% search_window = number of points to search on either side of the expected
%    peak position based on the peak rate
% filter_window = number of points on either side of the peak to set them to
%    zero; the peak is also set to zero.

y = obj;
abs_y = abs(y.samples);
pos_inc = y.sampleRate/peak_rate;
pos = start_peak;
search_window = round(search_window);
filter_window = round(filter_window);
while pos < end_peak + search_window
    i = round(pos);
    
    % Search for maximum
    [val, peak] = max(abs_y(i-search_window:i+search_window));
    
    % Set peak and neighboring points to zero
    center = i - search_window + peak - 1;
    y.samples(center-filter_window:center+filter_window) = 0;
    
    pos = pos + pos_inc;
end

y = addToTitle(y, [num2str(peak_rate), ' Hz Peaks Removed, 1st peak @ sample #', num2str(start_peak)]);
