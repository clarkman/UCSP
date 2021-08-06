function impls = impulseResp( inXferFunc )

sizor = size( inXferFunc );

numPoints = (sizor(1))*2;

rectXferFunc = zeros( numPoints, 2 );

freqs = zeros( numPoints, 1 );
freqs(1:sizor(1)) = flipud( inXferFunc(:,1) ) * -1.0;
freqs(sizor(1)+1:end) = inXferFunc(:,1);


for ith = 1 : sizor(1)
    rectXferFunc(ith+sizor(1),1) = inXferFunc(ith,2) * cos( inXferFunc(ith,3) );
    rectXferFunc(ith+sizor(1),2) = inXferFunc(ith,2) * sin( inXferFunc(ith,3) );
end


reals = rectXferFunc(sizor(1)+1:numPoints,1);
imags = rectXferFunc(sizor(1)+1:numPoints,2) .* -1;


for ith = 1 : sizor(1)
    rectXferFunc(sizor(1)-ith+1,1) = reals(ith);
    rectXferFunc(sizor(1)-ith+1,2) = imags(ith);
end

size(rectXferFunc)

%plot( freqs, sqrt(rectXferFunc(:,1).^2+rectXferFunc(:,2).^2) );


for ith = 1 : numPoints
    cplx(ith) = 1.0 / complex( rectXferFunc(ith,1) ,rectXferFunc(ith,2) );
end


if 1
 figure;  %plot( freqs, sqrt(rectXferFunc(:,1).^2+rectXferFunc(:,2).^2), 'k' );
 hold on; plot( freqs, rectXferFunc(:,1), 'b' ); hold off;
 hold on; plot( freqs, rectXferFunc(:,2), 'g' ); hold off;
 hold on; plot( freqs, abs(cplx), 'r' ); hold off;
 hold on; plot( freqs, unwrap(angle(cplx)), 'k' ); hold off;
 xlabel( 'Frequency (Hz)' );
 set( gca, 'YLim', [-20 20] )
end

impls = ifft( cplx', 'symmetric' );
impls = flipud( impls );

%figure; plot(impls)

