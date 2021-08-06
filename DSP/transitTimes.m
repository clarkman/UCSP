function [ sWaveTimes, errorBarHalf ] = transitTimes( eqTable )

sizor = size( eqTable )
numQuakes = sizor(1);
numStations = sizor(2);


sWaveTimes = zeros( numQuakes, numStations );
sWaveTimes = sWaveTimes - 1;  % ( -1 = No Op )

% Gleaned from http://neic.usgs.gov/neis/travel_times/ttgraph
% Degrees to minutes ....
highSlope = 60/122;
lowSlope = 53.3/120;

% Degrees to seconds ....
errorBarHalf = 60 * ( highSlope - lowSlope ) / 2;
meanSlope = 60 * ( highSlope + lowSlope ) / 2

earthRadius = 6372.795;
earthCircumference = 2 * pi * earthRadius; %km

% DEV: proof
% if( max( max( eqTable ) ) > earthCircumference/2 ), error( 'Holey thinking' );, end;

% Incoming ranges in km
for qth = 1 : numQuakes
    for sth = 1 : numStations
	if( eqTable(qth,sth) >= 0 )
	    sWaveTimes(qth,sth) = ( eqTable(qth,sth) / earthCircumference ) * 360 * meanSlope;
	end
    end
end