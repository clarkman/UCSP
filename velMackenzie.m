function vel = velMackenzie( D, S, T )
% VELMACKENZIE Sound velocity per Mackenzie
%
% The Mackenzie equation for the speed of sound in sea-water is a function of temperature, salinity and depth is given by:
% K.V. Mackenzie, Nine-term equation for the sound speed in the oceans (1981) J. Acoust. Soc. Am. 70(3), pp 807-812
%
% Range of validity: temperature 2 to 30 °C, salinity 25 to 40 parts per thousand, depth 0 to 8000 m
%
% T = temperature in degrees Celsius
% S = salinity in parts per thousand
% D = depth in metres

vel = 1448.96 + 4.591.*T - 5.304*10^-2.*T.^2 + 2.374*10^-4.*T.^3 + 1.340.*(S-35) + 1.630*10^-2.*D + 1.675*10^-7.*D.^2 - 1.025*10^-2.*T.*(S - 35) - 7.139*10^-13.*T.*D.^3;

end