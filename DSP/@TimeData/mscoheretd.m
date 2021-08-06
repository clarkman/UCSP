function [out, F] = mscohere( in1, in2, fractionOverlap, fftlen )
%
% Generates a frequency versus time spectrogram 
% 
lenIn1 = length(in1);
lenIn2 = length(in2);
lenIn = 0;


obj1=in1;
obj2=in2;


if (length(obj1.samples) == 0)
    error([' TimeData object for ', obj1.DataCommon.source, ' has no samples']);
end
if (length(obj2.samples) == 0)
    error([' TimeData object for ', obj2.DataCommon.source, ' has no samples']);
end

if( lenIn1 == lenIn2 )
    lenIn = lenIn2;
elseif( lenIn1 > lenIn2 )
    obj1.samples=in1.samples(1:lenIn2);
    lenIn = lenIn2;
else
    obj2.samples=in2.samples(1:lenIn1);
    lenIn = lenIn1;
end

fs1 = obj1.sampleRate;
fs2 = obj2.sampleRate;
if( abs( fs1 - fs2 ) > 0.01 )
    error([' TimeData sample rates not equal !!']);
end


fs = fs1;
freqRes = fs / fftlen;

nOverlap = 1.0/(1.0 - fractionOverlap);
%overlapPts = fix(fractionOverlap*fftlen);


obj1.samples=double(obj1.samples);
obj2.samples=double(obj2.samples);
obj1 = zeroCenter(obj1);
obj2 = zeroCenter(obj2);

% Careful there Eugene!  The window can hurt
%[Cxy,F] = mscohere(obj1.samples, obj2.samples, wdow, '', fftlen, fs );
%MSCOHERE(X,Y,WINDOW,NOVERLAP,NFFT,Fs)
[Cxy,F] = mscohere( obj1.samples, obj2.samples, blackman(fftlen), nOverlap, fftlen, fs );
%[Cxy,F] = mscohere( obj1.samples, obj2.samples );


out = FrequencyData(obj1.DataCommon, Cxy, freqRes);

out.title = ['CMN' obj1.DataCommon.station obj1.DataCommon.channel '-to-' 'CMN' obj2.DataCommon.station obj2.DataCommon.channel ];
out.history = 'Coherence';
out.valueType =  'Coherence';
out.valueUnit = 'Range 0-1';


return;
