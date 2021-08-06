function varargout = TimeData(varargin)
%
% This class represents evenly sampled time-domain data, time 
% units are in seconds. TimeData adds the following fields to
% DataCommon:
%
%    sampleRate -- in samples/sec
%    axisLabel  -- label for sampling axis, typically 'Time (Sec)'
%    valueType  -- type of sample values, e.g. 'Amplitude' or 'Phase'
%    valueUnit  -- unit of measure for sample values, e.g. 'Counts' or
%       'Degrees'
%    samples    -- samples evenly-spaced in time
%    
% TimeData class constructor has at present, six forms:
%
%   1. obj = TimeData;  :: A default TimeData object.
%
%   2. obj = TimeData( sourceTimeDataObject )  :: Copy Constructor
%
%   3. obj = TimeData( sourceFileName )  :: A QuakeSat data object (LEGACY)
%            The sourceFileName can be with or without the .raw.txt suffix. 
%
%   4. obj = TimeData( sourceFileName, type ) :: All types of files, the
%            "type" indicates which loader will be used. %The argument 
%            "type" is rigidly checked.  The accepted types at present are:
%
%            'quakesat' - The QuakeSat time data object.
%
%            'dataq' - XXX Clark Sample Rate is assumed, may need to set.
%
%            'eqtracker' - Ground data system.
%
%            'ma' - Thirteen channels of ma indices.
%
%   5. obj = TimeData( sourceFileName, type, annotation )  :: All files,
%            annotated.  Same as the 2 arg form above, but adds title
%            anotations.  "annotation" is appended to the sourceFileName 
%            after the '|' character, and is used to annotate plots.  If
%            the string passed is 'HdrOnly', then the TimeData object
%            returned has only the header intact, and only these fields:
%                - sampleRate
%                - sampleCount
%                - source
%                - UTCref
%
%   5a. obj = TimeData( sourceFileName, 'qm', colNumber ) 
%           = TimeData( TimeDataObj, 'qm', colNumber )  
%            This is the method of getting qm data.
%
%   6. obj = TimeData(baseObject, timeSamples, sampleRate) :: New data (LEGACY)
%            baseObject  -- a DataCommon object used as the basis for 
%            UTCref, timeOffset, source, etc. fields
%            timeSamples -- the actual time data
%            sampleRate --  in samples per second
%            The valueType and valueUnit fields default to, Amplitude 
%            and Counts; modify these after construction if they are 
%            not appropriate.
%
% This arrangement evolved out of usage, and has been upgraded to a general
% structure.  Form numbers four and five are the "real deal."  Loading can 
% also be done via routines such as:
%
% obj = remakeNSDCCFile( obj, filename );
% -or-
% obj = makeNSDCCTimeData( filename );

% Create the default
classname = 'TimeData';
outObj = makeDefault( classname );

switch nargin
    
case 0 
    varargout{1} = outObj;
    outObj = updateEndTime(outObj);
    
case 1
    if( isa(varargin{1}, classname) )
        % if single argument of this class, return it (copy constructor)
        obj = varargin{1}; 
        varargout{1} = obj;
    elseif( isa(varargin{1}, 'char') ) % Legacy choice
        varargout{1} = selectType( outObj, varargin{1}, 'quakesat', '' );
    else
        constructorError( classname, 1 );
    end
    
case 2 % Pick a format, any format ...
    if( isa(varargin{1}, 'char') && isa(varargin{2}, 'char') )
        varargout{1} = selectType( outObj, varargin{1}, varargin{2}, '' );
    else
        constructorError( classname, 2 );
    end
        
case 3 % Pick a format, any format, with annotation ...
    if( isa(varargin{1}, 'char') && isa(varargin{2}, 'char') && isa(varargin{3}, 'char') )
        varargout{1} = selectType( outObj, varargin{1}, varargin{2}, varargin{3} );
    elseif( (isa(varargin{1}, 'char') || isa(varargin{1}, classname) ) && isa(varargin{2}, 'char') && isnumeric(varargin{3}) )
        %All of this handles qm files.
		switch varargin{2} 
		case 'dataq'
            varargout{1} = selectType( outObj, varargin{1}, varargin{2}, varargin{3} );
		case 'hk'
            varargout{1} = selectType( outObj, varargin{1}, varargin{2}, varargin{3} );
		case 'qm'
            if( varargin{3} < 4 || varargin{3} > 43 )
                msg=['Column number must be 4-43! Yours: ',sprintf('%d',varargin{3})];
                error( msg );
            end
            if( isa(varargin{1}, classname) )
                obj = varargin{1}; % Accept what is (it either has samples or it don't)
            else
                obj = TimeData( varargin{1}, 'quakesat', 'HdrOnly' ); % Don't need samples
            end
            % Open and select on column of data
            varargout{1} = remakeQMFile( obj, varargin{3}, 'chop' ); 
            % NOTE: This form of the function truncates the first 60, and
            % last 60 seconds (pad).  The form below retains the pad:
            % remakeQMFile( varargin{1}, varargin{3}, 'keep' );
		otherwise
			msg = ['Type unknown: ',type,'. Default object created.'];
			warning( msg );
			obj = inObj;
		end             
    elseif( isa(varargin{1}, classname) && isnumeric(varargin{2}) && isnumeric(varargin{3}) )
        % Legacy choice
        parent = DataCommon(varargin{1});
        
        % Fill in object's fields, in the correct order
        obj.sampleRate = varargin{3};
        obj.sampleCount = 0;
        obj.axisLabel = 'Time (Sec)';
        obj.valueType = 'Amplitude';
        obj.valueUnit = 'Counts';
        obj.samples = varargin{2};
        obj = class(obj, classname, parent);
        varargout{1} = obj;
    else
        constructorError( classname, 3 );
    end
    
case 4 % Pick a format, any format, with annotation ...
    if( isa(varargin{1}, 'char') && isa(varargin{2}, 'char') && isnumeric(varargin{3}) && isnumeric(varargin{4}) )
        obj = inputWinDaQ( inObj, filename, varargin{3}, varargin{4} );
    else
        constructorError( classname, 3 );
    end
    
otherwise
    error('Bad qty. of input arguments')
end


if( ~isa(varargout{1}, classname)  && ~iscell(varargout{1}) )
    varargout{1} = outObj;  % Default in all cases.
end

%______________________________________________ end of constructor





function constructorError( classname, argCount )
msg = ['Wrong type of input arguments for ',sprintf('%d',argCount),' arg ',classname,' constructor!!']
error( msg ); 



function obj = makeDefault( classname )
parent = DataCommon;
obj.sampleRate = 1;
obj.sampleCount = 0;
obj.axisLabel = 'Time (Sec)';
obj.valueType = 'Amplitude';
obj.valueUnit = 'Counts';
obj.samples = [];
obj = class(obj, classname, parent);

