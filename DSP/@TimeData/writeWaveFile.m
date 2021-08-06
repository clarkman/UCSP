function writeWaveFile( obj, filename, numStd )
%
% Write the object as a .wav file with the given filename.

% The wavwrite function requires that the data fit within +/- 1
% So rescale to fit within that range.
if( nargin == 2 )
    mn = min(obj.samples);
    mx = max(obj.samples);
    mx = max(abs(mn), abs(mx) ) + 1;
    scaledData = obj.samples * (1/mx);
    writeRate = 44100;
else
    scaledData = removeDC( obj );
    rmdd = std( scaledData );
    mndd = mean( scaledData );
    samps = scaledData.samples;
    posLim = numStd * rmdd;
    negLim = numStd * rmdd * -1;
    for ith = 1 : length(obj)
        if( samps(ith) > posLim )
            samps(ith) = posLim;
        end;
        if( samps(ith) < negLim )
            samps(ith) = negLim;
        end;
    end
    scaledData.samples = samps * 1/(3*numStd);
    plot2( scaledData );
    writeRate = 44100;

end

wavwrite(scaledData, 44100, 24, filename);

