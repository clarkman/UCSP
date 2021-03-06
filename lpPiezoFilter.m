function Hd = lpPiezoFilter
%LPPIEZOFILTER Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 8.5 and the Signal Processing Toolbox 7.0.
% Generated on: 09-Oct-2015 13:38:34

% Butterworth Lowpass filter designed using FDESIGN.LOWPASS.

% All frequency values are in Hz.
Fs = 24000;  % Sampling Frequency

Fpass = 4000;        % Passband Frequency
Fstop = 6000;        % Stopband Frequency
Apass = 1;           % Passband Ripple (dB)
Astop = 60;          % Stopband Attenuation (dB)
match = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
Hd = design(h, 'butter', 'MatchExactly', match);

% [EOF]
