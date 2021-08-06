function dnS = convertMySqlTextTimesToDN( filename, tzOff )

% Expects files with lines like this:
%{
2014-06-26 11:35:00
2014-06-26 11:45:00
%}

timeString=cellstr(textread( filename, '%s' ));

sz=size(timeString);

numTimes = sz(1);

dnSTmp = zeros(numTimes/2,1);
nextT=0;
for t = 1 : 2 : numTimes

  nextTStr = [ char(timeString{t}), ' ', char(timeString{t+1}) ];
  nextT = nextT + 1;
  dnSTmp(nextT) = mysql2datenum(nextTStr);
end

dnS = dnSTmp + tzOff/24;