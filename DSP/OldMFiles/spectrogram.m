datafile = textread('MG1000HCDC06Aug2238R.txt');           %ingest file
datacolumn = 2;  %number of column with data (usually 2 when ingested from server or 7 when from a .prn file)
data0 = 7200;       %first data value for spectrogram
data = datafile(data0:length(datafile),datacolumn);
%n=1024;         %length of discrete Fourier transorms
%fs = 3000;       %sampling rate
%figure;
%SPECGRAM(data,n,fs,hann(n),n/2)

%***************************************************

% MAKESPEC.M
% Generates a spectragram 
% data samples must be in variable "data"

SAMPLING_RATE = 3000;			% Samples per second
DELTAF = 10;						% Hz
DATA = data;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NFFT = round(((SAMPLING_RATE/2/DELTAF)-1)*2);

[B, F, T] = specgram(DATA,NFFT,SAMPLING_RATE);
OUT = 20*log10(abs(B));

figure;
imagesc(T,F,OUT);
axis xy;
colormap(jet);
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');


fprintf(sprintf('Frequency resolution: %2.1f\n',F(2)-F(1)));
fprintf(sprintf('Time resolution: %2.3f\n',T(2)-T(1)));