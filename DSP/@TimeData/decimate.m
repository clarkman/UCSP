function outdata = decimate(obj, nfactor)
%
% Performs a simple 1-out-of-nfactor decimation of the samples in the input
% obj.
%

% Initialize output to be the same as the input
outdata = obj;

% Old - oops
%outdata.samples = outdata.samples(1 : nfactor : length(outdata.samples) );

% New- use the Matlab way!
% Keep us honest
if( nfactor ~= floor( nfactor ) )
    error('nfactor must be an integer!');
end


daSamples = obj.samples;
outdata.samples = decimate(daSamples,nfactor);

outdata.sampleRate = outdata.sampleRate / nfactor;

outdata = updateEndTime(outdata);

outdata = addToTitle(outdata, ['Decimated by ', num2str(nfactor)]);
