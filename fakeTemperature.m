function fakeT = fakeTemperature( vH2O )
%FAKETEMPERATURE Finds a fake temperature for Scepter to use to emulate water locations.
% 
% vH2O - sound velocity in water
%

tAir = 293; % 20 + 273 degK
vAir = 343; % meters /sec

fakeT = tAir * (vH2O/vAir)^2 - 273;
