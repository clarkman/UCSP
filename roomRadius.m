function roomRadius( angl, ht, muzHt )
%ROOMRADIUS Compute shooter radius & plot
%   angl in degrees (scalar)
%   ht in feet (1x2 | 2x1) min and max height
%   muzHt = (1xn | nx1) muzzle heights to plot.

h = ht(1):ht(2);

for deg = 1 : numel(angl)
  hold on;
    plot( h, (h-muzHt)*tand(angl(deg)) );
  hold off;
  leg{deg}=sprintf('Sensor FOV %d deg.',angl(deg)*2);
end
set(gca,'XLim', [h(1), h(end)])

xlabel('Height above floor - ft');
ylabel('Maximum radial visibility - ft');

set( gca, 'XGrid', 'on' )
set( gca, 'YGrid', 'on' )
legend(leg,'Location','NorthWest')

title( [ 'Radial distance - IR coverage, ' sprintf('%d-deg sensor',angl ) ] );