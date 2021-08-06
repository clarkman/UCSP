function mySqlDateRange = makeSQLDate(dnRange)

if length(dnRange) ~= 2
  display('dnRange must have two elements!')
  return;
end
if isnumeric( dnRange )
  display('numba')
else
  display('simba')
end
return
