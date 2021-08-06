% MAKESPEC.M
% Generates a spectragram 
% data samples must be in variable "data"

SAMPLING_RATE = 4000;			% Samples per second
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
