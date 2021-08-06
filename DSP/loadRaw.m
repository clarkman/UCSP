function [ arr, t ] = loadRaw( station, channels, intervals, slop )
% Multi-purpose loader for RAW dat in QFDC. Loads CMN & BK data on a per station basis.
% The reason for per-station is that each station has its own unique time outages, and thus
% resultant arrays are regular across channels.
%
% Input Arguments:
%
% station: '0606' and 'PKD', etc.  '606' is also accepted
%
% channels:  Cell Array of channel IDs.
%   For CalMagNet:  { '1', '2', '3' } loads three channels
%   For Berkeley:  { 'BT1', 'BT2', 'BQ5' } loads three channels
%
% intervals:  Array of nx2 matlab datenums in UTC (GMT) timezone.
% 
% slop:  Number of seconds to pad load with.
%
% Currently calls cmnLoader.mexXXX un the back, however things can be speeded up!


% Usage
if nargin < 3
    error( 'Usage:: loadRaw( 609, [1 2 3], intervals, slop'  )
end

% Default slop = 5 minutes
if nargin < 4
    slop = 300;
end
slop = slop/86400;

% Parse station & channel 
staIdLen = length( station );
chIdLen = length( channels );
if( staIdLen < 3 )
    error( 'Poorly formed station name!! s/b: three chars in length minimum!'  )
end
if( chIdLen < 1 ||  chIdLen > 8 )
    error( 'Poorly formed station name!! s/b: three chars in length minimum!'  )
end
[staID, count] = sscanf( station, '%d' );
if( count > 0 )
    if staIdLen < 4
        station = [ '0', station ];
    end
    network='cmn';
    options='NoCal';
    doBK = 0;
    for cth = 1 : chIdLen
        if( length( channels{cth} ) ~= 1 )
            error( 'Bad channel code, s/b one char long for BK' );
	    end
    end
else
    network='bk';
    options='Means';
    doBK = 1;
    for cth = 1 : chIdLen
        if( length( channels{cth} ) ~= 3 )
            error( 'Bad channel code, s/b three chars long for BK' );
	    end
    end
end


% Parse intervals & channel 
intervalSize = size( intervals );
if( intervalSize(2) ~= 2 )
    error( 'Interval array must be nx2 in size!' );
end
for( rth = 1 : intervalSize(1) )
    if( intervals( rth, 1 ) > intervals( rth, 2 ) )
        error( 'Each Interval must be increasing!' );
    end
    if( intervals( rth, 2 ) - intervals( rth, 1 ) > 30 )
        warning( 'An Interval exceeding 30 days was detected.  Check your RAM and your head!' );
    end
end
numSegs = intervalSize(1);


% Allocate output array
arr = cell( numSegs, chIdLen );


% Now it gets tricky.  Files are loaded by day, but for CMN we 
% don't know exactly what time the fields start, so determination 
% as to whether to load an extra day cannot be so easily made.
pstIntervals = gmt2pst( intervals );
starts = pstIntervals( :, 1 ) - slop;
pstIntervals( :, 1 ) = starts;
finits = pstIntervals( :, 2 ) + slop;
pstIntervals( :, 2 ) = finits;


% Loading consists of first computing file names to load:
for nth = 1 : numSegs
    loadRange = pstIntervals( nth, : );
    numdays = ceil( loadRange(2)  ) - floor( loadRange(1) );
    thisDay = datenum2str( floor( loadRange(1) ) );
    for cth = 1 : chIdLen
        yetLoad=0;
        clear arf;
        thisMoniker = [ thisDay(7:10), thisDay(1:2), thisDay(4:5), ];
        for dth = 1 : numdays
            if( doBK )
                loadName = [ 'BK_', station, '_', channels{cth}, '_', thisMoniker(1:4), '_', thisMoniker(5:6), '_', thisMoniker(7:8), '.txt' ]
            else
                loadName = [ 'CHANNEL', channels{cth}, '/', thisMoniker, '.CMN.', station(2:end), '.0', channels{cth}, '.txt' ]
            end
            try
                loaded = TimeData( loadName, network, options );
                if( yetLoad == 0 )
                    arf = loaded;
                    yetLoad = 1;
                else
                    arf = cat( arf, loaded );
                end
            catch
                warning( [ 'Load of ', loadName ' failed!!!' ] );
            end
            thisMoniker = backDater( thisMoniker, 1 );
        end
        arf = segDatenum( arf, pst2gmt( loadRange ) )
        arr{ nth, cth } = arf;
        t( nth, : ) = intervals( nth, : );
    end
end

