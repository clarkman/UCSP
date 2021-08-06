function A = trapArea( a, b, rate )

a = abs(a);
b = abs(b);

minV = min(a,b);
maxV = max(a,b);

T = 1.0/rate;

A = minV * T + ( maxV - minV ) * T * 0.5;

