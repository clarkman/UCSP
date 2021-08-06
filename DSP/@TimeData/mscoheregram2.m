function out = mscoheregram2( obj1, obj2, fftLength, fractionOverlap, nOffset, plotType )
%
% out = mscoheregram( obj1, obj2, timeSlice, fftLength, fractionOverlap, nOffset, plotType )
% 
% Render an array of rank 2, one axis for frequency
% one for time.  The array dimensions are controlled
% by the three variables:  fftLength, fractionOverlap, and nOffset.
%
% Version two compensates for differing sample rates teh best it can by choosing the two
% closest samples to start the FFT with.  This of course might mean that there are a few
% missedsamplkes
%

if( nargin == 5 )
    plotType = 'default';
end

% Sanity Checking
if( abs(obj1.sampleRate - obj2.sampleRate) > 1.0 )
    error('mscoheregram: sample rates too different');
end

in1 = obj1;
in2 = obj2;

fs = in1.sampleRate;


% Now compute overlapped section of time series

begTime1 = in1.DataCommon.UTCref;
begTime2 = in2.DataCommon.UTCref;
finTime1 = in1.DataCommon.UTCref + in1.DataCommon.timeEnd / 86400;
finTime2 = in2.DataCommon.UTCref + in2.DataCommon.timeEnd / 86400;
% A crude, alomst heuristic, check
if( (begTime1 > finTime2) || (begTime2 > finTime1) )
    error( 'Time Series do not overlap ...!' );
end

% Determine which series is shortest in terms of time and use it
% to scale.  The other will effectively be trimmed to discard samples.
% Shorter is called 'minor' and longer is called 'major.'
if( (finTime1 - begTime1) >= (finTime2 - begTime2) )
    major = obj1;
    minor = obj2;
else
    major = obj2;
    minor = obj1;
end 
lengthMajor=length( major );
lengthMinor=length( minor );

% Now determine the number of FFTs that will be taken
numNonOverlappedFFTs = mod( lengthMinor, fftLength );


%return;

if 0
    if 0
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
end
% Need error checking
overLapFactor = 1.0/(1.0 - fractionOverlap);

serieslength=lengthMajor;

numFFTSegs = serieslength / fftLength;
numSlices = ceil( numFFTSegs ) * overLapFactor
fftSlideStep = ceil( ( numFFTSegs / numSlices ) * fftLength );
timeSlice = fftSlideStep / in1.sampleRate;


sliceStarts = ones( numSlices, 2 );
sliceStarts(1) = 1;
for jth = 2 : numSlices
    sliceStarts(jth,1) = fftSlideStep + sliceStarts(jth-1);
    sliceStarts(jth,2) = (jth-1)*timeSlice+timeSlice/2;
end

residual = -1;
firstTruncatedSlice = numSlices;
while( residual < 0.0 )
    residual = serieslength - ( sliceStarts(firstTruncatedSlice) + fftLength );
    firstTruncatedSlice = firstTruncatedSlice - 1;
end
firstTruncatedSlice = firstTruncatedSlice+1;
sliceStarts = sliceStarts(1:firstTruncatedSlice,:);
numSlices = firstTruncatedSlice;
sliceStarts(numSlices,1) = serieslength - fftLength;
sliceStarts(numSlices,2) = in1.DataCommon.timeEnd - timeSlice/2;



numFreqPts = fftLength / 2 + 1;
freqRes = fs / fftLength;


surface = zeros(numSlices,numFreqPts);




for ith = 1 : numSlices
   
    samp1 = sliceStarts(ith,1);
    samp2 = samp1 + fftLength;
       
    %tint = hsv2rgb( [ith/totalRun, 1.0, 0.618] );
    
    display( [ 'Computing slice: ', sprintf( '%d', ith ) ] );

    if( nOffset >= 0 )
       [obj, F] = mscohere( slice(in1,samp1,samp2), slice(in2,samp1+nOffset,samp2+nOffset), '', fractionOverlap, fftLength );
    else
       [obj, F] = mscohere( slice(in1,samp1-nOffset,samp2-nOffset), slice(in2,samp1,samp2), '', fractionOverlap, fftLength );
    end        
     
     
    switch lower( plotType )
        case 'squared'
            surface( ith,: ) = abs( obj.samples );
            plotSpread = [0.25, 1];
            valTyper =  'Coherence^2';
        case 'log'
            surface( ith,: ) = 10.0 * log10( abs( obj.samples ) ); %power
            plotSpread = [ 10.0 * log10( 0.25 ), 10.0 * log10( 1.0 ) ];
            valTyper =  'log Coherence';
        otherwise % default
            surface( ith,: ) = sqrt( abs( obj.samples ) );
            plotSpread = [0.5, 1];
            valTyper =  'Coherence';
    end
end


if 1
    newSampleRate = 1 / timeSlice;
    out = FrequencyTimeData(obj1.DataCommon, surface', newSampleRate, freqRes);
    
    out.timeOffset = 0;

    % Shift start time by 1/2 an FFT length
    %out = addToTimeOffset( out, timeSlice/2 );
    
    sta1 = [ in1.DataCommon.network ' '  in1.DataCommon.station ' '  in1.DataCommon.channel ];
    sta2 = [ in2.DataCommon.network ' '  in2.DataCommon.station ' '  in2.DataCommon.channel ];

    out.source = [ sta1 ' vs ', sta2 ];

    % Update the end time
    sgramsize = size(out.samples);
    parent = out.DataCommon;
    out.title = ['CMN' obj1.DataCommon.station obj1.DataCommon.channel '-to-' 'CMN' obj2.DataCommon.station obj2.DataCommon.channel, ' sampsOff=' sprintf('%d',nOffset) ];
    out.history = 'Coherence';
    out.valueType =  valTyper;
    out.valueUnit = [ 'Range: ' sprintf( '%g-%g', plotSpread(1), plotSpread(2) ) ];
    out.colorRange = plotSpread;
else
    surf( tAxis,F,surface',...
          'FaceColor', 'interp', ...
          'EdgeColor', 'none', ...
          'FaceLighting', 'phong' );
    %daspect([5 5 1])
    axis tight
    view( -120,30 )
    camlight left

    ylabel('Hz');
    xlabel('seconds');
    zlabel('Coherence');
    set(get(gcf,'CurrentAxes'),'ZLim',[0 1.0]);
    %title( [ 'Coherence of ', label1, ' to ' label2 ]);
    %text( sampsOff*scalar, 16, 1, [ 'Baseline is: ', sprintf('%f',baseCoherence) ], 'BackgroundColor', [1 1 1] )
    %text( sampsOff*scalar, 0, 0.95, [ 'Baseline coherence is: ', sprintf('%f',baseCoherence) ], 'BackgroundColor', [1 1 1], 'EdgeColor', [0 0 0] )
    %text( sampsOff*scalar, 0, 0.8, [ 'Best found is ', sprintf('%f',bestCoherence), ', obtained by sliding ', sprintf('%d',bestCoherenceIndex), ' samples.' ], 'BackgroundColor', [1 1 1], 'EdgeColor', [0 0 0] )
    %title( [ 'Coherence of ', label1, ' to ' label2, 'is: ', sprintf('%f',baseCoherence), '. Best found is ', sprintf('%f',bestCoherence), ', obtained by sliding ', sprintf('%d',bestCoherenceIndex), ' samples.' ]);
    %title( [ 'Base coherence of ', label1, ' to ' label2, 'is: ', sprintf('%f',baseCoherence), '. Best found is ', sprintf('%f',bestCoherence), ', obtained by sliding ', sprintf('%d',bestCoherenceIndex), ' samples.' ]);
end

return;

