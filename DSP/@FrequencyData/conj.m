function outObj = conj( inObj )

if( inObj.isreal() )
    error('Real vector conjugatiion usage blocked.');
end

samps = conj( inObj.samples );



outObj = inObj;
outObj.samples = samps;

