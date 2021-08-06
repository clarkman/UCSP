function outObj = hamming( inObj )
%
% multiply the object by a hamming window

outObj = inObj;
daSamps = inObj.samples;
numSamps = length( inObj );

daHam = hamming( numSamps );

outObj.samples = daSamps .* daHam;
