function [ eqTimes, eqVals, staDirNames, staLocs, eqRanges ] = eqTable( eqFileName, cmnNetworkFileName )

eqFid = fopen( eqFileName );
if( eqFid == -1 ), error( 'Bad EQ file' );, end;

netFid = fopen( cmnNetworkFileName );
if( netFid == -1 ), error( 'Bad Net info file' );, end;

earthRadius = 6372.795;


numLines = 0;
while( 1 )

    daLine = fgetl( eqFid );
    if( daLine == -1 ), break;, end;
    
    numLines = numLines + 1;


end
frewind( eqFid );

eqTimes = zeros( numLines, 1 );
eqVals  = zeros( numLines, 4 );

numEarthquakes = numLines;

for ith = 1 : numEarthquakes

    daLine = fgetl( eqFid );
    if( daLine == -1 )
        error( 'Miscounting??  Should not have crashed' );
        return
    end
    
    eqTimes(ith) = str2datenum( daLine(1:22) );
    
    if( ~mod( ith,  100 ) )
        ith
    end
    
    [eqVals(ith,:), count] = sscanf( daLine(25:55), ' %lf %lf %lf %lf' );
    if( count ~= 4 )
        daLine
        error( 'Bad sscanf of earthquake' );
        break
    end

end

fclose( eqFid );


numLines = 0;
while( 1 )

    daLine = fgetl( netFid );
    if( daLine == -1 ), break;, end;
    
    numLines = numLines + 1;


end
frewind( netFid );

numStations = numLines-3; % Skipp 99's

staDirNames = cell(numStations);
staLocs = zeros(numStations,2);


for ith = 1 : numStations

    daLine = fgetl( netFid );
    bars = strfind( daLine, '|' );
    
    staDirNames{ith} = daLine(1:bars(1)-1);

    staLocs(ith,1) = sscanf( daLine(bars(1)+1:bars(2)-1), '%lf' );
    staLocs(ith,2) = sscanf( daLine(bars(2)+1:bars(3)-1), '%lf' ) * -1;
end

fclose( netFid );

% Date       Time             Lat       Lon  Depth   Mag Magt  Nst Gap  Clo  RMS  SRC   Event ID
% ----------------------------------------------------------------------------------------------
% 2006/01/01 00:03:17.30  15.9940  -97.6060  16.00  4.00   Mc    8          0.00  UNM 200601014001

eqRanges = zeros( numEarthquakes, numStations );


for ith = 1 : numEarthquakes
    for jth = 1 : numStations
        deltaLon = eqVals(ith,2) - staLocs(jth,2);
        eqRanges( ith, jth ) = earthRadius * atan2( sqrt( ( cosd(eqVals(ith,1)) * sind(deltaLon) )^2 + ( cosd(staLocs(jth,1)) * sind(eqVals(ith,1)) - sind(staLocs(jth,1)) * cosd(eqVals(ith,1)) * cosd(deltaLon) )^2 ), sind(staLocs(jth,1)) * sind(eqVals(ith,1)) + cosd(staLocs(jth,1)) * cosd(eqVals(ith,1)) * cosd(deltaLon) );

    end
end

