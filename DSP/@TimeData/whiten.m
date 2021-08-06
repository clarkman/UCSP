function outobj = whiten(obj, fftlen)
%
% Whitens by weighting by the stored spectrum. Uses an FFT with the given length. 
% 

% The foilowing response curve is in dB
freqResponse140 = ...
 [-21.8000    0.0000     
  -21.7259   60.0000
  -21.7352   65.0000
  -21.4862   70.0000
  -21.0443   75.0000
  -20.4749   80.0000
  -19.8434   85.0000
  -19.2144   90.0000
  -18.3253   95.0000
  -16.0741  100.0000
  -11.9634  105.0000
   -7.2130  110.0000
   -2.9509  115.0000
   -0.9637  120.0000
         0  125.0000
         0  130.0000
         0  135.0000
         0  140.0000
         0  145.0000
         0  150.0000
         0  155.0000
   -0.5087  160.0000
   -1.5843  165.0000
   -3.3023  170.0000
   -5.6079  175.0000
   -8.2865  180.0000
  -11.1281  185.0000
  -14.1096  190.0000
  -16.7634  195.0000
  -18.7953  200.0000
  -20.2251  205.0000
  -21.1242  210.0000
  -21.5741  215.0000
  -21.6877  220.0000
  -21.8000  250.1000];

% Invert amplitudes for whitening; 
%   Set the maximum pt to 0 dB, and all others are greater than that by 
%    the same amount they are less than the max
mx = max(freqResponse140(:,1))
freqResponse140(:,1) = mx - freqResponse140(:,1);


% Convert to linear amplitude from dB
freqResponse140(:,1) = freqResponse140(:,1) / 20;
freqResponse140(:,1) = 10 .^ freqResponse140(:,1);

% Initialize objects to be the same
outobj = obj;

fs = obj.sampleRate;

% Create interpolated frequency weightins for this FFT length
wts = interp1(freqResponse140(:,2), freqResponse140(:,1), 0: fs/fftlen : fs/2);
wts = [wts fliplr(wts(2:end-1)  )];

figure;
step = fs/fftlen;
plot(0: step :fs-step, wts);
grid on;


% Take inverse to get to time domain for fftfilt
filt = ifft(wts);
size(filt)

filt = fftshift(filt);

% Discard the imaginary part -- it should be zero but is not due to
%   calcuaton round-off
filt = real(filt);

outobj.samples = fftfilt(filt, obj.samples, fftlen); 

%hannWin = hann(fftlen);
%for m = 1 : fftlen/2 : length(obj.samples)
%    winData = hannWin .* obj.samples(m:m+fftlen-1);
    
%end

% fftfilt


outobj = addToTitle(outobj, ['Whitened for 140 Hz filter']);

