function sensorHeight( angl, ht )
%SENSORHEIGHT Compute shooter radius & plot for ceiling mounts
%   angl in degrees (scalar)
%   ht in feet (1x2 | 2x1) min and max height

h = ht(1):ht(2);
tanTh = tand(angl);
sensorOffAngles=[0, 15, 30, 45, 70];

for ht = 1 : numel(sensorOffAngles)
  hold on;
    plot( h, (h-muzHt(ht))*tanTh);
  hold off;
  leg{ht}=sprintf('Muzzle Height %d ft',muzHt(ht));
end
set(gca,'XLim', [h(1), h(end)])

xlabel('Height above floor - ft');
ylabel('Maximum radial visibility - ft');

set( gca, 'XGrid', 'on' )
set( gca, 'YGrid', 'on' )
legend(leg,'Location','NorthWest')

title( [ 'Radial distance - IR coverage, ' sprintf('%d-deg sensor',angl ) ] );