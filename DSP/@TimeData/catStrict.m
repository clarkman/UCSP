function argJoined = catStrict( arg1, arg2, gapTol )
% 
% Joins two TimeData objects together.  

% 1. Parse arg set
if( isa(arg1,'TimeData') == 0 || isa(arg2,'TimeData') == 0 )
    error('Args error');
end


% 2. Rough time check (guard against short files!!)
if( arg1.DataCommon.UTCref > arg2.DataCommon.UTCref )
    error( [ 'Second argument occurs before first !!! arg1: ' datenum2str( arg1.DataCommon.UTCref ), ' arg2: ', datenum2str( arg1.DataCommon.UTCref ), ] );
end

% Now test time match ....
arg1TimeEnd = endTime( arg1 );

if nargin < 3
  gapTol = 30.0;
end

if( abs( arg2.DataCommon.UTCref - arg1TimeEnd ) > gapTol/86400 )
    error( [ 'arg1 may be a shortened file!!! ' sprintf( '%f', arg2.DataCommon.UTCref - arg1TimeEnd ), ' should be less than : 2.3148e-04' ] );
end

argJoined = arg1;
argJoined.sampleRate = ( arg1.sampleRate + arg2.sampleRate ) / 2;
argJoined.samples = [ argJoined.samples' arg2.samples' ]';
argJoined = updateEndTime( argJoined );
