function [phase, freq] = phaseDemod(obj, centerFreq)
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

fs = obj.sampleRate;

if isreal(obj.samples)
    phase.samples = demod(obj.samples, centerFreq, fs, 'pm', 1);
else
    % Create sinusoid at -centerFreq
    phasor = [0 : length(obj.samples)-1]';
    phasor = exp(-i * phasor * 2 * pi * centerFreq / obj.sampleRate);
        
    % Downshift the signal from centerFreq to zero
    phase.samples = obj.samples .* phasor;
    
    % take the phase
    phase.samples = angle(phase.samples);
end

phase.samples = unwrap(phase.samples);

% Convert to cycles
phase.samples = phase.samples/(2*pi);         

phase = updateEndTime(phase);

phase = addToTitle(phase, ['Phase Detect @ ', num2str(centerFreq), ' Hz']);

phase.valueType = 'Phase';
phase.valueUnit = 'Cycles';
