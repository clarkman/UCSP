function country = countrycode( whichOne )


% Load earthquakes
switch whichOne
   case 'California'
      country='CMN';
   case 'Peru'
      country='PMN';
   case 'Taiwan'
      country='TMN';
   otherwise
      error('Unknown region.')
end
