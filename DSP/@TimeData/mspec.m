function [out , mag, t] = mspec(data, freqPOS, filtlength, ndec )

%   mspec.m
%
%       This function generates a very sensitive time-varying amplitude spectrum
%   from time-domain data using a matched filter (or digital antenna).  Sine waves
%   are generated at any number of specified frequencies and convolved with the data.
%   The result is filtered with a low-pass filter to remove oscillations which are 
%   an artifact of phase-matching. The resulting time series represents the 
%   amplitude of the specified frequencies changing in time.  (The exact amplitudes will not match the
%   amplitudes calculated using an FFT spectrogram, but the pattern of their variations
%   will be the same).  The time series is decimated by a factor of 200 (making it
%   sampled at 150 hz).  This decimation is not required, but since we are looking for
%   persistant tones, it looses no important information, and makes the resulting graphs
%   much easier to manipulate.
%       
%   USEAGE: [amp ,t] = mspec(data, freqPOS)
%
%   INPUTS:     data    : timedata object
%               freqPOS : vector of the desired frequencies in HZ
%  
%   OUTPUTS:    amp :   array in which each column represents amplitude at one
%                       of the desired frequencies and each row represents time
%               t :     vector of decimated times
%
%   To make a "spectrogram" of the results, use the command surf(t,freqPOS,amp,'linestyle','none');view(2)
%
%   Heidi Anderson Kuzma.  Modified Oct 4, 2004


signal=data.samples;
out = data;
deltat=1/data.sampleRate;
if nargin == 3
    lenfilt=filtlength;
else
    lenfilt=1;                              %This implementation uses 1 second matched filters
end
t=(1:length(signal))*deltat;

tfilt=deltat:deltat:lenfilt;

t=(decimate(t,ndec))';

for n=1:length(freqPOS)
    filt=sin(2*pi*tfilt*freqPOS(n));    %generate sine waves.
    amp=conv2(signal,filt','same');     %convolve filters with the timedata signal
%    amp=decimate(abs(amp),ndec);  %decimate 
    amp=decimate(amp,ndec);  %decimate 
    %Heidi orig ampd(:,n)=decimate(abs(amp),ndec);  %decimate 
end

mag = 0.0;
numAmps = length(amp);
for ith = 1 : length(amp)
    mag = mag + abs(amp(ith));
end
mag = mag / numAmps;

out.samples=amp;

