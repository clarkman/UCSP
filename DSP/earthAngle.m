function angl = earthAngle( start, finish )
% Gives the angle from North from the starting point to the finish point on a spherical Earth.

earthRadius = 6371.01;


Lat1 = start(1);
Lon1 = start(2);

Lat2 = finish(1);
Lon2 = finish(2);

deltaLon = Lon1 - Lon2;
%deltaLon = Lon2 - Lon1;

angl = atan2( sind(deltaLon)*cosd(Lat2), cosd(Lat1)*sind(Lat2)-sind(Lat1)*cosd(Lat2)*cosd(deltaLon) ) * -180/pi;
if angl < 0, angl = 360 + angl;, end;