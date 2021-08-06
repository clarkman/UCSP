function outObj = real( inObj )

outObj = inObj;
if isreal( inObj.samples )
    warning( 'Samples are not complex!' );
else
    outObj.samples = real( inObj.samples);
end
