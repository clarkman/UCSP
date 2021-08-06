function outObj = updnSample( obj )
%
outObj = obj;
samps = obj.samples;

L = 500; M = 781;                   % Interpolation/decimation factors.
N = 24*M;
h = fir1(N,1/M,blackman(N+1));
h = L*h; % Passband gain = L
Fs = 49.9996136084;                  % Original sampling frequency: 48kHz
%n = 0:10239; % 10240 samples, 0.213 seconds long
%x  = sin(2*pi*1e3/Fs*n); % Original signal, sinusoid at 1kHz
outSamps = upfirdn(samps,h,L,M);  % 9408 samples, still 0.213 seconds


n = 0:(length(obj));
lenSamps = length(samps);
lenOutSamps = length(outSamps)

outObj.samples = outSamps(13:lenOutSamps)
outObj.sampleRate = (obj.sampleRate*L/M);

return;

% Overlay original (48kHz) with resampled signal (44.1kHz) in red.
stem(n(1:lenOutSamps)/Fs,samps(1:lenOutSamps));
hold on; 
stem(n(1:lenOutSamps-12)/(Fs*L/M),outSamps(13:lenOutSamps),'r','filled'); 
hold off;
xlabel('Time (sec)');ylabel('Signal value');
