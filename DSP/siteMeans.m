function [ th, ph, mag, R, beta, thax ] = siteMeans( fx, fy, fz )
%
%

fxsize = size(fx);
fysize = size(fy);
fzsize = size(fz);

if ( sum((fxsize ~= fysize)) || sum((fysize ~= fzsize)) )
	warning( 'fx fy fz must be the same size' );
	th      = 0;
	ph      = 0;
	mag     = 0;
	R       = 0;
	beta    = 0;
	thax    = 0;
	return;
end

rows = fxsize( 1 )
cols = fxsize( 2 )

th      = zeros(rows, cols);   % theta: angle from vertical
ph      = zeros(rows, cols);   % phi: azimuth angle from x-axis
mag     = zeros(rows, cols);   % mag: pwoportional to mag of pwr in band
R       = zeros(rows, cols);   % R: polarizarion ratio (pol/unpol power)
beta    = zeros(rows, cols);   % beta: ellipticity, tan(beta)=min/maj axis
thax    = zeros(rows, cols);   % theta axis: ang of maj ellipse wrt rotated x

for li=1:rows
	li
	for lj=1:cols
		[ th(li,lj), ph(li,lj), mag(li,lj), R(li,lj), beta(li,lj), thax(li,lj) ] =  ...
		  	means2(fy(li,lj), -fx(li,lj), -fz(li,lj) );                
	end
end

return
