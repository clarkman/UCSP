%  This class inherits from DataCommon and represents frequency versus time data. 
%    The frequency and time points are evenly sampled.
%  Frequency units are in Hz. The frequency of the first point is assumed
%    to be 0 Hz.
%  Time units use the DataCommon time fields.
%  This class has the following fields:
%    sampleRate -- in samples/sec
%    freqResolution -- in Hz/point
%    timeAxisLabel  -- label for time sampling axis, typically 'Time (Sec)'
%    freqAxisLabel  -- label for frequency sampling axis, typically 'Frequency (Hz)'
%    valueType  -- type of sample values, e.g. 'Power' or 'Complex Values'
%    valueUnit  -- unit of measure for sample values, e.g. 'dB'
%    samples    -- NxM array of sample values evenly-spaced in frequency
%                  and time, where N is the number of freqeuncy bins and 
%                  M is the number of time points.
%    
function obj = FrequencyTimeData(varargin)
% Class constructor.
%   obj = FrequencyTimeData(baseObject, freqTimeArray, sampleRate, freqResolution)
%  baseObject  -- a DataCommon object used as the basis for UTCref,
%    timeOffset, source, etc. fields
%  freqSamples -- the actual frequency data
%  sampleRate  -- in samples/sec
%  freqResolution -- the frequency resolution, in Hz per point
% The valueType and valueUnit fields default to Power and dB; modify these
% after construction if they are not appropriate.

classname = 'FrequencyTimeData';
outObj = makeDefault( classname );

switch nargin

case 0 
    obj = outObj;
    
case 1
    % Usage:  object = FrequencyTimeData(FrequencyTimeData_obj);
    if (isa(varargin{1}, classname))
        % if single argument of this class, return a copy of it (copy constructor)
        obj = varargin{1}; 
    else
        error(['Input argument is wrong type, must be char or ', classname])
    end
    

case 4
    % Usage:
    %   obj = FrequencyTimeData(baseObject, freqTimeArray, sampleRate, freqResolution)
    %  baseObject  -- a DataCommon object used as the basis for UTCref,
    %    timeOffset, source, etc. fields
    %  freqSamples -- the actual frequency data
    %  sampleRate  -- in samples/sec
    %  freqResolution -- the frequency resolution, in Hz per point

    % Construct object
    obj = outObj;

    inObj = varargin{1};
    obj.DataCommon.source = inObj.source;
    obj.DataCommon.network = inObj.network;
    obj.DataCommon.station = inObj.station;
    obj.DataCommon.channel = inObj.channel;
    obj.DataCommon.UTCref = inObj.UTCref;
    obj.DataCommon.timeOffset = inObj.timeOffset;
        
    obj.sampleRate = varargin{3};
    obj.freqResolution = varargin{4};
    obj.samples = varargin{2};

case 5
	% Usage:
	%   obj = FrequencyTimeData( baseObject, numFreqPts, sampleRate, numTimePts, overlapFactor )
	% Makes an empty (zero) object.
	%  baseObject  -- a DataCommon object used as the basis for UTCref,
	%    timeOffset, source, etc. fields
	%  numFreqPts -- count of frequency points
	%  numTimePts -- count of time points

	% Construct object
	obj = outObj;

	inObj = varargin{1};
	obj.DataCommon.source = inObj.source;
	obj.DataCommon.network = inObj.network;
	obj.DataCommon.station = inObj.station;
	obj.DataCommon.channel = inObj.channel;
	obj.DataCommon.UTCref = inObj.UTCref;
	obj.DataCommon.timeOffset = inObj.timeOffset;

	obj.sampleRate = varargin{3} / varargin{5};
	obj.freqResolution =  ( varargin{3} / 2 ) / ( varargin{2} - 1 );
	obj.samples = zeros( varargin{2}, varargin{4} );

otherwise
    error('Wrong number of input arguments')
end




function obj = makeDefault( classname )
parent = DataCommon;
obj.sampleRate = 1;
obj.freqResolution = 1;
obj.timeAxisLabel = 'Time (Sec)';
obj.freqAxisLabel = 'Frequency (Hz)';
obj.valueType = 'Power';
obj.valueUnit = 'dB';
obj.samples = [];
obj.colorRange = [-1, -1];  % Min Max of colors
obj = class(obj, classname, parent);


