function t = coherenceFinder( obj1, obj2, fftLength, ovrLap, maxOffset, stepSize )
%
% Slide samples, compute coherence. 

in1 = obj1;
in2 = obj2;

% Sanity Checking
if( abs(in1.sampleRate - in2.sampleRate) > 0.1 )
    error('coherenceFinder: sample rates must match');
end
if( length(in1) ~= length(in2) )
    error('coherenceFinder: time series lengths must match');
end
fs = in1.sampleRate;


t1 = maxOffset;
t2 = t1+fftLength*2;

numSteps = 2 * (maxOffset / stepSize);


t = zeros( numSteps, 2 );

numFreqPts = fftLength / 2 + 1;
surface = zeros(numSteps,numFreqPts);


for ith = 1 : numSteps

    offler = ith*stepSize - maxOffset;

    [obj, F] = mscohere( removeDC(slice(in1,t1,t2)), removeDC(slice(in2,t1+offler,t2+offler)), ovrLap, fftLength );

    samps = obj.samples;
    samps = samps / length( obj );
    
    surface( ith,: ) = obj.samples;

    t( ith, 1 ) = offler;
    t( ith, 2 ) = sum( samps ) ;
end



