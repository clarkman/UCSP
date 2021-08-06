function str = time2str(time)
% Converts a time in seconds relative to 1 Jan 1970 to a printable string
% in the format dd-mmm-yyyy hh:mm:ss

secondsPerDay = 86400;

refdate = datenum('01-Jan-1970');

timeInDays = time / secondsPerDay;

matlabDate = refdate + timeInDays;

str = datenum2str(matlabDate); 
