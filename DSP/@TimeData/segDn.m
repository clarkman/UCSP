function outobj = segDn( obj, segDatenums )
%
% Create a new TimeData object but with its samples bounded by begDatenum and
% finDatenum. 'partials'  is optional.  If not supplied, 'outobj' will only
% be returned if 'begDatenum' and 'finDatenum' specify a subset of the time 
% series in 'obj' and are completely contained, ie.:
%
%   begDatenum > obj.UTCref
%
%      - and -
%
%   finDatenum < obj.UTCref + ( obj.sampleCount / obj.sampleRate ) / 8640

% A few rules ...
if( nargin ~= 2 )
    error( 'Bring two arguments or go away!' );
end
if( ~isa( obj, 'TimeData' ) )
    error( 'First argument must be a TimeData object!' );
end
if( ~isnumeric( segDatenums ) || length( segDatenums ) ~=2 )
    error( 'Second argument must be an array of two datenums!' );
end
if( segDatenums(1) >= segDatenums(2) )
    error( 'Supplied datenums are non-increasing!!!' );
else
    begDatenum = segDatenums(1);
    finDatenum = segDatenums(2);
end
minDatenum=str2datenum('2000/01/01 00:00:00.0000');
if( begDatenum < minDatenum ), error( 'Improbably early datenum' ), end;
maxDatenum=str2datenum('2050/01/01 00:00:00.0000');
if( finDatenum > maxDatenum ), error( 'Improbably tardy datenum' ), end;


% Now that we got that out of the way clear offset of our temp obj:
inobj = offset( obj );

% And compute time limts of our obj:
objBegDatenum = inobj.DataCommon.UTCref;
objFinDatenum = objBegDatenum + ( (inobj.sampleCount-1) / inobj.sampleRate ) / 86400;
if( begDatenum < objBegDatenum && finDatenum > objFinDatenum ) % Nothing remains
    outobj = inobj;
    outobj.samples=[];
end

if( begDatenum < objBegDatenum )
	begDatenum = objBegDatenum;
end;

if( finDatenum > objFinDatenum )
	finDatenum = objFinDatenum;
end;

% Compute properties of new series
begDeltaSamps = ( begDatenum - objBegDatenum ) * 86400 * inobj.sampleRate;
newSeriesLength = ( finDatenum - begDatenum ) * 86400 * inobj.sampleRate;

% Prepare output object
outobj = inobj;

outobj.samples = inobj.samples( floor(begDeltaSamps)+1 : ceil(begDeltaSamps+newSeriesLength));
outobj.DataCommon.UTCref = begDatenum;

outobj = updateEndTime( outobj );

