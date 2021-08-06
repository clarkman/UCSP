function dateStr = SQLDateFromDatenum( dateVal )

dStr = datenum2str( dateVal );

dateStr = [ dStr(7:10), '-', dStr(1:2), '-', dStr(4:5), ' ', dStr(12:19) ];