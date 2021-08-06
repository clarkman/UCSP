function [th,ph,mag,Rp,beta,thax] = means2(fa1,fa2,fa3)
%
% MEANS2     implementation of means [1972] direction finding algorithm,
%            but taking fft's of the signals as inputs
%
% USAGE:  
%   [th,ph,mag,Rp,beta,thax] = means(fa1,fa2,fa3)
%
%   th: zenith angle of k-vector wrt z-axis
%   ph: azimuth angle of k-vector wrt x-axis
%   mag: magnitude of imag part of cov matrix (i.e., pwr in wave)
%   R:  polarization ratio, pol/unpol power
%   beta: ellipticity, tan(beta)=min/maj axis  
%   thax: theta-axis, angle of maj ellipse axis wrt x-axis
%
%   fa1,fa2,fa3: the portion of the fft's of real signals a1, a2, and a3,
%   in which direction finding will be done.  
%   Example -- take real time-series x,y,z and take their fft's fx,fy,fz. 
%   Assume time series and fft's are 1024 point long.  Then we define a
%   frequency band where the means algorithm will be implemented, say from 
%   points 100 to 200 and pass fx(100:200), fy(100:200), and fz(100:200) 
%   to means2.
%
%   This function is identical to means.m except we pass portions of the
%   fft's of the signals and not the signals themselves.  
%
%   See means.m, fft.m
%
% Written by J. Bortnik, Oct. 5th 2005
%
%  April 1, 2006:   modified k-vector so that kz always > 0.  
%                   If kz<0, we set kx = -kx, ky=-ky, kz = -kz.  That was
%                   polarization can be either LH or RH.
%  Oct. 2nd, 2006:  Modified theta_ax such that it now gives correct angle 
%                   in the range [-90,90] such that x' is always lined up 
%                   with the major axis.  


if nargin<3,
    disp('Wrong number of input arguments')
    return;
end

S       = zeros(3,3);

S(1,1) = sum( fa1.*conj(fa1) );
S(2,2) = sum( fa2.*conj(fa2) );
S(3,3) = sum( fa3.*conj(fa3) );

S(1,2) = sum( fa1.*conj(fa2) );
S(1,3) = sum( fa1.*conj(fa3) ); 
S(2,3) = sum( fa2.*conj(fa3) );

S(2,1) = conj( S(1,2) );
S(3,1) = conj( S(1,3) ); 
S(3,2) = conj( S(2,3) );

JI = [ imag(S) ];



% Get k-vector and polar angles
mag = sqrt( JI(1,2).^2 + JI(1,3).^2 + JI(2,3).^2 );
if mag==0, mag=eps; end

kx  =   JI(2,3)/mag;
ky  =  -JI(1,3)/mag;
kz  =   JI(1,2)/mag;


% Set kz to be always positive.  Forces beta to be positive (RH) or
% negative (LH), which is more natural for Pc1.  Also consistent with Pc1
% detection paper.
if kz<0,
    kx  = -kx;
    ky  = -ky;
    kz  = -kz;
end


% Get POLAR angles - be careful to get in correct quadrant!
th = acos( kz );

if (th<1e-3 | th>0.999*pi ),  % if k is vertical
    ph = 0;                     % no phi rotation
else,

    if kx > 0,       % kx +ve, Q1 or Q4
        ph = atan( ky/kx );
    elseif kx<0,    % kx -ve and ...  
        if ky>=0,   % ky +ve, Q2
            ph = atan( ky/kx )+pi;
        else,           % ky -ve, Q3
            ph = atan( ky/kx )-pi;
        end
    else,           % kx=0, phi is either 90 or -90
        if ky>=0,   % ky +ve, Q2
            ph = pi/2;
        else,           % ky -ve, Q3
            ph = -pi/2;
        end
    end     % if kx<0

end % if k vertical



% Find a rotation matrix
% Euler angles to rotate coordinate system counterclockwise about: 
% z, x, and z again
phi     = ph-pi/2;
theta   = -th;
psi     = 0;  % can choose to rotate again so x lines up with sm.

B = [cos(psi) sin(psi) 0; -sin(psi) cos(psi) 0; 0 0 1];
C = [1 0 0; 0 cos(theta) sin(theta); 0 -sin(theta) cos(theta)];
D = [cos(phi) sin(phi) 0;  -sin(phi) cos(phi) 0; 0 0 1];

A = B*C*D;

% Here we rotate the operator matrix "S" so that it is in a frame where
% the z-axis is parallel to k.  That way S.k=0 is preserved in the new
% frame, such that J.k'=0, where k' = [0;0;1] (i.e., z-axis aligned).
J = A*S*inv(A);
J2 = J(1:2,1:2);        % square 2x2 submatrix



% Polarization parameters from Fowler et al. [1967] 
% R: Polarization ratio 
dJ2 = J2(1,1)*J2(2,2) - J2(1,2)*J2(2,1);
Rp   = sqrt( 1 - 4*dJ2/( J2(1,1)+J2(2,2) )^2 );

% Unpolarized part (from Fowler et al. [1967], p2873)
Dp  = .5*( J2(1,1)+J2(2,2) )-.5*sqrt( (J2(1,1)+J2(2,2))^2 - 4*dJ2 );

% Polarized matrix
Pp = J2 - [Dp 0 ; 0 Dp];

% thax: Angle of major ellipse axis (Eq. (6)) wrt x-axis, 
tan_2theta_majax = 2*real( Pp(1,2) ) / ( Pp(1,1)-Pp(2,2) );
%thax        = .5*atan( tan_2theta_majax ); 
if J2(1,1)<J2(2,2),
    thax = .5*atan( tan_2theta_majax );
else,
    if tan_2theta_majax>0,
        thax = .5*( atan( tan_2theta_majax )+pi );
    else,
        thax = .5*( atan( tan_2theta_majax )-pi );
    end
end

if thax>pi/2,   thax=thax-pi;   end
if thax<-pi/2,  thax=thax+pi;   end


% beta: Angle describing ellipticity, where
% tan(beta) = minor axis/major axis of ellipse
% sign(beta) = rotation direciton, +ve LH, -ve RH
tan_2beta_el = i*( Pp(2,1) - Pp(1,2) ) / ...
    sqrt(  (Pp(1,1)-Pp(2,2))^2 + 4*Pp(2,1)*Pp(1,2)  );
beta    = 0.5*asin( tan_2beta_el );


