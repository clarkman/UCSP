function dopObj = doppler(satAlt, freq, crossDistance, numSeconds, iRefract)
%
% dopObj = doppler(satAlt, ffreq, crossDistance, numSeconds)
% satAlt = satellite altitude (km)
% satSpeed = satellite circular speed (km/sec)
% freq is the pre-shift base frequency (Hz)
% crossDistance is the distance of a point on the ground from the satellite
% ground track (in km)
% numSeconds is the number of seconds of satellite motion to compute the
% Doppler frequency shift versus time, starting from the point of closest
% approach (zero Doppler).
% The output dopObj is a TimeData object of Doppler freq shift versus time


if nargin == 4
    iRefract = 1;
end

WGS84 = [6378137.0 6356752.3142];  % Earth's semi-major and semi-minor axes, in meters
WGS84 = WGS84 / 1000;              % Convert to km

% Use round Earth approximation
earthRadius = mean(WGS84);          % km 

earthCircumference = 2 * pi * earthRadius;      % km


satelliteRadius = earthRadius + satAlt;         % km

% Calculate satellite speed from Eq. (6-5) p.135 of Wertz (SMAD III).
satelliteSpeed = 7.905366 * sqrt(earthRadius/satelliteRadius);          % km/sec


angle = (crossDistance / earthCircumference) * 2 * pi;   % radians

% Cartesian coords. of the point on the ground
pPsn = [ earthRadius*cos(angle)  0  earthRadius*sin(angle) ];

% Max rate of Earth's rotation at equator
earthRotationRate = earthCircumference / 86400;


satellitePeriod = satelliteRadius * 2 * pi / satelliteSpeed;  % in seconds

satAngularSpeed = 2 * pi / satellitePeriod;         % rad/sec

dop = zeros(numSeconds+1,1);
for isec = 0 : numSeconds
    arcAngle = isec * satAngularSpeed;
    
    satPsn = [satelliteRadius * cos(arcAngle)      satelliteRadius * sin(arcAngle)      0 ];
    
    satVel = [satelliteSpeed * cos(arcAngle+pi/2)   satelliteSpeed * sin(arcAngle+pi/2) 0 ];
    
    dop(isec+1) = dopplerCalc(freq, satVel, satPsn, pPsn,iRefract);
end



dopObj = TimeData;
dopObj.sampleRate = 1;
dopObj.samples = dop;
dopObj.valueType = ' Doppler Frequency Shift';
dopObj.valueUnit = 'Hz';

fscaled = freq;  funits = 'Hz';
if fscaled >= 1e6
    fscaled = fscaled / 1e6;  funits = 'MHz';
elseif fscaled >= 1e3
    fscaled = fscaled / 1e3;  funits = 'KHz';
end
dopObj.source = ['Satellite @ ', num2str(satAlt), ' km alt., ', num2str(fscaled), ' ', funits, ' with ', num2str(crossDistance), ' km offset'];
dopObj.UTCref = 0;


function dop = dopplerCalc(freq, aVel, aPsn, bPsn, iRefract)
% freq = transmit frequency (Hz)
% aVel = Cartesian velocity vector of object A (km/sec)
% aPsn, bPsn = Cartesian coordinate vectors of objects A and B (km)
% Object B is assumed to be stationary

lightSpeed = 299792.458 / iRefract;                   % speed of light (km/sec)

diffVec = aPsn - bPsn;

magDiffvec = sqrt(dot(diffVec, diffVec));

unitDiffVec = diffVec / magDiffvec;

dop = - freq * dot(aVel, unitDiffVec) / lightSpeed;

