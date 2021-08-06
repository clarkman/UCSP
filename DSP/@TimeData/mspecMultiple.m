function mags = mspecMultiple( freq, varargin )

numTDobjs = length( varargin );

display(['Processing' sprintf(' %d',numTDobjs ) ' objects.']);

mags = zeros(numTDobjs,1); % Create a mask to be used for tone analysis


for ith = 1 : numTDobjs
    obj = varargin{ith};
    [amp, mag] = mspec( obj, freq );
    plot(amp);
    mags(ith) = mag;
    title( [obj.datacommon.source, sprintf( ': %f hz, mag = %f', freq, mag ) ] );
end