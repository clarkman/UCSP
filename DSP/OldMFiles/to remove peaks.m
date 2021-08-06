start_peak = 1539;
end_peak = 9940;
peak_rate = 10;
fs = 3000;
search_window = 1;
filter_window = 5;
y = remove_peaks(lowpass_data, start_peak, end_peak, peak_rate, fs, search_window, filter_window);
