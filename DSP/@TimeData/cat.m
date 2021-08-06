function argJoined = cat( arg1, arg2, mean )
% 
% Joins two TimeData objects together.  
arg1
arg2

% 1. Parse arg set
if( isa(arg1,'TimeData') == 0 || isa(arg2,'TimeData') == 0 )
    error('Args error');
end

% 1a. Default
if( arg1.sampleCount == 0 )
    argJoined = arg2;
    return;
end

% 2. Rough time check (guard against short files!!)
if( arg1.DataCommon.UTCref > arg2.DataCommon.UTCref )
    error('Second argument occurs before first !!!');
end

arg1TimeEnd = arg1.DataCommon.UTCref + ( arg1.sampleCount / arg1.sampleRate ) / 86400;
if( abs( arg2.DataCommon.UTCref - arg1TimeEnd ) > 0.1 )
    warning('arg1 may be a shortened file!!! Padding');
    numTotalSamples = ( arg2.DataCommon.UTCref - arg1.DataCommon.UTCref ) * 86400 * arg1.sampleRate;
    length(arg1)
    arg1 = zeroPad( arg1, floor(numTotalSamples), 2^23 );
    length(arg1)
end


argJoined = arg1;
clear arg1;

argJoined.samples = [ argJoined.samples' arg2.samples' ]';

argJoined = updateEndTime( argJoined );
