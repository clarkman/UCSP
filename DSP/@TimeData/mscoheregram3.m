function out = mscoheregram3( obj1, obj2, fftLength, ovrlap, plotType )
%
% out = mscoheregram( obj1, obj2, timeSlice, fftLength, fractionOverlap, nOffset, plotType )
% 
% Render an array of rank 2, one axis for frequency
% one for time.  The array dimensions are controlled
% by the three variables:  


if( nargin == 5 )
    plotType = 'default';
end

in1 = obj1;
in2 = obj2;
% Sanity Checking
if( abs(in1.sampleRate - in2.sampleRate) > 0.01 )
    error('mscoheregram: sample rates must match');
end
fs = in1.sampleRate;


% Now compute overlapped section of time series
lengthIn1=length(in1);
lengthIn2=length(in2);

begTime1 = in1.DataCommon.UTCref;
begTime2 = in2.DataCommon.UTCref;
finTime1 = in1.DataCommon.UTCref + in1.DataCommon.timeEnd / 86400;
finTime2 = in2.DataCommon.UTCref + in2.DataCommon.timeEnd / 86400;
% A crude, alomst heuristic, check
if( (begTime1 > finTime2) || (begTime2 > finTime1) )
    error( 'Time Series do not overlap ...!' );
end

if 1
    % Trim to 'identical'.
    if( in1.DataCommon.UTCref ~= in2.DataCommon.UTCref )
        display( 'correcting starttime mismatch' );
        tDiff = (in2.DataCommon.UTCref - in1.DataCommon.UTCref) * 86400
        if( tDiff > 10000 )
            error( [ 'mscoheregram: whacky timing diff = ', sprintf( '%d',tDiff ), ' seconds.' ]);
        end
        sampsDiff = round(tDiff * in1.sampleRate);
        if( sampsDiff > 0 )
           % in2 starts later than in1
           in1 = slice(in1, sampsDiff, lengthIn1);
        else
           % in1 starts later than in2
           in2 = slice(in2, sampsDiff*-1, lengthIn2);
        end
    end
    lengthIn1=length(in1);
    lengthIn2=length(in2);
    if( lengthIn1 > lengthIn2 )
        % in1 longer than in2
        in1 = slice( in1, 1, lengthIn2 );
    else
        % in2 longer than in1
        in2 = slice( in2, 1, lengthIn1 );
    end
    lengthIn1=length(in1);
    lengthIn2=length(in2);
    if( lengthIn1 ~= lengthIn2 )
        error('mscoheregram: signal lengths mismatched');
    end
else
    if( lengthIn1 > lengthIn2 )
        in1 = slice(in1,1, lengthIn2);
    else
        in2 = slice(in2,1, lengthIn1);
    end
end

% Bloody well check ...
serieslength=length(in1);
lengthIn2=length(in2);
if( lengthIn2 ~= serieslength ), error( 'Segment trimming error ...!' ), end;
if( serieslength < fftLength )
    error( 'FFT length is longer than common segment of time series ...!' )
end

% Next, trim to an even number of ffts

numFFTSegs = floor( serieslength / fftLength );
numFFTdSamples = numFFTSegs * fftLength;
samps = in1.samples;
in1.samples = samps(1:numFFTdSamples);
samps = in2.samples;
in2.samples = samps(1:numFFTdSamples);

segmentLengthDivisor = 2 ^ ovrlap;


% Now compute starts and stop samples for every slice
% and check rigidly before implementing (lessons burned)
% Remember for forcing fftLength to be a power of two, we
% have an "even" power of two series that may be evenly
% subdivided.  THANK you.

totalSegmentCount = (numFFTSegs-1) * 2 ^ ovrlap + 1;
sliceIncr = fftLength / segmentLengthDivisor;


% Col 1 = startT, Col 2 = stopT, Col 3 = num2Avg
segmentIndices=zeros(totalSegmentCount-1, 3);

for jth = 1 : totalSegmentCount
    segmentIndices(jth,1) = (jth-1) * sliceIncr + 1;
    segmentIndices(jth,2) = segmentIndices(jth,1)-1 + fftLength;
    segmentIndices(jth,3) = segmentLengthDivisor;    
end
for jth = 1 : segmentLengthDivisor
    segmentIndices(jth,3) = jth;    
    segmentIndices(end-(jth-1),3) = jth;    
end

lowestStartIndex = min( segmentIndices(:,1) );
highestStopIndex = max( segmentIndices(:,2) );

if( lowestStartIndex < 1 )
    error( 'Have a cow man!' );
end
if( highestStopIndex > numFFTdSamples )
    error( 'Have two cows man!' );
end


numFreqPts = ( fftLength / 2 ) + 1;

surface = zeros( totalSegmentCount, numFreqPts );

size(surface)

for ith = 1 : totalSegmentCount
    s1 = slice(in1,segmentIndices(ith,1),segmentIndices(ith,2));
    s2 = slice(in2,segmentIndices(ith,1),segmentIndices(ith,2));
    s1 = zeroPad( s1, fftLength*2 );
    s2 = zeroPad( s2, fftLength*2 );
    [Cxy, F] = mscohere( s1.samples, s2.samples, blackman(fftLength), '', fftLength, fs );

    surface( ith, : ) = Cxy;

end

size(surface)


%out = surface;
%return;

out = FrequencyTimeData(in1.DataCommon, surface', fs, fs/fftLength);

return

% Shift start time by 1/2 an FFT length
out = addToTimeOffset(out, (fftLength/2) / fs );

% Update the end time
sgramsize = size(out.samples);
out.timeEnd = out.timeOffset + (sgramsize(2)-1) / newSampleRate;


