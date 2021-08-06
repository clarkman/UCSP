function outdata = whiten(obj)
%
% Whitens the spectrum by fitting a 4th order polynomial and subtracting it.
%

% Initialize output to be the same as the input
outdata = obj;


x = 1:length(obj.samples);
x = x';

% Normalize the x-axis so polyfit is better behaved -- see polyfit help
y = (x - mean(x)) ./ std(x);

% Generater 4th order polynomial
poly = polyfit(y, obj.samples, 4);

% subtract
outdata.samples = obj.samples - polyval(poly, y);

outdata = addToTitle(outdata, ['Whitened Using 4th Order Polynomial']);
