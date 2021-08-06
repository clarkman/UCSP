function argJoined = catDays( arg1, arg2, meanCounts )
% 
% Joins two TimeData objects together.  


% 1. Parse arg set
if( isa(arg1,'TimeData') == 0 || isa(arg2,'TimeData') == 0 )
    error('Args error');
end

% 2. Rough time check (guard against short files!!)
if( arg1.DataCommon.UTCref > arg2.DataCommon.UTCref )
    error('Second argument occurs before first !!!');
end


arg1 = offset( updateEndTime( arg1 ) );
arg2 = offset( updateEndTime( arg2 ) );

arg1SampleCount = arg1.sampleCount;
arg1SampleRate = arg1.sampleRate;

arg1TimeEnd = arg1.DataCommon.UTCref + ( arg1.sampleCount / arg1.sampleRate ) / 86400;
arg2TimeEnd = arg2.DataCommon.UTCref + ( arg2.sampleCount / arg2.sampleRate ) / 86400;
gapr1 = abs( arg2.DataCommon.UTCref - arg1TimeEnd );
gapr2 = abs( ( arg2.DataCommon.UTCref + 1 ) - arg2TimeEnd );
if( gapr1 > 1.0/288.0 )
    warning('arg1 may be a shortened file!!!');
    numSecsShort = gapr1*86400;
    numSampsShort = gapr1*86400*arg1.sampleRate;
    sampees = arg1.samples;
    numSampees = length( sampees );
    meanSampees = mean( sampees );
    sampees(numSampees+1:numSampees+round(numSampsShort)) = meanSampees;
    arg1.samples = sampees;
    arg1 = offset( updateEndTime( arg1 ) );
    newNumSampsArg1 = arg1.sampleCount;
    arg1TimeEnd = arg1.DataCommon.UTCref + ( arg1.sampleCount / arg1.sampleRate ) / 86400;
    gapr1 = abs( arg2.DataCommon.UTCref - arg1TimeEnd );
    if( gapr1 > 1.0/288.0 )
        error('Arg1 Gap fix failed!');
    end
end
if( gapr2 > 1.0/288.0 )
    warning('arg2 may be a shortened file!!!');
    numSecsShort = gapr2*86400;
    numSampsShort = gapr2*86400*arg2.sampleRate;
    sampees = arg2.samples;
    numSampees = length( sampees );
    meanSampees = mean( sampees );
    sampees(numSampees+1:numSampees+round(numSampsShort)) = meanSampees;
    arg2.samples = sampees;
    arg2 = offset( updateEndTime( arg2 ) );
    newNumSampsArg2 = arg2.sampleCount;
    arg2TimeEnd = arg2.DataCommon.UTCref + ( arg2.sampleCount / arg2.sampleRate ) / 86400;
    gapr2 = abs( ( arg2.DataCommon.UTCref + 1 ) - arg2TimeEnd )
    if( gapr2 > 1.0/288.0 )
        error('Arg2 Gap fix failed!');
    end
end


argJoined = arg1;

argJoined.samples = [ arg1.samples' arg2.samples' ]';

argJoined = offset( updateEndTime( argJoined ) );
