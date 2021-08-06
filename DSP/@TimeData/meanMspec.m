function [mean, freqs, varargout]  = meanMspec( freqLo, freqHi, freqIter, filtLen, nDec, varargin )
%
% This function computes the spectral mean of an aribtrary number
% of TimeData objects using the mspec method. 

%1. Determine extent of work.
numTimeDataObjects = length(varargin);

cd each;

%2. Check data
for jth = 1 : numTimeDataObjects
    if( ~isa( varargin{jth}, 'TimeData' ) )
        error( 'All data must be TimeData format!' );
    end
end

% 2. Compute spectra and sum
mean = 0;
for each = 1 : numTimeDataObjects
    unit = varargin{each};
    %unit = decimate( obj, 13 );
    %sprintf('Computing mSpectrum #%d, %s',each, unit.DataCommon.source);
    [freqs, mags] = mspecSweep( freqLo, freqHi, freqIter, filtLen, nDec, 0, unit )
    % Keep these expensive results
    varargout(each) = {mags};
    mean = mean + mags;
end


% 3. Prepare output
for ith = 1 : length(mean)
    mean(ith) = mean(ith) / numTimeDataObjects;
end
plotTitle = sprintf( 'mSpec mean of %d signals, from %0.2f to %0.2f hz, in %0.2f hz steps. \n Filter length = %0.2f secs, decimation factor = %d', numTimeDataObjects, freqLo, freqHi, freqIter, filtLen, nDec);

plot( freqs, mags );
title( plotTitle );

saveas( hndl, [file '.meanMspec.fig'], 'fig' );
print( hndl,'-djpeg60', [file '.meanMspec.jpg'] );


cd ..;

return;


