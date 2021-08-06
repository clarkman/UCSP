function make1000HzWaveFile(filename)
% Notch filters out the 600 Hz and 1200 Hz tones, and
% then write the data as a .wav file.
% filename -- name of the 1000 Hz input file; can include the '.txt'
% at the end, or not.
%  The file is written to the Matalab6p5/work directory (for now)

d = TimeData(filename);

% Apply 600 Hz notch filter
d = bandstop(d, 600, 10, 1023);

% Apply 1200 Hz notch filter
d = bandstop(d, 1200, 10, 1023);

% Build the full path for the output file
outfilename = filename;
indexSuffix = length(outfilename) - 3;
if strcmp('.txt', outfilename(indexSuffix:indexSuffix+3) )
    % Remove .txt suffix
    outfilename = outfilename(1:indexSuffix-1);
end

outfilename = ['C:/MATLAB6p5/work/', outfilename, '.wav'];

% Write wav file
writeWaveFile(d, outfilename);
