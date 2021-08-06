function vel = velCoppens( D, S, T )
%VELCOPPENS  Sound velocity per Coppens
%
% The Coppens equation for the speed of sound in sea-water is a function of temperature, salinity and depth is given by:
% A.B. Coppens, Simple equations for the speed of sound in Neptunian waters (1981) J. Acoust. Soc. Am. 69(3), pp 862-863
%
% Range of validity: temperature 2 to 30 °C, salinity 25 to 40 parts per thousand, depth 0 to 8000 m
%
% T = temperature in degrees Celsius
% S = salinity in parts per thousand
% D = depth in metres

t = T/10;

vel = 1449.05 + 45.7*t - 5.21*t.^2 + 0.23*t.^3 + (1.333 - 0.126*t + 0.009*t.^2)*(S - 35) + (16.23 + 0.253*t)*D + (0.213-0.1*t)*D^2 + (0.016 + 0.0002*(S-35))*(S - 35)*t*D;

end
