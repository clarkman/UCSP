function [ eD, earliestTimes, sWaveTimes, errorBarHalf ] = transitWindow( quakeLats, quakeLons, staLat, staLon )

numQuakes = length(quakeLats);

earliestTimes = zeros( numQuakes, 1 );
sWaveTimes = zeros( numQuakes, 1 );
eD = zeros( numQuakes, 1 );

% Gleaned from http://neic.usgs.gov/neis/travel_times/ttgraph
% Degrees to minutes ....
highSlope = 60/122;
lowSlope = 53.3/120;
earlySlope = 20/180;

% Degrees to seconds ....
errorBarHalf = 60 * ( highSlope - lowSlope ) / 2;
meanSlope = 60 * ( highSlope + lowSlope ) / 2;
earlySlope = earlySlope * 60;

earthRadius = 6372.795;
earthCircumference = 2 * pi * earthRadius; %km

% Incoming ranges in km
for qth = 1 : numQuakes
	eD(qth) = earthDistance( [quakeLats(qth), quakeLons(qth)], [staLat, staLon] );
	sWaveTimes(qth) = ( eD(qth) / earthCircumference ) * 360 * meanSlope;
	earliestTimes(qth) =  ( eD(qth) / earthCircumference ) * 360 * earlySlope;
end

