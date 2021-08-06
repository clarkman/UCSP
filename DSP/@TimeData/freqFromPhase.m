function freq = freqFromPhase(obj)
%
% Produces the instantaneous frequency of a Phase obj that already has  
%  its center frequency removed.
% Takes phase differences to compute the instantaneous frequency. Since
%   the phase difference is an average over the interval between two 
%   time points, the frequencies must be interpolated to get them back to
%   being sampled at the same time as the phase points. The entire frequency
%   computation loses one point at the beginning of the data and one at the
%   end.

% Make sure that the input is a phase object
if ~strcmp(obj.valueType, 'Phase')
    error(['Input object must have valueType = "Phase"']);
end
    
% Initialize objects to be the same
freq = obj;

fs = obj.sampleRate;

% Compute phase differences = instantaneous phase
freq.samples = diff(obj.samples);             % Phase change per sample

% Convert to Hz, depending on input units
if strcmp(obj.valueUnit, 'Cycles')
    freq.samples = freq.samples * fs;
elseif strcmp(obj.valueUnit, 'Degrees')
    freq.samples = freq.samples * fs / 360;
elseif strcmp(obj.valueUnit, 'Radians')
    freq.samples = freq.samples * fs / (2*pi);
end

% Since this is really an average frequency over the time interval between
% two phase samples, we want to compute the frequency values at each phase
% sample by interpolating to the midpoint between two points.
%  This process loses the last frequency point.
freq.samples = (freq.samples(1:end-1) + freq.samples(2:end) ) / 2;      % Interpolate to the midpoint

% Shift time offset by one sample
freq = addToTimeOffset(freq, 1/fs);

freq = updateEndTime(freq);

freq = addToTitle(freq, ['Freq. Detect']);

freq.valueType = 'Frequency';
freq.valueUnit = 'Hz';

