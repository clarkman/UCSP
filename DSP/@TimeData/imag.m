function outObj = imag( inObj )

outObj = inObj;
if isreal( inObj.samples )
    error( 'Samples are not complex!' );
else
    outObj.samples = imag( inObj.samples);
end
