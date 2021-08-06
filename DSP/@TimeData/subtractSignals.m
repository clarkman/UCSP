function out = subtractSignals( obj1, obj2 )

in1 = obj1;
in2 = obj2;
% Sanity Checking
if( in1.sampleRate ~= in2.sampleRate )
    error('mscoheregram: sample rates must match');
end
fs = in1.sampleRate;

lengthIn1=length(in1);
lengthIn2=length(in2);
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

in1 = offset( in1 )
in2 = offset( in2 )
lengthIn1=length(in1)
lengthIn2=length(in2)

out = in1 - in2;

out.DataCommon.source = [ in1.DataCommon.source ' - ' in2.DataCommon.source ];

return 

numFreqPts = fftLength / 2 + 1;
freqRes = fs / fftLength;
%overlapPts = fix(fractionOverlap*fftLength);

beg=1;

fin=timeSlice*in1.sampleRate

slicesQuotient = lengthIn1 / fin;
numSlices = floor( slicesQuotient )
numTails = slicesQuotient - numSlices;

tAxis = zeros(numSlices,1);
surface = zeros(numSlices,numFreqPts);


for ith = 1 : numSlices
   
    samp1 = floor(beg + fin * (ith-1));
    samp2 = ceil(fin * ith);
   
    %tint = hsv2rgb( [ith/totalRun, 1.0, 0.618] );
   
    tAxis(ith) = (ith-1)*timeSlice+timeSlice/2;
   
   hold on;
    if( nOffset >= 0 )
       [obj, F] = mscohere( slice(in1,samp1,samp2), slice(in2,samp1+nOffset,samp2+nOffset), blackman(fftLength), fractionOverlap, fftLength );
    else
       [obj, F] = mscohere( slice(in1,samp1-nOffset,samp2-nOffset), slice(in2,samp1,samp2), blackman(fftLength), fractionOverlap, fftLength );
    end        
    
    surface(ith+1,:) = sqrt(obj.samples);
   hold off;
end


if 1
    newSampleRate = 1 / timeSlice;
    out = FrequencyTimeData(obj.DataCommon, surface', newSampleRate, freqRes);
    
    out.timeOffset = 0;

    % Shift start time by 1/2 an FFT length
    out = addToTimeOffset( out, timeSlice/2 );

    % Update the end time
    sgramsize = size(out.samples);
    parent = out.DataCommon;
    out.timeEnd = parent.timeOffset + numSlices*timeSlice;
    out.title = ['CMN' obj1.DataCommon.station obj1.DataCommon.channel '-to-' 'CMN' obj2.DataCommon.station obj2.DataCommon.channel, ' sampsOff=' sprintf('%d',nOffset) ];
    out.history = 'Coherence';
    out.valueType =  'Coherence';
    out.valueUnit = 'Range 0-1';
    out.colorRange = [0, 1];
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

