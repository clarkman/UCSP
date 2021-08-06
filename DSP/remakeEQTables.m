function [ eqTimes, eqVals, staDirNames, staLocs, staDates, eqRanges ] = remakeEQTables( minMag )


earthRadius = 6372.795;

if nargin < 1
    minMag = 0;
end


% Check Environment
[status, procDir] = system( 'echo -n $CMN_PROC_ROOT' );
if( length( procDir ) == 0 || status ~= 0 )
    display( 'env must contain $CMN_PROC_ROOT variable' );
    return;
end
[status, tmpDir] = system( 'echo -n $CMN_PROC_TMP' );
if( length( tmpDir ) == 0 || status ~= 0 )
    display( 'env must contain $CMN_PROC_TMP variable' );
    return;
end

% Make Station Catalog
cmnNetworkFileName = [ tmpDir, '/staSet.tmp' ];
cmd = [ '!', procDir, '/get_stations.plx > ', cmnNetworkFileName ];
eval( cmd );

netFid = fopen( cmnNetworkFileName );
if( netFid == -1 ), error( 'Bad Net info file' );, end;

numStations = 0;
while( 1 )
    daLine = fgetl( netFid );
    if( daLine == -1 ), break;, end;
    numStations = numStations + 1;
end
frewind( netFid );

staDirNames = cell(numStations,1);
staLocs = zeros(numStations,3);
staDates = zeros(numStations,2);


for ith = 1 : numStations

    daLine = fgetl( netFid );
    bars = strfind( daLine, '|' );
    
    staDirNames{ith} = daLine(bars(1)+1:bars(2)-1);

    staLocs(ith,1) = sscanf( daLine(bars(2)+1:bars(3)-1), '%lf' );
    staLocs(ith,2) = sscanf( daLine(bars(3)+1:bars(4)-1), '%lf' );
    staLocs(ith,3) = sscanf( daLine(bars(4)+1:bars(5)-1), '%lf' );
    
    state = daLine(bars(5)+1:bars(6)-1);
    
    
    staDates(ith,1) = str2datenum( sql2stdDate( daLine(bars(6)+1:bars(7)-1) ) );
    if( strcmp( state, 'CLOSED' ) )
        staDates(ith,2) = str2datenum( sql2stdDate( daLine(bars(7)+1:end) ) );
    else
        staDates(ith,2) = now;
    end
    
end

fclose( netFid );


eqFileName = [ tmpDir, '/eqSet.tmp' ];
cmd = [ '!', procDir, '/get_earthquakes.plx ', sprintf( '%f', minMag ) ' > ', eqFileName ];
eval( cmd );

eqFid = fopen( eqFileName );
if( eqFid == -1 ), error( 'Bad EQ file' );, end;

numEarthquakes = 0;
while( 1 )
    daLine = fgetl( eqFid );
    if( daLine == -1 ), break;, end;
    numEarthquakes = numEarthquakes + 1;
end
frewind( eqFid );

eqTimes  = zeros( numEarthquakes, 1 );
eqVals  = zeros( numEarthquakes, 5 );

for ith = 1 : numEarthquakes

    daLine = fgetl( eqFid );
    if( daLine == -1 )
        error( 'Miscounting??  Should not have crashed' );
        return
    end
    bars = strfind( daLine, '|' );
    % Earthquake  Time
    eqTimes(ith) = str2datenum( sql2stdDate( daLine(1:bars(1)-1) ) );

    % Earthquake Position
    [eqVals(ith,1), count]  = sscanf( daLine(bars(1)+1:bars(2)-1), '%lf' );
    if( count ~= 1 ), error( [ 'Bad sscanf of earthquake', sprintf( ' %d ', ith ), daLine(bars(1)+1:bars(2)-1), 'latitude!' ] );, end;
    [eqVals(ith,2), count]  = sscanf( daLine(bars(2)+1:bars(3)-1), '%lf' );
    if( count ~= 1 ), error( [ 'Bad sscanf of earthquake', sprintf( ' %d ', ith ), daLine(bars(1)+1:bars(2)-1), 'longitude!' ] );, end;
    [eqVals(ith,3), count]  = sscanf( daLine(bars(3)+1:bars(4)-1), '%lf' );
    if( count ~= 1 ), error( [ 'Bad sscanf of earthquake', sprintf( ' %d ', ith ), daLine(bars(1)+1:bars(2)-1), 'altitude!' ] );, end;
    [eqVals(ith,4), count]  = sscanf( daLine(bars(4)+1:end), '%lf' );
    if( count ~= 1 ), error( [ 'Bad sscanf of earthquake', sprintf( ' %d ', ith ), daLine(bars(1)+1:bars(2)-1), 'magnitude!' ] );, end;

end

fclose( eqFid );

eqRanges = zeros( numEarthquakes, numStations );


for ith = 1 : numEarthquakes
    for jth = 1 : numStations
        if( eqTimes(ith) >= staDates(jth,1) && eqTimes(ith) <= staDates(jth,2) )
	    deltaLon = eqVals(ith,2) - staLocs(jth,2);
		if( deltaLon > 180 ) 
		    deltaLon = 360 - deltaLon;
		end
	    eqRanges( ith, jth ) = earthRadius * atan2( sqrt( ( cosd(eqVals(ith,1)) * sind(deltaLon) )^2 + ( cosd(staLocs(jth,1)) * sind(eqVals(ith,1)) - sind(staLocs(jth,1)) * cosd(eqVals(ith,1)) * cosd(deltaLon) )^2 ), sind(staLocs(jth,1)) * sind(eqVals(ith,1)) + cosd(staLocs(jth,1)) * cosd(eqVals(ith,1)) * cosd(deltaLon) );
        else
	    eqRanges( ith, jth ) = -1;
	end
    end
end

