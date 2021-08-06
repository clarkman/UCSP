function obj = FrequencyData(varargin)
%
% This class represents evenly sampled frequency-domain data.
%  Frequency units are in Hz. The frequency of the first point is assumed
%  to be 0 Hz.
%  It has the following fields:
%    freqResolution -- in Hz/point
%    axisLabel  -- label for sampling axis, typically 'Frequency (Hz)'
%    valueType  -- type of sample values, e.g. 'Power' or 'Complex Values'
%    valueUnit  -- unit of measure for sample values, e.g. 'dB' or
%       'Counts'
%    samples    -- samples evenly-spaced in frequency
%    
% Class constructor.
%   obj = FrequencyData(baseObject, freqSamples, freqResolution)
%  baseObject  -- a DataCommon object used as the basis for UTCref,
%    timeOffset, source, etc. fields
%  freqSamples -- the actual frequency data
%  freqResolution -- the frequency resolution, in Hz per point
% The valueType and valueUnit fields default to, Power and dB; modify these
% after construction if they are not appropriate.

classname = 'FrequencyData';

switch nargin
case 0 
% if no input arguments, create a default object
    obj.freqResolution = 1;
    obj.axisLabel = 'Frequency (Hz)';
    obj.valueType = 'Power';
    obj.valueUnit = 'dB';
    obj.samples = [];
    parent = DataCommon;
    obj = class(obj, classname, parent);
case 1
    if (isa(varargin{1}, classname))
        % if single argument of this class, copy it
        obj = varargin{1};
    else
        error(['Input argument is wrong type, must be char or ', classname])
    end
case 3
    % create object
    parent = DataCommon(varargin{1});
   % parent = addToTitle(parent, 'Frequency Data');
    
    obj.freqResolution = varargin{3};
    obj.axisLabel = 'Frequency (Hz)';
    obj.valueType = 'Power';
    obj.valueUnit = 'dB';
    obj.samples = varargin{2};
    obj = class(obj, classname, parent);
otherwise
    error('Wrong number of input arguments')
end
