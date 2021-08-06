function ranges = delaunayHist( tris, lats, lons )

sz = size(tris)

numTris = sz(1); 
ranges = zeros(1,3*numTris);

edgeCount = 0;
for t = 1 : numTris
	tri = tris(t,:); 
	edgeCount = edgeCount + 1;
	ranges(edgeCount) = earthDistance( [lats(tri(1)) lons(tri(1))],[lats(tri(2)) lons(tri(2))] );
	edgeCount = edgeCount + 1;
	ranges(edgeCount) = earthDistance( [lats(tri(1)) lons(tri(1))],[lats(tri(3)) lons(tri(3))] );
	edgeCount = edgeCount + 1;
	ranges(edgeCount) = earthDistance( [lats(tri(2)) lons(tri(2))],[lats(tri(3)) lons(tri(3))] );
end

% earthCircum = 24901;
% milePerDeg = earthCircum / 360;

%ranges = ranges .* 0.621371;

