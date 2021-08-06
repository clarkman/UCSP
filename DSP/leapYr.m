function true = leapYr( year )

true = 0;

if( year < 1988 || year > 2020 )
    error('Year Out of RANGE for leap year');
end

if( year == 1988 ), true = 1; end;
if( year == 1992 ), true = 1; end;
if( year == 1996 ), true = 1; end;
if( year == 2000 ), true = 1; end;
if( year == 2004 ), true = 1; end;
if( year == 2008 ), true = 1; end;
if( year == 2012 ), true = 1; end;
if( year == 2016 ), true = 1; end;
if( year == 2020 ), true = 1; end;

