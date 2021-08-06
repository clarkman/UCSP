function outObj = quotient( B, A );

outObj = B;

lenA = length(A);
lenB = length(B);

if( lenA < lenB )
    samps = B.samples;
    B.samples = samps(1:lenA);
else
    samps = A.samples;
    A.samples = samps(1:lenB);
end

q = B.samples ./ A.samples;


outObj.samples = q;

