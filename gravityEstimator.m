function gVecEst = gravityEstimator( a, sliceInds )
% Expects ordered x, y, z vector in a

if nargin < 4
  % Assume the standard 4 sec signal
  Fs = 5000;
  sliceInds = [ 0.15*Fs, 0.19*Fs ];
end

xHat = mean(a(sliceInds(1):sliceInds(2),1));
yHat = mean(a(sliceInds(1):sliceInds(2),2));
zHat = mean(a(sliceInds(1):sliceInds(2),3));

gVecEst = [ xHat, yHat, zHat ];



