function obj = zeroPad( tdObj, numTotalSamples, mean )
%
% Adds zeroes to make the the object have as many
% total samples as specified by "numTotalSamples".

origSamps = tdObj.samples;
origSampLength = length(origSamps);
if( numTotalSamples < origSampLength )
    warning('"Specified total number of samples is less than existing number of samples');
    error('"zeroPad()" does not truncate.  Use "segment()"');
end

numTotalSamples
newSamples = zeros(numTotalSamples,1);

if nargin == 3
    newSamples = newSamples + mean; 
end

for ith = 1:origSampLength
    newSamples(ith) = origSamps(ith);
end

obj = tdObj;
obj.samples = newSamples;
