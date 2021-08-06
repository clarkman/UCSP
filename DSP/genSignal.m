function timeObj = genSignal(type, length, fs, amplitude, freq, initialPhase)
%
% timeObj = genSignal(type, length, fs, amplitude, freq, initialPhase)
% type = one of:
%   'sine' sine wave with freq and initialPhase as the initial phase,
%            +/- amplitude
%   'square', square wave witrh freq and dutyCycle, +/- amplitude
%   'unipolarPulses' pulses with freq, amplitude
%   'bipolarPulses', alternating pulses with freq, amplitude alternates as
%   +amplitude, -amplitude, +amplitude, etc.
%   'impulse', a single impulse with amplitude
%   'gwn' Gaussian white noise with zero mean and standard deviation =
%           amplitude
% length = number of points in the output
% fs = sample rate in samples/sec
% freq in Hz
% initialPhase in deg.
% The output timeObj is a TimeData object containing the generated signal

% Amplitude = +/- 1 or std ddev = 1


timeObj = TimeData;
timeObj.sampleRate = fs;
timeObj.UTCref = 0;


switch type
    case 'sine'
        % Generate a sine wave
        
        % Generate time sequence of phases
        phs = [1:length]' * 2 * pi * freq ./ fs;
        phs = phs + initialPhase;
        
        timeObj.samples = sin(phs);
        timeObj.samples = timeObj.samples .* amplitude;
        timeObj.source = [num2str(freq), ' Hz sine, amp. = ', num2str(amplitude)];

    case {'gwn', 'GWN'}
        % Generate Gaussian white noise
        
        timeObj.samples = randn(length, 1);
        timeObj.samples = timeObj.samples .* amplitude;
        timeObj.source = ['GWN, std dev = ', num2str(amplitude)];
end

