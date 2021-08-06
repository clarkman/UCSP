function distance = deg2nm(deg_lat)
% Convert the input deg_lat (in degrees of latitude) into an equivalent nautical mile
% distance along the Earth's surface.  Uses a round Earth approximation.
%

WGS84 = [6378137.0 6356752.3142];  % Earth's semi-major and semi-minor axes, in meters

WGS84nm = WGS84 / 1852.00;  % in nautical miles

WGS84nmperdeg = WGS84nm * 2 * pi / 360;  % convert to nautical miles per degree latitude

distance = deg_lat * mean(WGS84nmperdeg);