function impls = impulseResponse( inXferFunc )
% 
%
% Convert frequency response in traditional polar format
% to Impulse Response for convolution with time domain
% signal.  Very difficult to get this one right.
%
% Input is an N row vector with three columns:
%  Col 1 = frequency; Col 2 = magnitude; Col 3 = Phase angle



% 1. Must create conjugate-symmetric version in rectangular
%    complex (a+bi) form.

sizor = size( inXferFunc );
numPoints = (sizor(1))*2;



% 2. Now fill aray, in two halves

rectXferFunc = zeros( numPoints, 2 );
for ith = 1 : sizor(1)
    rectXferFunc(ith+sizor(1),1) = inXferFunc(ith,2) * cos( inXferFunc(ith,3) * pi/180 );
    rectXferFunc(ith+sizor(1),2) = inXferFunc(ith,2) * sin( inXferFunc(ith,3) * pi/180 );
end
reals = rectXferFunc(sizor(1)+1:numPoints,1);
imags = rectXferFunc(sizor(1)+1:numPoints,2) .* -1; % Conjugate symmetric
for ith = 1 : sizor(1)
    rectXferFunc(sizor(1)-ith+1,1) = reals(ith);
    rectXferFunc(sizor(1)-ith+1,2) = imags(ith);
end



% 3. Compute complex inverse

for ith = 1 : numPoints
    cplx(ith) = 1.0 / complex( rectXferFunc(ith,1) ,rectXferFunc(ith,2) );
end

if 0
	figure;
	%plot(sqrt(rectXferFunc(:,1).^2+rectXferFunc(:,2).^2), 'k' );
	% hold on;
	%plot( rectXferFunc(:,1), 'b' );
	% hold off;
	% hold on;
	%plot( rectXferFunc(:,2), 'g' );
	% hold off;
	hold on;
	plot( real(cplx), 'r' );
	hold off;
	hold on;
	plot( imag(cplx), 'k' );
	hold off;
end

for ith = 1 : 2 : length(cplx)
	cplx(ith) = cplx(ith) * -1.0;
end

%impls = ifft( cplx' );
impls = ifft( cplx', 'symmetric' );

%size( impls )

%figure; plot(impls)

%impls( 10 )
%impls( end-10 )

%impls = flipud( impls );

%figure; plot(impls)


%impls( 10 )
%impls( end-10 )


%plot( impls );
