function [freqs, mags] = mspecSweep( freqlo, freqhi, freqiter, filtlen, ndec, keep, varargin )

numTDobjs = length( varargin );

display(['Processing' sprintf(' %d',numTDobjs ) ' objects.']);

% Error Checking
if( freqlo > freqhi )
    error( ['freqhi less than freqlo'] );
end
if( freqiter > freqhi - freqlo )
    error( ['freqiter too big'] );
end

% Linear/Log plot
logit = 0;
if( freqiter <= 0.0 )
    display( ['Using log scale'] );
    numSteps = 1000;
    logit = 1;
else
    display( ['Using linear scale'] );
    numSteps = ceil( ( freqhi - freqlo ) / freqiter )+1;
end


icolor = 1;
for ith = 1 : numTDobjs
    obj = varargin{ith};
    mags = zeros( numSteps, 1 );
    freqs = mags;
    sizzer=decimate(abs(obj.samples),ndec);
    surff = zeros(numSteps,length(sizzer));
    clear sizzer;
    if( logit )
	for stepr = 1 : numSteps
            freqs(stepr) = freqlo + (stepr-1) * freqiter;
            display(['Processing ' sprintf('%f',freqs(stepr)) ' hz']);
            [amp, mags(stepr), t] = mspec( obj, freqs(stepr), filtlen, ndec );
            surff(stepr,:) = (amp.samples)';
	end
    else
	for stepr = 1 : numSteps
            freqs(stepr) = freqlo + (stepr-1) * freqiter;
            display(['Processing ' sprintf('%f',freqs(stepr)) ' hz']);
            [amp, mags(stepr), t] = mspec( obj, freqs(stepr), filtlen, ndec );
            surff(stepr,:) = (amp.samples)';
	end
    end
    
    if keep
        hndl = figure;
        %hold on;
        plot( freqs, mags );
        %hold off;
        title( [obj.DataCommon.source, sprintf( ': %f hz steps', freqiter ) ] );
        [path, file, ext, anot] = splitpath(obj.DataCommon.source);
        freqRange = sprintf('.%0.0f.%0.0f',freqlo,freqhi);
        saveas( hndl, [file freqRange '.mspectrum.fig'], 'fig' );
        %print( hndl,'-dmeta', [file freqRange '.mspectrum.emf'])
        print( hndl,'-djpeg60', [file freqRange '.mspectrum.jpg']);
        %close( hndl );
	
        hndl = figure;
        surf(t ,freqs ,surff, 'linestyle', 'none' ); view(2)
        title( [obj.DataCommon.source, sprintf( ': %f hz steps', freqiter ) ] );
        saveas( hndl, [file freqRange '.mspectrogram.fig'], 'fig' );
        print( hndl,'-djpeg60', [file freqRange '.mspectrogram.jpg'])
        %close( hndl );
	close all;
    end
    
end

return;

% Examples
mspecSweep( 1001, 1099, 0.5, 2, 200, MG3HXUK2M04Dec0655B )
plot(spectrum(MG3HXUK2M04Dec0655B,6000))
plot(spectrogram(MG3HXUK2M04Dec0655B,6000,0.875))
mspecSweep( 1001, 1099, 0.2, 5, 200, MG3HXUK2M04Dec0655B )
plot(spectrum(MG3HXUK2M04Dec0655B,6000*5/2))
plot(spectrogram(MG3HXUK2M04Dec0655B,6000*5/2,0.875))
mspecSweep( 1001, 1099, 0.1, 10, 200, MG3HXUK2M04Dec0655B )
plot(spectrum(MG3HXUK2M04Dec0655B,6000*5/2*2))
plot(spectrogram(MG3HXUK2M04Dec0655B,6000*5/2,0.875))
