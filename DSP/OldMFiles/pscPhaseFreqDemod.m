function [phase, freq] = pscPhaseFreqDemod(indata, fs, centerFreq)
% Produces the instantaneous phase and frequency of indata, after 
%   removing the centerFreq (Hz) based on the sample rate fs (samples/sec).
% Phase demodulates and phase unwraps indata, to produce the 
%   output phase in degress, with the mean removed.
% Takes phase differences to compute the instantaneous frequency. Since
%   the phase difference is an average over the interval between two 
%   time points, the frequencies must be interpolated to get them back to
%   being sampled at the same as the phase points. The entire frequency
%   computation loses one point at the beginning of the data and one at the
%   end, so the phase is likewise reduced by two points, one at the
%   beginning and one at the end.

phase = demod(indata, centerFreq, fs, 'pm', 1);

phase = unwrap(phase);

phase = phase - mean(phase);     % remove mean

phase = phase*180/pi;         % Convert to degrees

% Compute phase differences = instantaneous phase
freq = phase(2:end) - phase(1:end-1);     % Phase change (deg) per sample

freq = freq * fs / 360;              % Convert to Hz

% Since this is really an average frequency over the time interval between
% two phase samples, we want to compute the frequency values at each phase
% sample by interpolating to the midpoint between two points.
%  This process loses the last frequency point.
freq = (freq(1:end-1) + freq(2:end) ) / 2;      % Interpolate to the midpoint

phase = phase(2:end-1);     % Discard first and last phase point so it lines up with freq



