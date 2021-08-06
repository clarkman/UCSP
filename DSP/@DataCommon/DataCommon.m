function obj = DataCommon(varargin)
% This class is the common base class for our data objects
%  It has the following fields:
%    source     -- the source data file, e.g. 'MG150HScalif06jul1234R'
%    title      -- a plot title, based on processing history
%    UTCref     -- double; the UTC date-time at the start of the source
%                   file; in internal Matlab format, a "serial date number"
%                   that is number of days since 1-Jan-0000. Resolution is
%                   down to fractions of a second (approx. 10 usec) 
%    timeOffset -- relative time, in seconds, from UTCref to the start of
%      the data in this object. UTCref is the reference time for the start
%      of the source file, and does not change. timeOffset changes
%      according to the processing done to this object (e.g., if a
%      subsection of the object is selected).
%    timeEnd    -- end time of the data, in seconds, relative to UTCref
%    history    -- a text string with the processing history
% DataCommon class constructor.
%   Creates a DataCommon object from the args
classname = 'DataCommon';

switch nargin
    
case 0 % Build default
    obj = makeDefault( classname );
    
case 1 % Old, soon to be copy constructor only (upgrades, etc).
	if isa(varargin{1}, classname)
        % The input is an object of this type, so copy it
        obj = varargin{1};
	elseif isa( varargin{1}, 'char' )
        obj = makeDefault( classname );
        % Remake path to legal form
        [daPath daFile daExt daNote] = splitPath( varargin{1} );
        obj.source = [daFile,daExt];
	else
        error(' Invalid input to DataCommon constructor');
	end
    
otherwise
    error('Wrong number of input arguments to DataCommon constructor')
end



function obj = makeDefault( classname )
	obj.source = '';
	obj.title = '';
	obj.network = '';
	obj.station = '';
	obj.channel = '';
	obj.UTCref = 0;      % Unknown
	obj.timeOffset = 0;
	obj.timeEnd = 0;
	obj.history = [];
	obj = class(obj, classname);
