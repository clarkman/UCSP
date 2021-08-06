function [lat, lon] = hms2dec( latDeg, latMin, latSec, lonDeg, lonMin, lonSec )

lat = latDeg + latMin / 60 + latSec / 3600;
lon = lonDeg + lonMin / 60 + lonSec / 3600;

sprintf('%0.7f, %0.7f',lat,lon)
