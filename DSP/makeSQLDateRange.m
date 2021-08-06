function mySqlDateRange = makeSQLDateRange( dnRange )

if length(dnRange) ~= 2
  display('dnRange must have two elements!')
  return;
end

if( isnumeric( dnRange ) )
  mySqlDateRange = { std2sqlDate(datenum2str(dnRange(1))), std2sqlDate(datenum2str(dnRange(2))) };
else
  error('Args must be datenums')
end

