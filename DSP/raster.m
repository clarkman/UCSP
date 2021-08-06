
%***************************************************

% raster.m
% Takes an input vector and produces an NxM matrix where N is the length of the
%       raster frame and M is the number of frames.

function [timevector, outdata] = raster(indata, fs, frameRate)
%data0 = fix(2.5*fs);       %first data value for spectrogram; skip cal signal
%data = readtextfile('tapsFL.txt');

frameLen = fs/frameRate;           % Length of the frame (floating pt)
frameLen_int = fix(frameLen) + 1; % Make sure the data fits in the output array

nframes = (length(indata)-frameLen_int) / frameLen;
nframes = fix(nframes);

outdata = zeros(frameLen_int, nframes);      % initialize output array
frameStart = 1;
for i = 1: nframes
    index = round(frameStart);
    outdata(:, i) = indata(index: index + frameLen_int - 1);
    frameStart = frameStart + frameLen;
end


timevector = (1: nframes) / frameRate;
