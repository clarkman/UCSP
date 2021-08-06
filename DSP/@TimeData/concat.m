function outObj = concat( varargin )
% 
% Links two or more TimeData objects together.  
% Refuses if time arithmetic shows that time of last 
% sample does not fit with first sample of the next
% TimeData object given the sample rate.
%
% If the last arg supplied is a non-zero number, then
% the operation will be carried out anyway.  All other
% args must be TimeData objects.  
%
% Warnings are issued for time mismatches. Delta is reported.

% XXX Clark - needs upgrade

forceAppend = 1;
numObjs = 0;


% 1. Parse arg set
if nargin < 2
    error( 'Must supply at least two TimeData objects' );
end
if nargin == 2
    if( isa(varargin{1},'TimeData') && isa(varargin{2},'TimeData') )
        numObjs = 2;
    else
        error( 'When two args supplied, both must be TimeData objects' );
    end
end
if( isa(varargin{nargin},'TimeData') )
    numObjs = nargin;
else
    numObjs = nargin-1;
    if( varargin{nargin} ~= 0 )
        forceAppend = 1;
        warning( 'Forcing concatenation as ordered ...' );
    end
end


% 1a. XXX Clark - reject timeOffset feature for now 
for ith = 1 : numObjs
    daObj = varargin{ith};
    if( daObj.DataCommon.timeOffset ~= 0.0 )
        daError( sprintf( 'XXX Clark - rejecting timeOffset feature for now' ), forceAppend );
    end
end

% 1a. XXX Clark - reject timeOffset feature for now 
daObj = varargin{ith};
theSampleRate = daObj.sampleRate;
for ith = 2 : numObjs
    daObj = varargin{ith};
    if( daObj.sampleRate ~= theSampleRate )
        daError( sprintf( 'Sampling rate mismatch: obj1 = %g, obj%d = %g!!!', theSampleRate, ith, daObj.sampleRate ), forceAppend );
    end
end


% 2. Check time matches rigorously
for jth = 1 : (numObjs-1)
    originObj = varargin{jth};
    appendObj = varargin{jth+1};
    originEndTime = originObj.DataCommon.UTCref + ( originObj.DataCommon.timeEnd / 86400 );
    delta = ( appendObj.DataCommon.UTCref - originEndTime ) * 86400
    if( delta > 0 )
        daError( sprintf('Non-abutting files: %s %s', datenum2str(originObj.DataCommon.UTCref),datenum2str(appendObj.DataCommon.UTCref)), forceAppend );
    end
    if( delta < -120.0 )
        daError( sprintf('Files overlap too far? : %s %s', datenum2str(originObj.UTCref),datenum2str(appendObj.UTCref)), forceAppend );
    end
end


%3. Match series
for jth = 1 : (numObjs-1)
    originObj = varargin{jth};
    appendObj = varargin{jth+1};
	appendSamples = appendObj.samples;
	originSamples = originObj.samples;
	firstVal = appendSamples(1);
	numOrigSamps = length(originSamples);
	for kth = numOrigSamps: -1: 1
        if( kth == 1 )
            daError( sprintf('Non-overlapping samples') );        
        end
        if( firstVal == originSamples(kth) )
            display( sprintf( 'Potential match found %d', kth ) );
            %mth = kth;
            appth = 1;
            foundMatch = 0;
            for mth = kth : numOrigSamps
                %display( sprintf( 'samps %d %d', originSamples(mth), appendSamples(appth) ) )
                if( originSamples(mth) ~= appendSamples(appth) )
                    display( sprintf( 'Potential match rejected at mth=%d, kth=%d, appth=%d', numOrigSamps-mth, numOrigSamps-kth, appth ) );
                    %return;
                    break;
                end
                if( mth == numOrigSamps )
                    foundMatch = 1;
                    newSamps = [originSamples(1:kth-1)' appendSamples']';
                    %display( sprintf('kth = %d', kth) )
                    break;
                else
                    %display( sprintf('mth = %d %d', mth, numOrigSamps) )
                end
                appth = appth + 1;
            end
            if foundMatch
                outObj = originObj;
                outObj.samples = newSamps;
                break;
            end;
        end
	end
end



%-----------------------------------------------------------------------
function daError( msg, force )

if nargin == 1
    doForce = 0;
else
    doForce = force;
end

if doForce
    warning( msg );
else
    error( msg );
end

