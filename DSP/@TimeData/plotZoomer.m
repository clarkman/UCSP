function plotZoomer( inObj, typer )
%
% Called when magnifying glass is unclicked
% via Mathworks-patched zoom.m
% 
% Codes (typer) are assigned to the figure's
% 'UserData' field in the @[FTD]Data/plot.m 
% routines, and translated by Zoom_Types.m
%
% The time zoom is based on the notion of "log2"
% or the series 1, 2, 5, 10, 20, 50, ...   Thus
% there are three axes scalings per decade.
%
% There are a number of natural regimes for dating
% data, not all a good match with common sense. We
% list some logic:
%
% The exact time of the start of the file and the 
% exact time of the stop at each end is key. Full 
% date/time/doy are therefore stamped at the end of 
% each page (for absolute time plots)
%
% Next are subdivisions of the view in cutomary units:
%
% Quarter seconds (SS:SS)
% Half seconds (SS:SS)
% Seconds (SS)
% Quarter minutes (MM:SS)
% Half minutes (MM:SS)
% Minutes (MM)
% Quarter hours (HH:MM)
% Half hours (HH:MM)
% Hours (HH)
% Eighth days (DD-HH)
% Quarter days (DD-HH)
% Half days (DD-HH)
% Days (DD)
% Months (YY/MM)


% The facts Jack
xAxisLims = get( gca, 'XLim' );
plotWidth = xAxisLims(2) - xAxisLims(1);
if( plotWidth < 0 ) 
    warning('Negative absolute time plot!!')
    return
end


% Guardian of the Gates
switch typer
    case 9
        absTime = 0;
        numTicksPlotted = 8;
        [ xAxisLabel, tickMarks, tickMarkLabels ] = timeLabeler( plotWidth, numTicksPlotted );
        xlabel( xAxisLabel );
        set( ax, 'XTick', tickMarks );
        set( ax, 'XTickLabel', tickMarkLabels );
        return
    case 10
        absTime = 0;
        display('Relative scaling not implemented yet');
        return
    case 14
        absTime = 1;
    otherwise
        warning('Wrong plot type');
        return
end



begStr        = datenum2str( xAxisLims(1) );
finStr        = datenum2str( xAxisLims(2) );
begYear       = sscanf( begStr( 7 : 10 ), '%d' );
finYear       = sscanf( finStr( 7 : 10 ), '%d' );
begMonth      = sscanf( begStr( 1 : 2 ), '%d' );
finMonth      = sscanf( finStr( 1 : 2 ), '%d' );
begDay        = sscanf( begStr( 4 : 5 ), '%d' );
finDay        = sscanf( finStr( 4 : 5 ), '%d' );
begHour       = sscanf( begStr( 12 : 13 ), '%d' );
finHour       = sscanf( finStr( 12 : 13 ), '%d' );
begMinute     = sscanf( begStr( 15 : 16 ), '%d' );
finMinute     = sscanf( finStr( 15 : 16 ), '%d' );
begSecond     = sscanf( begStr( 18 : 19 ), '%d' );
finSecond     = sscanf( finStr( 18 : 19 ), '%d' );
begSecsFract  = sscanf( begStr( 21 : 22 ), '%d' );
finSecsFract  = sscanf( finStr( 21 : 22 ), '%d' );

t0 = sprintf( '%02d/%02d/%02d %02d:%02d:%02d.%02d', begYear, begMonth, begDay, begHour, begMinute, begSecond, begSecsFract );
t1 = sprintf( '%02d/%02d/%02d %02d:%02d:%02d.%02d', finYear, finMonth, finDay, finHour, finMinute, finSecond, finSecsFract );

doyBeg = sprintf( '%d', round( str2datenum( sprintf( '%02d/%02d/%02d 00:00:00.00', begYear, begMonth, begDay ) ) - str2datenum( sprintf( '%02d/01/01 00:00:00.00', begYear ) ) ) );
doyFin = sprintf( '%d', round( str2datenum( sprintf( '%02d/%02d/%02d 00:00:00.00', finYear, finMonth, finDay ) ) - str2datenum( sprintf( '%02d/01/01 00:00:00.00', finYear ) ) ) );


% Time Divisions
% Quarter seconds (SS.SS)
quarterSecond = 1.0 / ( 4.0 * 86400 );
% Half seconds (SS.SS)
halfSecond = 1.0 / ( 2.0 * 86400 );
% Seconds (SS)
second = 1.0 / 86400;
% Quarter minutes (MM:SS)
quarterMinute = 1.0 / ( 1440 * 4 );
% Half minutes (MM:SS)
halfMinute = 1.0 / ( 1440 * 2 );
% Minutes (MM)
minute = 1.0 / 1440;
% Quarter hours (HH:MM)
quarterHour = 1.0 / ( 24 * 4 );
% Half hours (HH:MM)
halfHour = 1.0 / ( 24 * 2 );
% Hours (HH)
hour = 1.0 / 24;
% Eighth days (DD-HH)
eighthDays = 1.0 / 8;
% Quarter days (DD-HH)
fourthDays = 1.0 / 4;
% Half days (DD-HH)
halfDays = 1.0 / 2;
% Days (DD)
days = 1.0;

numFractDayCodes = 12;
units = zeros( numFractDayCodes, 1 );
units(1)  = quarterSecond;
units(2)  = halfSecond;
units(3)  = second;
units(4)  = quarterMinute;
units(5)  = halfMinute;
units(6)  = minute;
units(7)  = quarterHour;
units(8)  = halfHour;
units(9)  = hour;
units(10) = eighthDays;
units(11) = fourthDays;
units(12) = halfDays;


if( plotWidth > 1 ) % do days/months/years
    display( 'Days not implemented yet' );
else
    for dth = 1 : numFractDayCodes
        quotient = plotWidth / units(dth);
        display( sprintf('%d %f %f ', dth, units(dth), quotient ) );
        if( quotient < 16 )
            break;
        end
    end
end

% Determine first tick
switch dth
    case 1
        ack = (begSecsFract/quarterSecond) + 1;
        firstTickStr = sprintf( '%02d/%02d/%02d %02d:%02d:%02d.%02d', begYear, begMonth, begDay, begHour, begMinute, begSecond, ack*0.25 )
        firstTick = str2datenum( firstTickStr );
    case 2
        ack = (begSecsFract/halfSecond) + 1;
        firstTickStr = sprintf( '%02d/%02d/%02d %02d:%02d:%02d.%02d', begYear, begMonth, begDay, begHour, begMinute, begSecond, ack*0.5 )
        firstTick = str2datenum( firstTickStr );
end





xTickies      = zeros( floor(quotient)+2, 1 );
xTickies(1)   = xAxisLims(1);
xTickies(end) = xAxisLims(2);
xTickLabls{1}   = 't0';
for ith = 1: floor(quotient)
end
xTickLabls{floor(quotient)+2} = xAxisLims(2);


xlabel( ['t0 = ' t0 ' (' doyBeg ')       ()       t1 = ' t1 ' (' doyFin ')' ] )

return

set( gca,'XTick', xTickies );
set( gca,'XTickLabel', xTickLabls );

%set( gca,'XTick', [ xAxisLims(1), xAxisLims(2) ] );
%set( gca,'XTickLabel', { 't0' 't1' } );






