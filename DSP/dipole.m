function dipole

ptArray = zeros(2,360);

for h = 1 : 10

for ith = 1 : 360
    theta = ith * pi/180;
    r = h * sin( ith * pi/180 )^2;
    ptArray(1, ith) = r * cos( theta );
    ptArray(2, ith) = r * sin( theta );
end

hold on;
plot( ptArray(1,:), ptArray(2,:) )
hold off;

end

set( gca, 'XLim', [-10 10] )
set( gca, 'YLim', [-10 10] )
