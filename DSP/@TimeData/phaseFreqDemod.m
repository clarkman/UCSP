function [phase, freq] = phaseFreqDemod(obj, centerFreq)
%
% Produces the instantaneous phase and frequency of obj, after 
%   removing the centerFreq (Hz).
% Phase demodulates and phase unwraps indata, to produce the 
%   output phase in degress, with the mean removed.
% Takes phase differences to compute the instantaneous frequency. Since
%   the phase difference is an average over the interval between two 
%   time points, the frequencies must be interpolated to get them back to
%   being sampled at the same as the phase points. The entire frequency
%   computation loses one point at the beginning of the data and one at the
%   end, so the phase is likewise reduced by two points, one at the
%   beginning and one at the end.

% Initialize objects to be the same
phase = obj;
freq = obj;

fs = obj.sampleRate;

phase.samples = demod(obj.samples, centerFreq, fs, 'pm', 1);

phase.samples = unwrap(phase.samples);

phase.samples = phase.samples - mean(phase.samples);     % remove mean

phase.samples = phase.samples/(2*pi);         % Convert to cycles

% Compute phase differences = instantaneous phase
freq.samples = diff(phase.samples);             % Phase change (cycles) per sample

freq.samples = freq.samples * fs;              % Convert to Hz

% Since this is really an average frequency over the time interval between
% two phase samples, we want to compute the frequency values at each phase
% sample by interpolating to the midpoint between two points.
%  This process loses the last frequency point.
freq.samples = (freq.samples(1:end-1) + freq.samples(2:end) ) / 2;      % Interpolate to the midpoint

phase.samples = phase.samples(2:end-1);     % Discard first and last phase point so it lines up with freq

% Shift time offset by one sample
phase = addToTimeOffset(phase, 1/fs);
freq = addToTimeOffset(freq, 1/fs);

phase = updateEndTime(phase);

phase = addToTitle(phase, ['Phase Detect @ ', num2str(centerFreq), ' Hz']);
freq = addToTitle(freq, ['Freq. Detect @ ', num2str(centerFreq), ' Hz']);

phase.valueType = 'Phase';
phase.valueUnit = 'Cycles';

freq.valueType = 'Frequency';
freq.valueUnit = 'Hz';

