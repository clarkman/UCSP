function [vals] = waveEq(phi,k,w,x,t)

numPts = numel(x)
if numPts ~= numel(t)
	error('length of x and t must match!')
end

vals = zeros(numPts,3);
for p = 1 : numPts
  vals(p,1) = x(p);
  vals(p,2) = t(p);
  vals(p,3) = phi * cosd(k*x(p)-w*t(p));
end