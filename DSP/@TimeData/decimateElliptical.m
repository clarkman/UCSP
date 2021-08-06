function outdata = decimateElliptical(obj, nFactor)
%
% Performs a simple 1-out-of-nfactor decimation of the samples in the input
% obj.
%

if ( (nFactor - round(nFactor)) ~= 0 ) 
    error( 'Must use integer decimation factor' );
end


% Calculate new cutoff frequency
Fc=obj.sampleRate/(nFactor/2);


% A twelfth order, very low ripple, 80 dB killer ...
[b,a] = ellip(12,0.2,120,Fc/obj.sampleRate);


% Make anew object.
outdata=filter(obj,b,a);


% Decimate
outdata.samples=outdata.samples(1:nFactor/2:end);


% Update new object
outdata.sampleRate = outdata.sampleRate / (nFactor/2);
outdata = updateEndTime(outdata);
outdata = addToTitle(outdata, ['Elliptically Decimated by ', num2str(nFactor)]);
