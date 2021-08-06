function varargout = EventData(varargin)
%
% This class represents events seen in data.  All data events have coordinates
% that can be represented as a tier of three parts: network, station, channel.  (So far...)
%
%  A strict format:
%
% startTime, endTime, network, station, channel, type|subtype... all simple double precision
% for speed.  This of course means that the streams that have lettered names for station and
% channels must have a canonical way to convert their names to indices.  So we have created
% an exclusive name space of three parts: network, station, and channel.  Here's how it worked
% out:
%
% Top level network file: QFDC/include/networks:
%
% cmn - 1
% bk - 2
% anss - 3
% dem - 4
% goes - 5
% quakesat - 6
% symres - 7
% kp - 8
% etc.
% 
% is accessed via networks.m.  Station and Channel indices are taken natively or by look up from 
% tables inside the stream's home directory
%
% CalMagNet uses raw sid as the station identifier, 0000-9999.  Channel identifiers are 1-8 and 
% are mapped to the names CHANNEL[1-8].
%
% Berkeley uses both station and channel lookup tables.
% 
% ANSS only has one station and channel
% 
% DEMETER not implemented yet
% 
% GOES uses satellite numers 1-15 and channel numbers 1-6
%
% Quakesat not implemented yet
% 
% Symres one channel, one station
%
% Kp also treated with one station and one channel.
% 
% EventData is the classic container, which can hold zero of more records.  It is stream-neutral,
% and all stream inclusive

% Create the default
classname = 'EventData';
outObj = makeDefault( classname );

switch nargin
    
case 0 
    varargout{1} = outObj;
    
case 1
    if( isa(varargin{1}, classname) )
        % if single argument of this class, return it (copy constructor)
        obj = varargin{1}; 
        varargout{1} = obj;
    else
        constructorError( classname, 1 );
    end

case 4

    if( isnumeric(varargin{4}) )
        sz = size( varargin{4} );
        if( sz(2) < 5 )
            constructorError( classname, 1 );
        else
            outObj.DataCommon.network=varargin{1};
            
            if isnumeric( varargin{2} )
                outObj.DataCommon.station=sprintf( '%d', varargin{2} );
            else
                outObj.DataCommon.station=varargin{2};
            end
            
            if isnumeric( varargin{3} )
                outObj.DataCommon.channel=sprintf( '%d', varargin{3} );
            else
                outObj.DataCommon.channel=varargin{3};
            end
            
            outObj.eventTable=varargin{4};
            outObj = updateTimes( outObj );
            varargout{1} = outObj;
        end
    end


otherwise
    error('Bad qty. of input arguments')
end

if( ~isa(varargout{1}, classname) )
    varargout{1} = outObj;  % Default in all cases.
end
%______________________________________________ end of constructor



function constructorError( classname, argCount )
msg = ['Wrong type of input arguments for ',sprintf('%d',argCount),' arg ',classname,' constructor!!']
error( msg ); 



function obj = makeDefault( classname )
parent = DataCommon;
obj.eventTable = zeros(0,5);
obj = class(obj, classname, parent);

