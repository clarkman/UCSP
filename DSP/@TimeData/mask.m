function outobjs = mask( obj, segDatenums )
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

% Five cases:

if( finDatenum <= objBegDatenum && begDatenum >= objFinDatenum ) % Nothing masked
    outobjs = cell( 1, 1 );
    outobjs{1} = inobj;
    return;
end

if( begDatenum <= objBegDatenum && finDatenum >= objFinDatenum ) % Nothing remains
    inobj.samples=[];
    outobjs = cell( 1, 1 );
    outobjs{1} = inobj;
    return;
end

if( begDatenum > objBegDatenum && finDatenum < objFinDatenum ) % Contained slice
    
    firstSegToff = (begDatenum - objBegDatenum);
    firstSegLength = ceil( firstSegToff * 86400 *  inobj.sampleRate );
    samps = inobj.samples;
    firstObj = inobj;
    firstObj.samples = samps(1:firstSegLength);
    
    scndSegToff = (finDatenum - objBegDatenum);
    scndSegStart = ceil( scndSegToff * 86400 *  inobj.sampleRate );
    scndObj = inobj;
    scndObj.samples = samps(scndSegStart:end);
    scndObj.DataCommon.UTCref = finDatenum;
    
    outobjs = cell( 2, 1 );
    outobjs{1} = firstObj;
    outobjs{2} = scndObj;
end

if( begDatenum <= objBegDatenum ) % Hangoff at start
    
    scndSegToff = (finDatenum - objBegDatenum);
    scndSegStart = ceil( scndSegToff * 86400 *  inobj.sampleRate )+1;
    scndObj = inobj;
    samps = inobj.samples;
    scndObj.samples = samps(scndSegStart:end);
    scndObj.DataCommon.UTCref = finDatenum;
    
    outobjs = cell( 1, 1 );
    outobjs{1} = scndObj;
    
end;

if( finDatenum >= objFinDatenum ) % Hangoff at end

    firstSegToff = (begDatenum - objBegDatenum);
    firstSegLength = ceil( firstSegToff * 86400 *  inobj.sampleRate );
    samps = inobj.samples;
    firstObj = inobj;
    firstObj.samples = samps(1:firstSegLength);

    outobjs = cell( 1, 1 );
    outobjs{1} = firstObj;

end;

