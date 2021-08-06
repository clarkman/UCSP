%attempt to perform polyfit in order to figure out if there was a shift in cal signal since there was a hole...trying to see if hole is 100n
x = [1:9];
y = [5,6,10,20,28,33,34,36,42];
xp = [1:.01:9];
for k = 1:4
    coeff = polyfit(x,y,k)
    yp(k,:) = polyval(coeff,xp);
    J(k) = sum((polyval(coeff,x)-y).^2);
end


x = textread('03493.txt');
t = 1:length(x);

polyfit(t,x, )