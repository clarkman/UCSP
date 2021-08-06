function [ xAxisLabel, tickMarks, tickMarkLabels ] = timeLabeler( span, numTicksPlotted )

numMajTicks = 40;
tickIncrs = zeros( numMajTicks, 1 );
tickIncrs(1) = 1/32;
tickIncrs(2) = 8/32;
tickIncrs(3) = 1;
tickIncrs(4) = 2;
tickIncrs(5) = 3;
tickIncrs(6) = 5;
tickIncrs(7) = 10;
tickIncrs(8) = 15;
tickIncrs(9) = 30;
tickIncrs(10) = 60;   % 1 minute
tickIncrs(11) = 120;
tickIncrs(12) = 180;
tickIncrs(13) = 300;
tickIncrs(14) = 600;
tickIncrs(15) = 900;
tickIncrs(16) = 1800;
tickIncrs(17) = 3600;   % 1 hour
tickIncrs(18) = 5400;
tickIncrs(19) = 7200;
tickIncrs(20) = 10800;
tickIncrs(21) = 21600;
tickIncrs(22) = 43200;
tickIncrs(23) = 86400;   % 1 day
tickIncrs(24) = 86400 * 2;
tickIncrs(25) = 86400 * 3;
tickIncrs(26) = 86400 * 5;
tickIncrs(27) = 86400 * 7;   % 1 week
tickIncrs(28) = 86400 * 10;
tickIncrs(29) = 86400 * 14;   % 1 fortnight
tickIncrs(30) = 86400 * 20;   % 1 score
tickIncrs(31) = 86400 * 30;  
tickIncrs(32) = 86400 * 60; 
tickIncrs(33) = 86400 * 120; 
tickIncrs(34) = 86400 * 180; 
tickIncrs(35) = 86400 * 365;    % 1 year
tickIncrs(36) = 86400 * 365 * 2; 
tickIncrs(37) = 86400 * 365 * 5;  
tickIncrs(38) = 86400 * 365 * 10 + 2;
tickIncrs(39) = 86400 * 365 * 20 + 5;
tickIncrs( numMajTicks ) = 86400 * 365 * 50 + 12;  % Golden Cent

numTickLabels = 5;
tickLabels = cell( numTickLabels );
tickLabelRanges = zeros( numTickLabels, 2 );
tickDivisors = zeros( numTickLabels, 2 );

tickLabelRanges( 1, 1 ) = 1;
tickLabelRanges( 1, 2 ) = 2;
tickLabels{ 1 } = 'Samples';
tickDivisors( 1 ) = 1/32;

tickLabelRanges( 2, 1 ) = 3;
tickLabelRanges( 2, 2 ) = 7;
tickLabels{ 2 } = 'Seconds';
tickDivisors( 2 ) = 1;

tickLabelRanges( 3, 1 ) = 8;
tickLabelRanges( 3, 2 ) = 14;
tickLabels{ 3 } = 'Minutes';
tickDivisors( 3 ) = 60;

tickLabelRanges( 4, 1 ) = 15;
tickLabelRanges( 4, 2 ) = 20;
tickLabels{ 4 } = 'Hours';
tickDivisors( 4 ) = 3600;

tickLabelRanges( 5, 1 ) = 21;
tickLabelRanges( 5, 2 ) = 26;
tickLabels{ 5 } = 'Days';
tickDivisors( 5 ) = 86400;

whichTickSet = 1;
spanSlice = span / numTicksPlotted;
while( spanSlice >= tickIncrs(whichTickSet) )
    whichTickSet = whichTickSet + 1;
end

tickSpan = tickIncrs(whichTickSet);
tickCount = ceil(span / tickSpan);
tickMarkLabels = cell(tickCount);
tickMarks = zeros( tickCount, 1 );

for ith = 1 : tickCount
    tickMarks(ith) = (ith-1) * tickSpan;
end

foundLabelSet = -1;
for( sth = 1 : numTickLabels )
    if( tickLabelRanges( sth, 1 ) <= whichTickSet && whichTickSet <= tickLabelRanges( sth, 2 ) )
        foundLabelSet = sth;
        break;
    end
end
if( foundLabelSet < 0 ), foundLabelSet = numTickLabels;, end;

xAxisLabel = tickLabels{ foundLabelSet };

for tth = 1 : tickCount
    tickMarkLabels{tth} = sprintf( '%2.1f', tickMarks(tth) / tickDivisors( foundLabelSet ) );
end

