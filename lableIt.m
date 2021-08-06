function labelIt(names,lats,lons)


tri=delaunay(lons,lats);
triplot(tri,lons,lats);
%hold on; voronoi(lons,lats,'Color',[0.85 0.33 0.1]);
hold on; voronoi(lons,lats);

for n = 1 : length(lats)
	name=names{n};
	text(lons(n),lats(n),name(12:15));
end

ms=12
%FP1	42.463834	-73.245703
line([-73.245703],[42.463834],'LineStyle','none','Marker','p','Color','r','MarkerSize',ms)
%FP2	42.451333	-73.249224
line([-73.249224],[42.451333],'LineStyle','none','Marker','p','Color','r','MarkerSize',ms)

legend({'Delaunay triangulation','Sensors', 'Voronoi','FP1','FP2'})

text([-73.245703],[42.463834],' FP1');
text([-73.249224],[42.451333],' FP2');

title('Pittsfield MA, Array')
ylabel('latitude');
xlabel('longitude')