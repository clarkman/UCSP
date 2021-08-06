function matlab16oct(filename, FFTsize)
%
% Read the files direct from the CD
%----------------------------------------------------------------
% INSTRUCTIONS
%  Call the matlab16oct function inside Matlab as follows:
%        matlab16oct(filename, FFTSize)
% where:
%        filename -- is the full path and name of the file
%        FFTsize  -- is the length of the FFT (must be a power of 2)
%
%   EXAMPLE
%   matlab16oct('D:/16 Oct Report/Background 1/MG3HXBkGrd1M11Oct0025B.txt', 512); 
%
%  IMPORTANT:  This example assumes that 'D:' is your CD drive. If not, simply change D
%  to your CD drive letter.
%
%  The path can also use backslashes instead:
%   matlab16oct('D:\16 Oct Report\Background 1\MG3HXBkGrd1M11Oct0025B.txt', 512); 
%-----------------------------------------------------------------


% Get parameters from the header part of the file
fid = fopen(filename);
if fid == -1
    error('Cannot open the file');
end
hdrlinecnt = 0;         % Count the total number of lines in the header
while 1
    tline = fgetl(fid);
    hdrlinecnt = hdrlinecnt + 1;
    if strncmp('HEADER_END', tline, 9)
        % The last line in the header
        break;
    elseif strncmp('SAMPLE_RATE', tline, 11)
        sampleRate = sscanf(tline, '%*s%*s%f');
    elseif strncmp('START_TIME', tline, 10)
        UTCref = sscanf(tline, '%*s%*s%s%c%s');
    elseif isempty(strfind(tline, '='))
        error('This file does not have the standard format.');
    end
end
fclose(fid);

% Read data samples from the file, skipping over the header
datafile = textread(filename, '%d', 'headerlines', hdrlinecnt);            
col = 1;
samples = datafile(1:length(datafile), col);



% Compute spectrogram, in dB

[spectrogram, F, T] = specgram(samples, FFTsize, sampleRate, FFTsize, 7*FFTsize/8);
spectrogram = 20*log10(abs(spectrogram));

% Offset the start time to account for FFT processing
T = T + (FFTsize/sampleRate)/2;           


% Display the spectrogram

siz = size(samples);


figure;
imagesc(T, F, spectrogram);
axis xy;

% Create tge plot title from the time and file name
%   Remove the filename extension by stripping off the last dot and everything
%   after it
titlestr = filename;
dots = strfind(filename, '.');
if dots
    titlestr = filename(1:dots(end)-1);
end
% Remove the path by finding the last slash or backslash
slashes = [strfind(titlestr, '/') strfind(titlestr, '\')];
if slashes
    titlestr = titlestr(max(slashes)+1:end);
end    
        
title([titlestr, '  ', UTCref, 'UTC']);

xlabel(['Time (seconds)', '   (', num2str(T(2)-T(1)), ' sec resolution)']);
ylabel(['Frequency (Hz)', '   (', num2str(F(2)-F(1)), ' Hz resolution)']);

colormap(jet(256));

% Turn on grid lines
grid on;

orient landscape;
